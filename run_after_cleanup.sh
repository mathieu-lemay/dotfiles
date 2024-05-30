#! /bin/bash

set -euo pipefail

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-"${HOME}/.config"}"
XDG_STATE_HOME="${XDG_STATE_HOME:-"${HOME}/.local/state"}"

. ~/.local/lib/log.sh

update_zsh_history_location() {
    local src dst temp
    src="${XDG_CONFIG_HOME}/zsh/history"
    dst="${XDG_STATE_HOME}/zsh/history"

    [[ -e "${src}" ]] || return 0

    temp="$(mktemp)"

    info "Moving ${src} -> ${dst}"

    mv "${src}" "${temp}"

    [[ -e "${dst}" ]] && cat "${dst}" >> "${temp}"

    mv "${temp}" "${dst}"
    chmod 600 "${dst}"
}

update_neovim_undo_location() {
    local src1 src2 dst
    src1="${XDG_CONFIG_HOME}/nvim/undo"
    src2="${HOME}/.vim/undo"
    dst="${XDG_STATE_HOME}/nvim/undo"

    if [[ ! -e "${src1}" ]] && [[ ! -e "${src2}" ]]; then
        return 0
    fi

    mkdir -p "${dst}"

    files=$(shopt -s nullglob dotglob; echo "${src1}"/*)
    if (( ${#files} )); then
        info "Moving ${src1} -> ${dst}"
        mv "${src1}"/* "${dst}"
    fi
    [[ -d "${src1}" ]] && rmdir "${src1}"

    files=$(shopt -s nullglob dotglob; echo "${src2}"/*)
    if (( ${#files} )); then
        info "Moving ${src2} -> ${dst}"
        mv "${src2}"/* "${dst}"
    fi
    [[ -d "${src2}" ]] && rmdir "${src2}"
}

remove() {
    local path
    path="${1:?}"

    [[ -e "${path}" ]] || return 0
    info "Removing ${path}"
    rm -rf "${path}"
}

update_zsh_history_location
update_neovim_undo_location
remove "${XDG_CONFIG_HOME}/zsh/.zcompdump"
remove "${HOME}/.tmux.zsh"
remove "${HOME}/.inputrc"
remove "${HOME}/.ideavimrc"
remove "${HOME}/.config/zsh/local"
remove "${HOME}/.local/share/zsh/plugins/ssh.zsh"

if command -v pyenv &> /dev/null; then
    remove "$(pyenv root)/plugins/xxenv-latest"
fi

# vi: ft=sh
