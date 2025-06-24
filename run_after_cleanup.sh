#! /bin/bash

set -euo pipefail

. ~/.local/lib/log.sh

remove() {
    local path
    path="${1:?}"

    [[ -e "${path}" ]] || return 0
    info "Removing ${path}"
    rm -rf "${path}"
}

remove ~/.local/share/zsh/plugins/bash_compl.zsh
remove ~/.local/share/zsh-antidote
remove ~/.local/state/zsh/zcompdump
remove ~/.config/pipewire/pipewire.conf.d/clock-rate.conf
remove ~/.config/pipewire/pipewire.conf.d/quantum.conf

# vi: ft=sh
