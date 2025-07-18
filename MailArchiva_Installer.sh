#!/bin/bash

GITHUB_RAW="https://raw.githubusercontent.com/Q14siX/mailarchiva-installer-i18n/main/"

source <(wget -qO- "${GITHUB_RAW}helpers/functions.sh")

get_system_language
source_remote "lang/${LANGUAGE}.lang"

echo "Sprache: $LANGUAGE"
echo "Version: $(get_github_info tag_name)"
echo "Name: $(get_github_info name)"
