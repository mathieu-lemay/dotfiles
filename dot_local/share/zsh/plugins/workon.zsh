__WORKON_BASE_DIR="${HOME}/src"
__WORKON_LIST_FILE="${XDG_CONFIG_HOME}/workon/list"

__workon_cd() {
    BUFFER="builtin cd -- ${(q)1}"
    zle accept-line
    zle reset-prompt
}

__workon_err() {
    echo "\n$@" >&2
    zle redisplay
}

__workon_add() {
    [[ $# -eq 0 ]] && { echo "Error: No directories specified" >&2; return 1; }

    [[ -e "${__WORKON_LIST_FILE}" ]] || install -D /dev/null "${__WORKON_LIST_FILE}"

    for d in "$@"; do
        d="$(readlink -f "$d")"
        if [[ "$d" =~ "^${__WORKON_BASE_DIR}" ]]; then
            if ! grep -qE "^${d}$" "${__WORKON_LIST_FILE}"; then
                echo "$d" >> "${__WORKON_LIST_FILE}"
            fi
        else
            echo "error: $d is not a subdirectory of ${__WORKON_BASE_DIR}"
        fi
    done
}

function __workon() {
    local workondir q prj
    local -a searchdirs

    if [[ ! -e "${__WORKON_LIST_FILE}" ]]; then
        __workon_err "List file not found"
        return 3
    fi

    q="${BUFFER}"

    if [[ -n "${q}" ]] && [[ -d "${__WORKON_BASE_DIR}/${q}" ]]; then
        __workon_cd "${__WORKON_BASE_DIR}/${q}"
        return 0
    fi

    searchdirs=$(cat "${__WORKON_LIST_FILE}")
    prj=$(find "${=searchdirs}" -maxdepth 1 -mindepth 1 -type d -print \
        | sed "s@^${__WORKON_BASE_DIR}/@@" \
        | sort \
        | $(__fzfcmd) -q "${BUFFER:-}")

    if [[ -z "${prj}" ]]; then
        __workon_err "No project selected"
        return 2
    fi

    workondir="${__WORKON_BASE_DIR}/${prj}"
    if [[ ! -d "${workondir}" ]]; then
        __workon_err "Invalid environment: ${prj}"
        return 1
    fi

    __workon_cd "${workondir}"
}

w() {
    local cmd="${1:-}"
    [[ $# -ge 1 ]] && shift

    case "${cmd}" in
        a | add)
            __workon_add "$@"
            ;;
        l | ls | list)
            if [[ ! -e "${__WORKON_LIST_FILE}" ]]; then
                echo "error: List file not found" >&2
                return 1
            fi
            cat "${__WORKON_LIST_FILE}"
            ;;
        e | ed | edit)
            if [[ ! -e "${__WORKON_LIST_FILE}" ]]; then
                echo "error: List file not found" >&2
                return 1
            fi
            $EDITOR "${__WORKON_LIST_FILE}"
            ;;
        *)
            echo "Usage $0 <a|l|e>" >&2
            return 1
            ;;
    esac
}

zle     -N             __workon
bindkey -M emacs '^ '  __workon
bindkey -M vicmd '^ '  __workon
bindkey -M viins '^ '  __workon

# vim: ft=zsh
