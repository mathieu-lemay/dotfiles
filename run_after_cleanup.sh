#! /bin/bash

set -euo pipefail

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-"${HOME}/.config"}"
XDG_STATE_HOME="${XDG_STATE_HOME:-"${HOME}/.local/state"}"

. ~/.local/lib/log.sh

# vi: ft=sh
