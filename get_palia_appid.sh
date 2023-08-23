#!/usr/bin/env bash

# Author:    Give yourself some credit
# Purpose:   What this script does
# Arguments: What arguments can be passed to the script


SHORTCUTS="/home/agotenshi/.steam/steam/userdata/64462332/config/shortcuts.vdf"

function cleanup {
  rm -r $ramtmp
  rm -r $ramshorts
}

trap cleanup EXIT

((skip=0)) # read bytes at this offset
((count=1024)) # read bytes at this offset
ramtmp="$(mktemp -p /dev/shm/)"
ramshorts="$(mktemp -p /dev/shm/)"
cp $SHORTCUTS $ramshorts
fsize=$(wc -c < "$ramshorts")
while [ $skip -le $fsize ] ; do
  dd if=$ramshorts bs=1 skip=$skip count=$count of=$ramtmp 2>/dev/null
  pos=$(cat $ramtmp | grep -aob P | head -n1 | grep -oE '[0-9]+')
  if [ $? -eq 0 ]; then
    ((pos=pos+skip))
    ((apos=pos-9))
    dd if=$ramshorts bs=1 skip=$apos count=20 of=$ramtmp 2>/dev/null
    cat $ramtmp | grep -aobP 'AppName\x00PaliaSTL' > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        ((apos=apos-4))
        dd if=$ramshorts bs=1 skip=$apos count=4 2>/dev/null | od -tu8 | head -n1 | grep -oE '[0-9]+' | tail -n1
        exit 0
    fi
    ((skip=pos+1))
  else
    ((skip=skip+count))
  fi
done


#XDG_CONFIG_HOME=$(pwd)/.config XDG_CACHE_HOME=$(pwd)/.cache XDG_DATA_HOME=$(pwd)/.local/share ./steamtinkerlaunch addnonsteamgame -ep="/home/agotenshi/temp/stl/steamtinkerlaunch-12.12/palia_steam_helper.sh" -an=PaliaSTL -ip="/home/agotenshi/temp/stl/steamtinkerlaunch-12.12/palia.png" -ao=1

#./steamtinkerlaunch sga 3739948084 --hero=/home/agotenshi/temp/stl/steamtinkerlaunch-12.12/images/palia-hero.png --logo=/home/agotenshi/temp/stl/steamtinkerlaunch-12.12/images/palia-logo.png --boxart=/home/agotenshi/temp/stl/steamtinkerlaunch-12.12/images/palia-boxart.png --tenfoot=/home/agotenshi/temp/stl/steamtinkerlaunch-12.12/images/palia-tenfoot.png

FSCV="$STUIDPATH/config/$SCVDF"
SCSRC="$STUIDPATH/config/$SCVDF"
STUIDPATH="$SUSDA/$STEAMUSERID"