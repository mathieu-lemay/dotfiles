if type paru &>/dev/null; then
    pm() {
        if [ -n "${VIRTUAL_ENV}" ]; then
            echo "Can't run paru in venv"
            return 1
        fi

        paru "$@"
    }

    up() {
        if [ -n "${VIRTUAL_ENV}" ]; then
            echo "Can't run paru in venv"
            return 1
        fi

        paru -Syu "$@"
    }

    pmi() {
        if [ -n "${VIRTUAL_ENV}" ]; then
            echo "Can't run paru in venv"
            return 1
        fi

        paru -Slq | fzf --multi --preview 'paru -Si {1}' -q "${@:-}" | xargs -ro paru -S
    }

    pmr() {
        if [ -n "${VIRTUAL_ENV}" ]; then
            echo "Can't run paru in venv"
            return 1
        fi

        paru -Qq | fzf --multi --preview 'paru -Si {1}' -q "${@:-}" | xargs -ro paru -Rns
    }

    compdef pm='paru'
elif type yay &>/dev/null; then
    pm() {
        if [ -n "${VIRTUAL_ENV}" ]; then
            echo "Can't run yay in venv"
            return 1
        fi

        yay "$@"
    }

    up() {
        if [ -n "${VIRTUAL_ENV}" ]; then
            echo "Can't run yay in venv"
            return 1
        fi

        yay -Syu "$@"
    }

    pmi() {
        if [ -n "${VIRTUAL_ENV}" ]; then
            echo "Can't run yay in venv"
            return 1
        fi

        yay -Slq | fzf --multi --preview 'yay -Si {1}' -q "${@:-}" | xargs -ro yay -S
    }

    pmr() {
        if [ -n "${VIRTUAL_ENV}" ]; then
            echo "Can't run yay in venv"
            return 1
        fi

        yay -Qq | fzf --multi --preview 'yay -Si {1}' -q "${@:-}" | xargs -ro yay -Rns
    }

    compdef pm='yay'
fi

function arch-clone() {
    if [ $# -lt 1 ]; then
        echo "Usage: $0 packages"
        exit 1
    fi

    for pkg in "$@"; do
        git clone "https://gitlab.archlinux.org/archlinux/packaging/packages/${app}.git"
    done
}

function aur-clone() {
    if [ $# -lt 1 ]; then
        echo "Usage: $0 packages"
        exit 1
    fi

    for pkg in "$@"; do
        git clone "https://aur.archlinux.org/${pkg}.git"
    done
}
