#!/bin/bash
clear

INSTALLER_VERSION="BETA 20250718_1049"
INSTALLER_NAME="🇩🇪 MailArchiva Installer mit i18n - Version $INSTALLER_VERSION / 🇬🇧 MailArchiva Installer with i18n - Version $INSTALLER_VERSION"

USER="Q14siX"
REPO="mailarchiva-installer-i18n"
GITHUB_RAW="https://raw.githubusercontent.com/$USER/$REPO/main/"
GITHUB_API="https://api.github.com/repos/$USER/$REPO/releases/latest"
MAILARCHIVA_RSS_URL="https://bs.stimulussoft.com/rss/product/maonprem"

get_mailarchiva_download_info() {
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

	MAILARCHIVA_VERSION=$(echo "$JSON" | jq -r '.version')
	if [ -z "$MAILARCHIVA_VERSION" ] || [ "$MAILARCHIVA_VERSION" == "null" ]; then
		echo "Fehler: Version nicht gefunden."
		exit 1
	fi

	MAILARCHIVA_DOWNLOAD_URL=$(echo "$JSON" | jq -r '.distributions[] | select(.operatingSystem=="LINUX") | .downloadUrl')
	if [ -z "$MAILARCHIVA_DOWNLOAD_URL" ] || [ "$MAILARCHIVA_DOWNLOAD_URL" == "null" ]; then
		echo "Fehler: Keine Linux-Download-URL gefunden."
		exit 1
	fi
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

	if [[ -n "$value" ]]; then
		echo "$value"
	else
		if [[ "$field" == "tag_name" ]]; then
			echo "$INSTALLER_VERSION"
		elif [[ "$field" == "name" ]]; then
			echo "$INSTALLER_NAME"
   		else
     			echo ""
		fi
	fi
}

input() {
	stty sane
 	read -p "$1" INPUT_VALUE
  	echo "$INPUT_VALUE"
 	stty -echo -icanon time 0 min 0
}

stty -echo -icanon time 0 min 0
trap 'stty sane' EXIT

get_system_language
source_remote "lang/${LANGUAGE}.lang"

echo "$MSG_WELCOME - $MSG_VERSION $(get_github_info tag_name)"
echo "$MSG_LANGUAGE $LANGUAGE"
echo "$MSG_NAME $(get_github_info name)"

get_mailarchiva_download_info
echo "$MSG_MAILARCHIVA_VERSION $MAILARCHIVA_VERSION"
echo "$MSG_MAILARCHIVA_DOWNLOAD_URL $MAILARCHIVA_DOWNLOAD_URL"

antwort=$(input "Bitte Ihren Namen eingeben: ")
echo "Der Benutzer heißt: $antwort"
