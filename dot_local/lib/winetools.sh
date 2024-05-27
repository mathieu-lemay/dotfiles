#!/bin/bash

debug()   { if [[ -n "${WINETOOLS_DEBUG:-}" ]]; then _log "\e[34m[DEBUG]\e[0m  " "$*"; fi }
info()    { _log "\e[32m[INFO]\e[0m   " "$*" ; }
warning() { _log "\e[33m[WARNING]\e[0m" "$*" ; }
error()   { _log "\e[31m[ERROR]\e[0m  " "$*" ; }
fatal()   { _log "\e[35m[FATAL]\e[0m  " "$*"; exit 1 ; }
_log()    {
    local level msg msg_line
    level="${1}"
    shift
    msg="$*"

    if [[ -n "${WINETOOLS_DEBUG:-}" ]]; then
        msg_line="${BASH_SOURCE[0]}:${BASH_LINENO[1]}: "
    else
        msg_line=""
    fi

    printf "%b %s%s\\n" "${level}" "${msg_line}" "${msg}" >&2 ;
}
ensure()  { command -v "$1" &> /dev/null || fatal "Command not found: $1"; }

ROOTDIR="${1:?Root Directory not specified}"
export ROOTDIR
shift

# Wine settings
export WINEPREFIX="${ROOTDIR}/pfx"
export WINEESYNC=1
export WINEFSYNC=1
export WINEARCH=win64
export WINEEXE=wine
export WINEROOT=
export WINEDLLOVERRIDES="mscoree=d;mshtml=d;winemenubuilder.exe=d;"
export WINE_LARGE_ADDRESS_AWARE=1
export WINEDEBUG="-all"
export STAGING_SHARED_MEMORY=1

# dxvk settings
export DXVK_FRAME_RATE=0
export DXVK_LOG_PATH=none
export DXVK_HUD=fps

# Definining tools and regular settings
SUPPORT_DIR="${ROOTDIR}/support"
WINDOWED="${WINDOWED:-0}"
RESOLUTION="${RESOLUTION:-1920x1080}"
GAMEMODERUN_ENABLED=0
MANGOHUD_ENABLED=0
OVERLAYFS_ENABLED=0

# Forbid root rights
if [ -n "${ROOT:-}" ] || [ "$EUID" = "0" ]; then
    fatal "Don't use the sudo command or the root user to execute these scripts!"
fi

print_banner() {
    command -v figlet &> /dev/null || return 0

    echo -en "\e[38;5;$((RANDOM%257))m"
    figlet -c -f slant "$@"
    echo -en "\e[0m"
}

set_wine_root() {
    WINEROOT="${1:?}/bin"

    WINELOADER="${WINEROOT}/${WINEEXE}"
    WINESERVER="${WINEROOT}/wineserver"

    [[ -x "${WINELOADER}" ]] || fatal "Invalid WINEROOT: ${WINEROOT}"
    [[ -x "${WINESERVER}" ]] || fatal "Invalid WINEROOT: ${WINEROOT}"

    debug "Setting WINELOADER to '${WINELOADER}'"
    debug "Setting WINESERVER to '${WINESERVER}'"

    export WINEROOT WINELOADER WINESERVER
}

_get_wine_cmd() {
    cmd="${WINEROOT:-/usr/bin}/${1:?Command not specified}"
    [[ -x "${cmd}" ]] || fatal "Command not found: ${cmd}"

    echo "${cmd}"
}

wine() {
    cmd="$(_get_wine_cmd wine)"
    info "Executing: ${cmd} $*"
    "${cmd}" "$@"
}

wine64() {
    cmd="$(_get_wine_cmd wine64)"
    info "Executing: ${cmd} $*"
    "${cmd}" "$@"
}

wineserver() {
    cmd="$(_get_wine_cmd wineserver)"
    info "Executing: ${cmd} $*"
    "${cmd}" "$@"
}

run_winetricks_cmd() {
    cmd="$1"
    if grep "${cmd}" "${WINEPREFIX}/winetricks.log" &> /dev/null; then
        debug "'${cmd}' already installed, skipping."
        return
    fi

    info "Running winetricks ${cmd}"
    WINE="$(_get_wine_cmd wine)" winetricks -q "${cmd}"
}

install_dxvk() {
    dxvk_version=$(pacman -Qi dxvk-bin 2>/dev/null | awk -F": " '/Version/ {print $2}' | awk -F"-" '{ print $1 }')
    dxvk_version_file="${WINEPREFIX}/.dxvk"

    if [ -f "${dxvk_version_file}" ] && [ "$(cat "${dxvk_version_file}")" = "${dxvk_version}" ]; then
        debug "dxvk ${dxvk_version} already installed, skipping."
        return
    fi

    info "Installing dxvk ${dxvk_version}"
    wine wineboot -i
    wineserver -w
    setup_dxvk install
    echo "${dxvk_version}" > "${dxvk_version_file}"
    wineserver -k
}

