_antidote_dir="${HOME}/.local/share/antidote"

[[ -e "${_antidote_dir}" ]] || return

_antidote_init_script="${_antidote_dir}/antidote/antidote.zsh"
_antidote_plugins_file="${_antidote_dir}/plugins.txt"
_antidote_bundle_file="${_antidote_dir}/plugins.zsh"

if [[ ! -e "${_antidote_bundle_file}" ]] || [[ "${_antidote_plugins_file}" -nt "${_antidote_bundle_file}" ]]; then
    source "${_antidote_init_script}"
    antidote bundle <"${_antidote_plugins_file}" >"${_antidote_bundle_file}"
fi

source "${_antidote_bundle_file}"

unset _antidote_dir _antidote_plugins_file _antidote_bundle_file

# Lazy load the full plugin
function antidote() {
    source "${_antidote_init_script}"
    unset _antidote_init_script

    antidote "$@"
}

# Plugin configuration {{{

# fast-syntax-highlighting {{{

typeset -gA FAST_HIGHLIGHT
FAST_HIGHLIGHT[git-cmsg-len]=80

# }}}

# }}}

# vim: foldmethod=marker
