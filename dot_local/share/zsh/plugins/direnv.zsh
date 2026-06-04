command -v direnv &> /dev/null || return

direnv-disable() {
    unset -f _direnv_hook

    eval "$(cd /tmp; direnv export zsh)"
}

direnv-enable() {
    eval "$(direnv hook zsh)"
}

direnv-enable
