AWS_PROFILE_CACHE_FILE="$HOME/.cache/zsh/aws-profile"

[[ -d "$(dirname "${AWS_PROFILE_CACHE_FILE}")" ]] || mkdir -p "$(dirname "${AWS_PROFILE_CACHE_FILE}")"

if [ -e "${AWS_PROFILE_CACHE_FILE}" ]; then
    export AWS_PROFILE="$(< "${AWS_PROFILE_CACHE_FILE}")"
fi

# Profiles {{{

function aws-current-profile {
    if [[ -n "${AWS_PROFILE}" ]]; then
        echo "Current Profile: ${AWS_PROFILE}"
    else
        echo "Profile not set"
    fi
}

function aws-list-profiles() {
    grep -oE '\[profile .*?\]' "${AWS_CONFIG_FILE}" | sed -E 's/\[profile (.*?)\]/\1/g'
}

function aws-switch-profile {
    local profile=$(aws-list-profiles | fzf -q "$*")

    [[ -n "${profile}" ]] || return

    echo "Switching to profile: ${profile}"
    echo -n "${profile}" > "${AWS_PROFILE_CACHE_FILE}"
    export AWS_PROFILE="${profile}"
}

function aws-unset-profile {
    [[ -e "${AWS_PROFILE_CACHE_FILE}" ]] && rm "${AWS_PROFILE_CACHE_FILE}"
    unset AWS_PROFILE
}

# }}}

# Account Info {{{

function aws-get-account-id() {
    aws sts get-caller-identity | jq -r '.Account'
}

function aws-get-current-region() {
    if [ -n "${AWS_PROFILE}" ]; then
        aws configure get --profile "${AWS_PROFILE}" region
    else
        aws configure get region
    fi
}

# }}}

# Credentials {{{

function aws-mfa {
    local mfa_code="$(ykman oath code -s broadsign-aws)"
    echo -n "$mfa_code" | xsel -b
    echo "$mfa_code"
}

function aws-assume-role {
    if [ -z "$AWS_PROFILE" ]; then
        printf "\\e[31m[ERROR]\\e[0m   %s\\n" "AWS_PROFILE not set" >&2
        return
    fi

    role_arn="$(aws configure get role_arn)"
    if [ $? -ne 0 ]; then
        printf "\\e[31m[ERROR]\\e[0m   %s\\n" "Unable to get role arn" >&2
        return
    fi

    credentials="$(aws sts assume-role --role-arn "${role_arn}" --role-session-name "admin@${AWS_PROFILE}")"
    if [ $? -ne 0 ]; then
        printf "\\e[31m[ERROR]\\e[0m   %s\\n" "Failed to get credentials" >&2
        return
    fi

    export AWS_ACCESS_KEY_ID="$(echo "$credentials" | jq -r '.Credentials.AccessKeyId')"
    export AWS_SECRET_ACCESS_KEY="$(echo "$credentials" | jq -r '.Credentials.SecretAccessKey')"
    export AWS_SESSION_TOKEN="$(echo "$credentials" | jq -r '.Credentials.SessionToken')"
    expiry="$(echo "$credentials" | jq -r '.Credentials.Expiration')"
    echo "Session expires on ${expiry}"
}

function aws-clear-session {
    unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
}

function aws-ecr-login() {
    local accountid region passwd profile_name

    profile_name="${1:-}"
    if [ -n "${profile_name}" ]; then
        echo "Using AWS Profile: ${profile_name}"
        export AWS_PROFILE="${profile_name}"
    else
        echo "Using current AWS Profile: ${AWS_PROFILE:-}"
    fi

    accountid="$(aws-get-account-id)"
    region="$(aws-get-current-region)"
    passwd="$(aws ecr get-login-password)"

    repo="${accountid}.dkr.ecr.${region}.amazonaws.com"
    echo "Logging in docker repository ${repo}"

    echo "$passwd" | docker login --username AWS --password-stdin "${repo}"
}