install_vkd3d() {
    vkd3d_version="$(curl -s "https://api.github.com/repos/HansKristian-Work/vkd3d-proton/releases/latest" | jq -r ".tag_name" | sed 's/^v//')"
    vkd3d_version_file="${WINEPREFIX}/.vkd3d"

    if [ -f "${vkd3d_version_file}" ] && [ "$(cat "${vkd3d_version_file}")" = "${vkd3d_version}" ]; then
        debug "vkd3d ${vkd3d_version} already installed, skipping."
        return
    fi

    name="vkd3d-proton-${vkd3d_version}"
    archive="${name}.tar.zst"

    if [[ ! -e "${SUPPORT_DIR}/${archive}" ]]; then
        mkdir -p "${SUPPORT_DIR}"
        curl -L -o "${SUPPORT_DIR}/${archive}" \
            "https://github.com/HansKristian-Work/vkd3d-proton/releases/download/v${vkd3d_version}/vkd3d-proton-${vkd3d_version}.tar.zst"
    fi

    info "Installing vkd3d ${vkd3d_version}"
    tar -x -C "${SUPPORT_DIR}" -f "${SUPPORT_DIR}/${archive}"

    bash "${SUPPORT_DIR}/${name}/setup_vkd3d_proton.sh" install
    echo "${vkd3d_version}" > "${vkd3d_version_file}"

    rm -rf "${SUPPORT_DIR}/${name:?}"
}

setup_save_link() {
    source="${ROOTDIR}/save"
    target="${1:?target not specified}"

    if [[ -e "${target}" ]]; then
        if [[ ! -L "${target}" ]]; then
            fatal "save directory exists and is not a link: ${target}"
        elif [[ "$(readlink -f "${target}")" == "${source}" ]]; then
            return 0
        else
            info "Removing bad link: ${target}"
            rm "${target}"
        fi
    fi

    [[ -d "${source}" ]] || mkdir -p "${source}"

    mkdir -p "$(dirname "${target}")"

    ln -sf "${source}" "${target}"
}

mount_overlayfs() {
    info "Mounting overlayfs"
    unmount_overlayfs &> /dev/null

    mkdir -p "${ROOTDIR}"/{game,files/{game,game-rw,fuse-work}}

    # shellcheck disable=SC2140
    fuse-overlayfs \
        -o squash_to_uid="$(id -u "${USER}")" \
        -o squash_to_gid="$(id -g "${USER}")" \
        -o lowerdir="${ROOTDIR}/files/game",upperdir="${ROOTDIR}/files/game-rw",workdir="${ROOTDIR}/files/fuse-work" \
        "${ROOTDIR}/game"
}

unmount_overlayfs() {
    info "Unmounting overlayfs"
    #fuser -k "$PWD/files/groot-mnt";
    fusermount3 -u -z "${ROOTDIR}/game" || true
    rm -rf "${ROOTDIR}/files/fuse-work"
}

start_game() {
    local -a cmd

    if [ "${1:-}" = "-w" ]; then
        WINDOWED=1
        shift
    fi

    if [ "${OVERLAYFS_ENABLED:-0}" -eq 1 ]; then
        ensure fuse-overlayfs
        trap 'unmount_overlayfs' EXIT INT SIGINT SIGTERM
        mount_overlayfs
    fi

    cd "${GAME_FOLDER}" || fatal "Invalid folder: ${GAME_FOLDER}"

    cmd=("$(_get_wine_cmd "${WINEEXE}")")

    if [ "${WINDOWED}" -eq 1 ]; then
        cmd+=("explorer" "/desktop=${GAME_NAME},${RESOLUTION}")
    fi

    if [ "${MANGOHUD_ENABLED:-0}" -eq 1 ]; then
        info "Using mangohud"
        cmd=("mangohud" "${cmd[@]}")
    fi

    if [ "${GAMEMODERUN_ENABLED:-0}" -eq 1 ]; then
        cmd=("gamemoderun" "${cmd[@]}")
    fi

    # Start the game
    cmd+=("${GAME_EXE}" "$@")
    info "${cmd[@]}"
    env "${cmd[@]}"
}

case "${1:-}" in
    "mount")
        mount_overlayfs
        exit 0
        ;;
    "umount")
        unmount_overlayfs
        exit 0
        ;;
    "exec")
        shift
        wine "$@"
        exit 0
        ;;
esac
