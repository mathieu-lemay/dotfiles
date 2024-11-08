[[ -d "${HOME}/.local/share/zsh/prompts" ]] || return

# Color shortcuts {{{

let idx=0
let idx_bright=8
for color in black red green yellow blue magenta cyan white; do
    eval $color='${idx}'
    eval bright_$color='${idx_bright}'
    let idx=idx+1
    let idx_bright=idx_bright+1
done
unset idx idx_bright
color_reset="%f%k"

# }}}

__zsh_get_venv_prompt() {
    local p

    p=${VIRTUAL_ENV:t}

    if [[ "${VIRTUAL_ENV_PROMPT}" == '('?*') ' && "${VIRTUAL_ENV_PROMPT}" != "(${p}) " ]]; then
        p="${VIRTUAL_ENV_PROMPT[2,-3]}"
    fi

    echo "${p}"
}

__zsh_load_vcs_info() {
    vcs_info

    if contains "${vcs_info_msg_0_}" "|"; then
        vcs_action_msg="$(cut -d '|' -f1 <<< ${vcs_info_msg_0_})"
        # Hack to remove leading space when there are no changes
        vcs_branch_msg="$(cut -d '|' -f2 <<< ${vcs_info_msg_0_} | awk '{$1=$1};1')"
    else
        vcs_action_msg=""
        # Hack to remove leading space when there are no changes
        vcs_branch_msg="$(awk '{$1=$1};1' <<< ${vcs_info_msg_0_})"
    fi
}

function zle-keymap-select {
    zle reset-prompt
}

zle -N zle-keymap-select

if [[ -n "${ZSH_PROMPT:-}" ]]; then
    prompt "${ZSH_PROMPT}"
elif [[ $(tput colors) -lt 256 ]]; then
    prompt simple
else
    prompt powerline
fi

# vi: foldmethod=marker
