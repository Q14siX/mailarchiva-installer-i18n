USER="Q14siX"
REPO="mailarchiva-installer-i18n"
GITHUB_RAW="https://raw.githubusercontent.com/$USER/$REPO/main/"
GITHUB_API="https://api.github.com/repos/$USER/$REPO/releases/latest"

get_system_language() {
  local lang="${LC_ALL:-${LC_MESSAGES:-$LANG}}"
  lang="${lang%%[_\.]*}"
  [[ "$lang" == "de" ]] && LANGUAGE="de" || LANGUAGE="en"
}

add_trailing_slash() {
  case "$1" in
    */) echo "$1" ;;
    *)  echo "$1/" ;;
}

source_remote() {
  source <(wget -qO- "${GITHUB_RAW}$1")
}

source_local() {
  source $1
}

get_github_info() {
  local field="$1"
  local json value
  
  json=$(wget -qO- "$GITHUB_API")
  value=$(echo "$json" | grep -Po "\"$field\":\s*\"\K.*?(?=\")")

  echo "$value"
}

get_system_language
source_remote "lang/${LANGUAGE}.lang"

echo "Sprache: $LANGUAGE"
echo "Version: $(get_github_info tag_name)"
echo "Name: $(get_github_info name)"
