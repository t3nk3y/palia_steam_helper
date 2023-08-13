#!/usr/bin/env bash

# Author:    Give yourself some credit
# Purpose:   What this script does
# Arguments: What arguments can be passed to the script

INSTALLATION_DIRECTORY=$(pwd)

function download_file() {
  FILE_URL=$1

  FILENAME=$(basename -- "$FILE_URL")
  EXT="${FILENAME##*.}"

  if [[ $EXT == "exe" ]]
  then
    DESTINATION_PATH="$INSTALLATION_DIRECTORY/Palia/Binaries/Win64/$FILENAME"

    curl -L --create-dirs -C - --progress-bar -o $DESTINATION_PATH $FILE_URL
  elif [[ $EXT == "pak" ]]
  then
    DESTINATION_PATH="$INSTALLATION_DIRECTORY/Palia/Content/Paks/$FILENAME"

    #if [ ! -f "$DESTINATION_PATH" ]
    #then
      curl -L --create-dirs -C - --progress-bar -o $DESTINATION_PATH $FILE_URL
    #fi
  fi
}

regex="shadercache/([^/]+)/"
[[ $STEAM_COMPAT_MEDIA_PATH =~ $regex ]]
export SteamAppId=${BASH_REMATCH[1]}



regex="\"URL\": \"([^\"]+)\""
curl -L -s https://update.palia.com/manifest/PatchManifest.json | grep https |
while read in; do
    [[ $in =~ $regex ]]
    download_file ${BASH_REMATCH[1]}
done
