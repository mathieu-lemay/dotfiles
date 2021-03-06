# Set default terminal
export TERMINAL="kitty"

# Get proper date format
export LC_TIME="en_DK.UTF-8"

# Respect XDG Base Directory spec
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"

export AWS_CONFIG_FILE="${XDG_CONFIG_HOME}/aws/config"
export AWS_SHARED_CREDENTIALS_FILE="${XDG_CONFIG_HOME}/aws/credentials"
export DOCKER_CONFIG="${XDG_CONFIG_HOME}/docker"
export JFROG_CLI_HOME_DIR="${XDG_DATA_HOME}/jfrog"
export POETRY_HOME="${XDG_DATA_HOME}/poetry"
export PYENV_ROOT="${XDG_DATA_HOME}/pyenv"
export PIPX_HOME="${XDG_DATA_HOME}/pipx"
export PIPX_BIN_DIR="${PIPX_HOME}/bin"
export VAGRANT_HOME="${XDG_DATA_HOME}/vagrant"
export CARGO_HOME="${XDG_DATA_HOME}/cargo"
export RUSTUP_HOME="${XDG_DATA_HOME}/rustup"
export GOPATH="${XDG_DATA_HOME}/go"

# Set JRE for JetBrains products
JETBRAINS_JRE="/usr/lib/jvm/jre-jetbrains"
if [ -d "$JETBRAINS_JRE" ]; then
    export IDEA_JDK="${JETBRAINS_JRE}"
    export CLION_JDK="${JETBRAINS_JRE}"
    export DATAGRIP_JDK="${JETBRAINS_JRE}"
    export PYCHARM_JDK="${JETBRAINS_JRE}"
    export STUDIO_JDK="${JETBRAINS_JRE}"
fi

# Personal usr folder
if [[ -d "${HOME}/usr/bin" ]] && [[ ":${PATH}:" != *":${HOME}/usr/bin:"* ]]; then
    export PATH="${HOME}/usr/bin:${PATH}"
fi
if [[ -d "${HOME}/usr/lib" ]] && [[ ":${LD_LIBRARY_PATH}:" != *":${HOME}/usr/lib:"* ]]; then
    export LD_LIBRARY_PATH="${HOME}/usr/lib:${LD_LIBRARY_PATH}"
fi
if [[ -d "${HOME}/usr/lib/pkgconfig" ]] && [[ ":${PKG_CONFIG_PATH}:" != *":${HOME}/usr/lib/pkgconfig:"* ]]; then
    export PKG_CONFIG_PATH="${HOME}/usr/lib/pkgconfig:${PKG_CONFIG_PATH}"
fi

# Extra PATH
paths=(
    "${CARGO_HOME}/bin"
    "${GOPATH}/bin"
    "${POETRY_HOME}/bin"
    "${PIPX_BIN_DIR}"
)
for p in ${paths}; do
    if [[ -d "${p}" ]] && [[ ":${PATH}:" != *":${p}:"* ]]; then
        export PATH="${p}:${PATH}"
    fi
done
unset paths

# Prevent Wine from taking over file associations
# https://wiki.archlinux.org/index.php/wine#Prevent_new_Wine_file_associations
export WINEDLLOVERRIDES="winemenubuilder.exe=d"

# vim: ft=sh
