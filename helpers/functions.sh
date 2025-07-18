clear

USER="Q14siX"
REPO="mailarchiva-installer-i18n"
GITHUB_RAW="https://raw.githubusercontent.com/$USER/$REPO/main/"
GITHUB_API="https://api.github.com/repos/$USER/$REPO/releases/latest"
MAILARCHIVA_RSS_URL="https://bs.stimulussoft.com/rss/product/maonprem"

get_mailarchiver_download_url() {
	FEED=$(wget -q -O - "$MAILARCHIVA_RSS_URL")
	LATEST_LINK=$(echo "$FEED" | awk '/<item>/,/<\/item>/{print}' | grep -oP '(?<=<link>)[^<]+' | head -n 1)
	
	if [ -z "$LATEST_LINK" ]; then
		echo "Fehler: Link der neuesten Version nicht gefunden."
		exit 1
	fi
 
	JSON=$(wget -q -O - "$LATEST_LINK")
	
	if [ -z "$JSON" ]; then
		echo "Fehler: Keine Daten vom Link erhalten."
		exit 1
	fi
	
	DOWNLOAD_URL=$(echo "$JSON" | jq -r '.distributions[] | select(.operatingSystem=="LINUX") | .downloadUrl')
		
	if [ -z "$DOWNLOAD_URL" ]; then
		echo "Fehler: Keine Linux-Download-URL gefunden."
		exit 1
	fi
	
	echo "$DOWNLOAD_URL"
}

get_system_language() {
  local lang="${LC_ALL:-${LC_MESSAGES:-$LANG}}"
  lang="${lang%%[_\.]*}"
  [[ "$lang" == "de" ]] && LANGUAGE="de" || LANGUAGE="en"
}

add_trailing_slash() {
  case "$1" in
    */) echo "$1" ;;
    *)  echo "$1/" ;;
  esac
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
echo "MailAchiver: $(get_mailarchiver_download_url)"