function aws-eks-get-token() {
    if [[ $# -ne 1 ]]; then
        echo "Usage: $0 <cluster-name>" >&2
        return 1
    fi

    aws eks get-token --cluster-name preprod | jq -r '.status.token'
}

function aws-sso-login() {
    local last_check_file="${XDG_CACHE_HOME:-${HOME}/.cache}/aws/last_sso_check"

    if [[ "${1:-}" != "-f" ]] && [[ -e "${last_check_file}" ]] && [[ -z "$(find "${last_check_file}" -mmin +480 2>/dev/null)" ]]; then
        return
    fi

    if aws sso login; then
        mkdir -p "$(dirname "${last_check_file}")"
        touch "${last_check_file}"
    fi
}

function __aws-sso-get-access-token {
    for f in ~/.aws/sso/cache/*; do
        token="$(jq -r '.accessToken | select(. != null)' < "${f}")"

        [[ -z "${token}" ]] && continue

        expiry="$(date -d "$(jq -r '.expiresAt' < "${f}")" "+%s")"

        if [ "${expiry}" -gt "$(date "+%s")" ]; then
            echo "${token}"
        fi
        return
    done
}

function aws-sso-assume() {
    local token accountid credentials

    [[ -n "${AWS_PROFILE:-}" ]] || aws-switch-profile

    aws-sso-login
    aws-clear-session

    token="$(__aws-sso-get-access-token)"

    if [[ -z "${token}" ]]; then
        echo "Unable to find access token." >&2
        return 1
    fi

    accountid="$(aws-get-account-id)"
    credentials="$(aws sso get-role-credentials --role-name AdminAccess --account-id "${accountid}" --access-token "${token}")"

    if [[ -z "${credentials}" ]]; then
        echo "Error fetching credentials" >&2
        return 1
    fi

    export AWS_ACCESS_KEY_ID="$(echo "$credentials" | jq -r -e '.roleCredentials.accessKeyId')"
    export AWS_SECRET_ACCESS_KEY="$(echo "$credentials" | jq -r -e '.roleCredentials.secretAccessKey')"
    export AWS_SESSION_TOKEN="$(echo "$credentials" | jq -r -e '.roleCredentials.sessionToken')"
    unset AWS_PROFILE
}

# }}}

# Cloud Formation {{{

function aws-cf-create-stack() {
    local stack_name="${1:?Stack name not specified}"
    local template_file="${2:?Template file not specified}"

    aws cloudformation create-stack --stack-name "${stack_name}" --template-body "$(cat "${template_file}")"
    aws cloudformation wait stack-create-complete --stack-name "${stack_name}"
}

function aws-cf-update-stack() {
    local stack_name="${1:?Stack name not specified}"
    local template_file="${2:?Template file not specified}"

    aws cloudformation update-stack --stack-name "${stack_name}" --template-body "$(cat "${template_file}")"
    aws cloudformation wait stack-update-complete --stack-name "${stack_name}"
}

function aws-cf-delete-stack() {
    local stack_name="${1:?Stack name not specified}"

    aws cloudformation delete-stack --stack-name "${stack_name}"
    aws cloudformation wait stack-delete-complete --stack-name "${stack_name}"
}

function aws-cf-delete-stacks() {
    local pattern="$1" stacks
    if [[ -z "${pattern}" ]]; then
        echo "Pattern not specified"
        return 1
    fi

    stacks=($(aws cloudformation list-stacks | jq -r '.StackSummaries[] | select(.StackName | contains("'"${pattern}"'")) | select(.StackStatus != "DELETE_COMPLETE") | .StackId'))

    if [[ -z "${stacks}" ]]; then
        echo "No stacks to delete"
        return 0
    fi

    echo "Stacks:"
    echo ${stacks} | xargs -n1 echo "  "

    echo -n "Delete stacks? [y/N] "
    read -s -k response
    echo ""

    response="$(echo "$response" | tr '[:upper:]' '[:lower:]')"

    if [[ "${response}" != "y" ]]; then
        return 2
    fi

    for s in ${stacks}; do
        aws-cf-delete-stack "${s}"
    done
}

# }}}

# Misc {{{

function aws-get-ipgranges {
    curl "https://ip-ranges.amazonaws.com/ip-ranges.json" | jq '.prefixes'
}

alias aws-local='aws --profile=default --endpoint-url=http://localhost:4566'

# }}}

# Completion {{{

autoload bashcompinit
bashcompinit
complete -C aws_completer aws

# }}}

# vim: foldmethod=marker
