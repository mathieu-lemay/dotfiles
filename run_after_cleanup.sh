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
remove ~/.profile

# vi: ft=sh
