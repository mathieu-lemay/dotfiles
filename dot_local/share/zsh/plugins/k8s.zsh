if command -v kubectl &>/dev/null; then
    if command -v kubecolor &>/dev/null; then
        function kctl() {
            aws-sso-login

            kubecolor "$@"
        }
    else
        function kctl() {
            aws-sso-login

            kubectl "$@"
        }
    fi

    compdef kctl='kubectl'
fi

if command -v k9s &>/dev/null; then
    function k9s() {
        aws-sso-login

        command k9s "$@"
    }
fi

if command -v kubectx &>/dev/null; then
    functions ksel() {
        kubectx "${1:-}" || return 1
        kubens "${2:-}" || return 1
    }

    alias kx=kubectx
    alias kn=kubens
fi
