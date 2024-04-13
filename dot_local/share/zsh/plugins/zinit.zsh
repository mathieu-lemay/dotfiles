_zinit_script="${ZINIT_HOME:-"${HOME}/.local/share/zinit"}/zinit.git/zinit.zsh"

if [[ ! -e "${_zinit_script}" ]]; then
    unset _zinit_script
    return
fi

source "${_zinit_script}"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

zinit wait lucid for "MichaelAquilina/zsh-autoswitch-virtualenv"

unset _zinit_script
