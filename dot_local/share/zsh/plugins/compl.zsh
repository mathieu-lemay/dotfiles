files=()

for f in "${files[@]}"; do
    [[ -f "$f" ]] && source "$f"
done

if command -v terraform &>/dev/null && [ -z "${_comps[terraform]}" ]; then
    complete -o nospace -C /opt/homebrew/bin/terraform terraform
fi
