#!/usr/bin/env bash

# Author:    Madalee
# Purpose:   This installs the Palia Steam Helper
# Arguments: None for now

if [[ $(pwd)/ = ~/ ]]; then
    zenity --info --title="Install Palia Steam Helper"  --ok-label="Click here to exit" --text="$(cat << EndOfMessage
<big>This script should NOT be run in your home directory, please do it somewhere else.</big>
EndOfMessage
    )"
    exit
fi

curl -L -O https://raw.githubusercontent.com/t3nk3y/palia_steam_helper/main/palia_steam_helper.sh
chmod +x palia_steam_helper.sh

if [ -d "./steam" ]; then
    zenity --info --title="Updating Palia Steam Helper"  --ok-label="Click here to exit" --text="$(cat << EndOfMessage
<big>The Palia Steam Helper has been updated.</big>
EndOfMessage
    )"
else
    encodedUrl="steam://addnonsteamgame/$(python3 -c "import urllib.parse;print(urllib.parse.quote(\""$(pwd)"/palia_steam_helper.sh\", safe=''))")"
    touch /tmp/addnonsteamgamefile
    zenity --info --title="Install Palia Steam Helper"  --ok-label="Click here to proceed" --text="$(cat << EndOfMessage
<big>We are going to try to launch Steam and automatically add Palia for you.</big>

If Steam does start, and displays a window asking you what game you want to add, come back to this window for further instructions.
EndOfMessage
    )"

    xdg-open $encodedUrl >/dev/null 2>&1
    if [ $? != 0 ]; then
        zenity --info --title="Install Palia Steam Helper"  --ok-label="Click here to proceed" --text="$(cat << EndOfMessage
<big>We couldn't launch Steam</big>

- You will need to launch it yourself.
- Once Steam is open, click 'Games' in the menu bar.
- Then click 'Add a Non-Steam Game to My library...'
- Once the 'Add Non-Steam Game' window opens, come back here, and click the button.'
EndOfMessage
        )"
    fi

    zenity --info --title="Install Palia Steam Helper"  --ok-label="Click here to proceed" --text="$(cat << EndOfMessage
In the 'Add Non-Steam Game' window:
- Click the 'Browse...' button, and then select(for copy and paste)

$(pwd)/palia_steam_helper.sh

- Then click the 'Add Selected Programs' button.
- Once you finish the above steps, come back here, and click the button.
EndOfMessage
    )"

    zenity --info --title="Install Palia Steam Helper"  --ok-label="Click here to proceed" --text="$(cat << EndOfMessage
- Now you need to head back to the Steam Library and search for 'palia_steam_helper.sh' in the library search box.
- Right click on 'palia_steam_helper.sh' in Steam, and choose 'Properties...'
- Click in the box that says 'palia_steam_helper.sh' change this text to something friendly, like 'Palia'
  (feel free to copy and paste from this window.)
- Now click on 'Compatability' on the left of the window.
- Enable the 'Force the use of a specific Steam Play compatability tool' checkbox
- Be sure the dropdown menu below the checkbox says 'Proton Experimental' if it doesn't you need to click on it to switch to 'Proton Experimental'
- You can close the Properties window in Steam, then come back here, and click the button.
EndOfMessage
    )"
    zenity --info --title="Install Palia Steam Helper"  --ok-label="Click here to exit" --text="$(cat << EndOfMessage
- You can close this window and the terminal
- Then head back to Steam, select Palia, click play, and continue from there.
EndOfMessage
    )"
    exit
fi
