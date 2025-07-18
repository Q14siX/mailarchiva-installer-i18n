GITHUB="https://raw.githubusercontent.com/Q14siX/mailarchiva-installer-i18n/main/"

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
  source <(wget -qO- "${GITHUB}$1")
}

source_local() {
  source $1
}

source_remote "lang/${LANGUAGE}.lang"

echo "Sprache $LANGUAGE"
