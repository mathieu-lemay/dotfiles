debug()   { if [[ -n "${DEBUG:-}" ]]; then printf "\\e[34m[DEBUG]\\e[0m   %s\\n" "$*" >&2 ; fi }
info()    { printf "\\e[32m[INFO]\\e[0m    %s\\n" "$*" >&2 ; }
warning() { printf "\\e[33m[WARNING]\\e[0m %s\\n" "$*" >&2 ; }
error()   { printf "\\e[31m[ERROR]\\e[0m   %s\\n" "$*" >&2 ; }
fatal()   { printf "\\e[35m[FATAL]\\e[0m   %s\\n" "$*" >&2 ; exit 1 ; }
prompt()  { printf "\\e[36m[PROMPT]\\e[0m  %s\\n" "$*" >&2 ; }

# TODO: Make this POSIX compatible
if [[ -n "${ZSH_VERSION:-}" ]]; then
    prompt-confirmation() {
        if [[ $# -lt 1 ]]; then
            echo "Usage: $0 prompt [default]" >&2
            return 1
        fi

        local prompt defans
        prompt="$1"
        defans="${2:-n}"
        defans="${defans:l}"

        if [[ "${defans}" == "y" ]]; then
            prompt="${prompt} [Y/n]? "
        else
            prompt="${prompt} [y/N]? "
        fi

        echo -n "${prompt}"
        read -r -s -k response
        echo ""

        # shellcheck disable=SC2116
        # echo to trim whitespaces
        response="$(echo "${response:l}")"

        if [[ "${response:-${defans}}" == "y" ]]; then
            return 0
        fi

        return 1
    }
fi
