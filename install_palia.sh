#!/usr/bin/env bash

# Author:    Madalee
# Purpose:   Launch either the PaliaLauncher for install, or the installed PaliaLauncher
# Arguments: None for now

#curl https://www.opscode.com/chef/install.sh | bash
curl -O https://github/palia_steam_helper.sh
chmod +x palia_steam_helper.sh

encodedUrl="steam://addnonsteamgame/$(python3 -c "import urllib.parse;print(urllib.parse.quote(\"$PWD/palia_steam_helper.sh\", safe=''))")"
touch /tmp/addnonsteamgamefile
xdg-open $encodedUrl
