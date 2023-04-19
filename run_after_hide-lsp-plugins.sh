#! /bin/bash
set -eu

LOCAL_APPLICATIONS_DIR="${HOME}/.local/share/applications"

if [ ! -d "${LOCAL_APPLICATIONS_DIR}" ]; then
    mkdir -p "${LOCAL_APPLICATIONS_DIR}"
fi

find "${LOCAL_APPLICATIONS_DIR}" -name '*lsp_plug*.desktop' -delete

while IFS= read -r -d '' file
do
    target="${LOCAL_APPLICATIONS_DIR}/$(basename "${file}")"
    cat << EOF > "${target}"
[Desktop Entry]
Hidden=true
EOF
done <   <(find /usr/share/applications -name '*lsp_plug*.desktop' -print0)
