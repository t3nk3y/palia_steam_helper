#!/usr/bin/env bash

# Author:    Madalee based on work by ColtenP
# Purpose:   This will grab/extract the Palia game files and updates
#            It's intended to run on Mac OS without any additional
#            dependencies, but may work on other Linux environments.

INSTALLATION_DIRECTORY=$(pwd)

function download_file() {
  FILE_URL="$1"

  FILENAME=$(basename -- "$FILE_URL")
  EXT="${FILENAME##*.}"

  if [[ $EXT == "zip" ]]; then
    DESTINATION_PATH="$INSTALLATION_DIRECTORY/Client"
    if [[ ! -f "$DESTINATION_PATH/Build.version" ]]; then
      echo "Build.version is missing, so we are going to download the base zip now..."
      echo "This will take a long time, but you can restart if things get interrupted."
      echo ""
      echo ""
      curl -L -C - -o "$FILENAME" "$FILE_URL"
      echo ""
      echo ""
    fi

    if [[ -f "$FILENAME" ]]; then
      echo "Unzipping base Palia game files, this will take a long time, standby..."
      unzip -o -d "$DESTINATION_PATH" -u "$FILENAME"
      echo "Done unzipping base game files..."
      echo ""
      echo ""
    fi
  elif [[ $EXT == "exe" ]]; then
    echo "Checking/downloading $FILENAME..."
    DESTINATION_PATH="$INSTALLATION_DIRECTORY/Client/Palia/Binaries/Win64/$FILENAME"

    curl -L --create-dirs -C - --retry 5 --retry-max-time 120 --progress-bar -o "$DESTINATION_PATH" "$FILE_URL"
  elif [[ $EXT == "pak" ]]; then
    echo "Checking/downloading $FILENAME..."
    DESTINATION_PATH="$INSTALLATION_DIRECTORY/Client/Palia/Content/Paks/$FILENAME"

    #if [[ ! -f "$DESTINATION_PATH" ]]; #then
      curl -L --create-dirs -C - --retry 5 --retry-max-time 120 --progress-bar -o "$DESTINATION_PATH" "$FILE_URL"
    #fi
  fi
}

echo Grabbing and processing manifest...
echo ""
echo ""
regex="\"URL\": \"([^\"]+)\""
curl -L -s https://update.palia.com/manifest/PatchManifest.json | grep https |
while read in; do
    [[ $in =~ $regex ]]
    download_file ${BASH_REMATCH[1]}
done
echo ""
echo ""
echo "All done..."
