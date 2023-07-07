# Only run if tmux is actually installed
if ! command -v tmux &> /dev/null; then
    return 0
fi

# Disable autostart from ssh connections or from virtual terminal
# Disable also for root as it's probably from sudo, which would result in nested tmux
if [[ -n "${SSH_CLIENT}" || "${TERM}" = "linux" || ${EUID} -eq 0 ]]; then
    export ZSH_TMUX_AUTOSTART=false
fi

# Configuration variables
#
# Automatically start tmux
ZSH_TMUX_AUTOSTART=${ZSH_TMUX_AUTOSTART:-true}

# Automatically close the terminal when tmux exits
ZSH_TMUX_AUTOQUIT=${ZSH_TMUX_AUTOQUIT:-${ZSH_TMUX_AUTOSTART}}

# Name of the tmux socket
ZSH_TMUX_SOCKET_NAME=${ZSH_TMUX_SOCKET_NAME:-default}

# The TERM to use for non-256 color terminals.
# Tmux states this should be screen, but you may need to change it on
# systems without the proper terminfo
ZSH_TMUX_FIXTERM_WITHOUT_256COLOR=${ZSH_TMUX_FIXTERM_WITHOUT_256COLOR:-tmux}

# The TERM to use for 256 color terminals.
# Tmux states this should be screen-256color, but you may need to change it on
# systems without the proper terminfo
ZSH_TMUX_FIXTERM_WITH_256COLOR=${ZSH_TMUX_FIXTERM_WITH_256COLOR:-tmux-256color}

# Change TPM install path
export TMUX_PLUGIN_MANAGER_PATH="${XDG_DATA_HOME}/tmux/plugins/"

function _zsh_tmux_setup_term() {
    # Determine if the terminal supports 256 colors
    if [[ $(tput colors) -eq 256 ]]; then
        export ZSH_TMUX_TERM=${ZSH_TMUX_FIXTERM_WITH_256COLOR}
        export ZSH_TRUE_COLOR=1
    else
        export ZSH_TMUX_TERM=${ZSH_TMUX_FIXTERM_WITHOUT_256COLOR}
        export ZSH_TRUE_COLOR=0
    fi
}

function _zsh_tmux_cleanup() {
    unset ZSH_TMUX_TERM
    unset ZSH_TRUE_COLOR
}

# Wrapper function for tmux.
function _zsh_tmux_plugin_run() {
    _zsh_tmux_setup_term

    command tmux -L "${ZSH_TMUX_SOCKET_NAME}" "$@"
    ret=$?
    _zsh_tmux_cleanup
    return $ret
}

# Alias to for one-time disable of autoquit
alias tq="(ZSH_TMUX_AUTOSTART=false SHLVL=0 \${TERMINAL} &>/dev/null &)"

# Do nothing if already in tmux
[[ -n "${TMUX}" ]] && return 0

if [[ "${ZSH_TMUX_AUTOSTART}" == "true" ]]; then
    # Start tmux
    _zsh_tmux_setup_term
    exec tmux -L "${ZSH_TMUX_SOCKET_NAME}"
else
    # Setup an alias to the wrapper
    compdef _tmux _zsh_tmux_plugin_run
    alias tmux=_zsh_tmux_plugin_run
fi
