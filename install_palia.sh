#!/usr/bin/env bash

# Author:    Madalee
# Thanks:	 Authors of SteamTinkerLinker, BoilR, Steam ROM Manager, and especially ValvePython-vdf
# Purpose:   This installs the Palia Steam Helper
# Arguments: None for now

function cleanup {
	rm -rf $ramtmp
	rm -rf $ramshorts
	rm -rf $TOOLS

	if [ ! -z "$steamcmd" ]; then
		steampid=$(ps aux | grep "/steam\( [^/]*\$\|\$\)" | awk '{print $2}')
		if [ -z "$steampid" ]; then
			if [ "$steamcmd" == *"com.valvesoftware.Steam"* ]; then
				nohup flatpak run com.valvesoftware.Steam >/dev/null 2>&1 & disown
			else
				nohup $steamcmd >/dev/null 2>&1 & disown
			fi
		fi
	fi
}

trap cleanup EXIT

PROGNAME="palia_installer"
PALIA_TITLE="Palia"
STLPFX="XDG_CONFIG_HOME=$(pwd)/.config"
TOOLSDIR="tools"
TOOLS="$(pwd)/$TOOLSDIR"
COMPATTOOLS="compat_tools.py"
VKEYVALPATH="valve_keyvalues_python"
VKEYVALS="$VKEYVALPATH/keyvalues.py"
COMPATTOOL="$TOOLS/$COMPATTOOLS"
LOGFILE="install_palia.log"

USDA="userdata"
SCVDF="shortcuts.vdf"
COCOV="config/config.vdf"
LCV="localconfig.vdf"
SCV="sharedconfig.vdf"
SRSCV="7/remote/$SCV"

IMGS="$(pwd)/images"
IMG_ICON=palia-icon.png
IMG_LOGO=palia-logo.png
IMG_HERO=palia-hero.png
IMG_BOXART=palia-boxart.png
IMG_TENFOOT=palia-tenfoot.png
IMG_SQUARE=palia-square.png
PSH_REPO=https://raw.githubusercontent.com/t3nk3y/palia_steam_helper/main
PSH_SCRIPT=palia_steam_helper.sh
KNOWN_HASH_FILE=known-hashes.json
COMPATTOOLSURL="$PSH_REPO/$TOOLSDIR/$COMPATTOOLS"
VKEYVALSURL="$PSH_REPO/$TOOLSDIR/$VKEYVALS"

function writelog {
	echo $@ >> "$LOGFILE"
	if [ $1 = "MSG" ]; then
		echo $@
	fi
}

function setSteamPath {
	HSR="$HOME/.steam/root"
	HSS="$HOME/.steam/steam"

	if [ -z "${!1}" ]; then
		if [ -e "${HSR}/${2}" ]; then
			# readlink might be better in both STPAs here to be distribution independant, possible side effects not tested!
			STPA="$(readlink -f "${HSR}/${2}")"
			export "$1"="$STPA"
			writelog "INFO" "${FUNCNAME[0]} - Set '$1' to '$STPA'"
		elif [ -e "${HSS}/${2}" ]; then
			STPA="$(readlink -f "${HSS}/${2}")"
			export "$1"="$STPA"
			writelog "INFO" "${FUNCNAME[0]} - Set '$1' to '$STPA'"
		else
		 	writelog "WARN" "${FUNCNAME[0]} - '$2' not found for variable '$1' in '$HSR' or '$HSS'!"
		fi	
	else
	 	writelog "SKIP" "${FUNCNAME[0]} - '$1' already defined as '${!1}'"
	fi
}

function setSteamPaths {
	setSteamPath "SROOT"
	setSteamPath "SUSDA" "$USDA"
	setSteamPath "CFGVDF" "$COCOV"

	if [ -d "$SUSDA" ]; then
	# this works for 99% of all users, because most do have 1 steamuser on their system
		#export STUIDPATH="$(find "$SUSDA" -maxdepth 1 -type d -name "[1-9]*" | head -n1)"
		#testing to using this to find the most recent user to make file modifications, likely the most recently logged in user
		export STUIDPATH=$(find "$SUSDA" -maxdepth 3 -type f -name "$LCV" -printf "%T@ %p\n" | sort -k 1nr | head -n1 | cut -d' ' -f2 | sed -n 's/\(.\+\/userdata\/[1-9]*\).\+/\1/p')
		export STEAMUSERID="${STUIDPATH##*/}"
	else
			writelog "WARN" "${FUNCNAME[0]} - Steam '$USDA' directory not found, other variables depend on it - Expect problems" "E"
	fi

	export FSCV="$STUIDPATH/config/$SCVDF"
	export SUIC="$STUIDPATH/config"
	export FLCV="$SUIC/$LCV"

	writelog "INFO" "${FUNCNAME[0]} - Found SteamUserId '$STEAMUSERID'"
}

function addNonSteamGame {
	if [ -z "$SUSDA" ] || [ -z "$STUIDPATH" ]; then
		setSteamPaths
	fi
	SCPATH="$STUIDPATH/config/$SCVDF"

	function getCRC {
		echo -n "$1" | gzip -c | tail -c 8 | od -An -N 4 -tx4
	}

	function dec2hex {
		 printf '%x\n' "$1"
	}

	function hex2dec {
		printf "%d\n" "0x${1#0x}"
	}

	function splitTags {
		mapfile -d "," -t -O "${#TAGARR[@]}" TAGARR < <(printf '%s' "$1")
		for i in "${!TAGARR[@]}"; do
			if grep -q "${TAGARR[$i]}" <<< "$(getActiveSteamCollections)"; then
				printf '\x01%s\x00%s\x00' "$i" "${TAGARR[i]}"
			fi
		done
	}

	NOSTHIDE=0
	NOSTADC=1
	NOSTAO=1
	NOSTVR=0
	NOSTSTLLO=0

	for i in "$@"; do
		case $i in
			-an=*|--appname=*)
				NOSTAPPNAME="${i#*=}"
				shift ;;
			-ep=*|--exepath=*)
				QEP="${i#*=}"; NOSTEXEPATH="\"$QEP\""
				shift ;;
			-sd=*|--startdir=*)
				QSD="${i#*=}"; NOSTSTDIR="\"$QSD\""
				shift ;;
			-ip=*|--iconpath=*)
				NOSTICONPATH="${i#*=}"
				shift ;;
			-lo=*|--launchoptions=*)
				NOSTLAOP="${i#*=}"
				shift ;;
			-hd=*|--hide=*)
				NOSTHIDE="${i#*=}"
				shift ;;
			-adc=*|--allowdesktopconf=*)
				NOSTADC="${i#*=}"
				shift ;;
			-ao=*|--allowoverlay=*)
				NOSTAO="${i#*=}"
				shift ;;
			-vr=*|--openvr=*)
				NOSTVR="${i#*=}"
				shift ;;
			-t=*|--tags=*)
				NOSTTAGS="${i#*=}"
				shift ;;
			-stllo=*|--stllaunchoption=*)
				NOSTSTLLO="${i#*=}"
				shift ;;
			*) ;;
		esac
	done

	if [ -n "${NOSTEXEPATH}" ]; then
		if [ -z "${NOSTAPPNAME}" ]; then
			NOSTAPPNAME="${QEP##*/}"
		fi

		if [ -z "${NOSTSTDIR}" ]; then
			QSD="$(dirname "$QEP")"; NOSTSTDIR="\"$QSD\""
		fi

		if [ "$NOSTSTLLO" -eq 1 ]; then
			NOSTGICONPATH="$STLICON"
		fi

		APPKEY="$NOSTEXEPATH$NOSTAPPNAME"
		APPKEYCRC=$(printf "0x%s" $(getCRC "$APPKEY"))
		topAppId=$(( ${APPKEYCRC} | 0x80000000 ))
		longAppId=$(printf '%u' $(((topAppId<<32)|0x02000000)))
		shortAppIdHex=$(printf '%x' $longAppId)
		shortAppIdHex=$(printf '%x' 0x${shortAppIdHex:0:8})
		shortAppId=$(printf '%u' 0x$shortAppIdHex)
		shortAppIdBinHex="$(echo ${shortAppIdHex:6:2}${shortAppIdHex:4:2}${shortAppIdHex:2:2}${shortAppIdHex:0:2})"
		shortAppIdBinHex="\x$(awk '{$1=$1}1' FPAT='.{2}' OFS="\\\x" <<< $shortAppIdBinHex)"
		shortCutAppIdHex=$(printf '%x' $(( ($longAppId>>32) - 0x100000000 )) )
		shortCutAppIdHex=$(printf '%x' 0x${shortCutAppIdHex:8:8})
		shortCutAppId=$(printf '%u' 0x$shortCutAppIdHex)
		shortCutAppIdBinHex="$(echo ${shortCutAppIdHex:6:2}${shortCutAppIdHex:4:2}${shortCutAppIdHex:2:2}${shortCutAppIdHex:0:2})"
		shortCutAppIdBinHex="\x$(awk '{$1=$1}1' FPAT='.{2}' OFS="\\\x" <<< $shortCutAppIdBinHex)"

		writelog "INFO" "${FUNCNAME[0]} - === Adding new $NSGA ==="
		writelog "INFO" "${FUNCNAME[0]} - AppID: '${longAppId}'"
		writelog "INFO" "${FUNCNAME[0]} - AppIDHex: '$(printf '%x' $longAppId)'"
		writelog "INFO" "${FUNCNAME[0]} - ShortAppID: '${shortAppId}'"
		writelog "INFO" "${FUNCNAME[0]} - ShortAppIDHex: '$(printf '%s' $shortAppIdHex)'"
		writelog "INFO" "${FUNCNAME[0]} - ShortAppIDBinHex: '$(printf '%s' $shortAppIdBinHex)'"
		writelog "INFO" "${FUNCNAME[0]} - ShortCutAppID: '${shortCutAppId}'"
		writelog "INFO" "${FUNCNAME[0]} - ShortCutAppIDHex: '$(printf '%x' $shortCutAppId)'"
		writelog "INFO" "${FUNCNAME[0]} - ShortCutAppIDBinHex: '$(printf '%s' $shortCutAppIdBinHex)'"
		writelog "INFO" "${FUNCNAME[0]} - App Name: '${NOSTAPPNAME}'"
		writelog "INFO" "${FUNCNAME[0]} - Exe Path: '${NOSTEXEPATH}'"
		writelog "INFO" "${FUNCNAME[0]} - Start Dir: '${NOSTSTDIR}'"
		writelog "INFO" "${FUNCNAME[0]} - Icon Path: '${NOSTICONPATH}'"
		writelog "INFO" "${FUNCNAME[0]} - Launch options: '${NOSTLAOP}'"
		writelog "INFO" "${FUNCNAME[0]} - Is Hidden: '${NOSTHIDE}'"
		writelog "INFO" "${FUNCNAME[0]} - Allow Desktop Config: '${NOSTADC}'"
		writelog "INFO" "${FUNCNAME[0]} - Allow Overlay: '${NOSTAO}'"
		writelog "INFO" "${FUNCNAME[0]} - OpenVR: '${NOSTVR}'"
		writelog "INFO" "${FUNCNAME[0]} - Tags: '${NOSTTAGS}'"

		if [ -f "$SCPATH" ]; then
			writelog "INFO" "${FUNCNAME[0]} - The file '$SCPATH' already exists, creating a backup, then removing the 2 closing backslashes at the end"
			cp "$SCPATH" "${SCPATH//.vdf}_${PROGNAME}_backup.vdf" 2>/dev/null
			truncate -s-2 "$SCPATH"
			OLDSET="$(grep -aPo '\x00[0-9]\x00\x02appid' "$SCPATH" | tail -n1 | tr -dc '0-9')"
			NEWSET=$((OLDSET + 1))
			writelog "INFO" "${FUNCNAME[0]} - Last set in file has ID '$OLDSET', so continuing with '$OLDSET'"
		else
			writelog "INFO" "${FUNCNAME[0]} - Creating new $SCPATH"
			printf '\x00%s\x00' "shortcuts" > "$SCPATH"
			NEWSET=0
		fi

		writelog "INFO" "${FUNCNAME[0]} - Adding new set '$NEWSET'"

		{
		printf '\x00%s\x00' "$NEWSET"
		printf '\x02%s\x00%b' "appid" "$shortAppIdBinHex"
		printf '\x01%s\x00%s\x00' "appname" "$NOSTAPPNAME"
		printf '\x01%s\x00%s\x00' "Exe" "$NOSTEXEPATH"
		printf '\x01%s\x00%s\x00' "StartDir" "$NOSTSTDIR"

		if [ -n "$NOSTICONPATH" ]; then
			printf '\x01%s\x00%s\x00' "icon" "$NOSTICONPATH"
		else
			printf '\x01%s\x00\x00' "icon"
		fi

		printf '\x01%s\x00\x00' "ShortcutPath"

		if [ -n "$NOSTLAOP" ]; then
			printf '\x01%s\x00%s\x00' "LaunchOptions" "$NOSTLAOP"
		else
			printf '\x01%s\x00\x00' "LaunchOptions"
		fi
		
		if [ "$NOSTHIDE" -eq 1 ]; then
			printf '\x02%s\x00\x01\x00\x00\x00' "IsHidden"
		else
			printf '\x02%s\x00\x00\x00\x00\x00' "IsHidden"
		fi

		if [ "$NOSTADC" -eq 1 ]; then
			printf '\x02%s\x00\x01\x00\x00\x00' "AllowDesktopConfig"
		else
			printf '\x02%s\x00\x00\x00\x00\x00' "AllowDesktopConfig"
		fi

		if [ "$NOSTAO" -eq 1 ]; then
			printf '\x02%s\x00\x01\x00\x00\x00' "AllowOverlay"
		else
			printf '\x02%s\x00\x00\x00\x00\x00' "AllowOverlay"
		fi

		if [ "$NOSTVR" -eq 1 ]; then
			printf '\x02%s\x00\x01\x00\x00\x00' "openvr"
		else
			printf '\x02%s\x00\x00\x00\x00\x00' "openvr"
		fi

		printf '\x02%s\x00\x00\x00\x00\x00' "Devkit"
		printf '\x01%s\x00\x00' "DevkitGameID"

		printf '\x02%s\x00\x00\x00\x00\x00' "LastPlayTime"
		printf '\x00%s\x00' "tags"
		splitTags "$NOSTTAGS"
		printf '\x08'
		printf '\x08'

		#file end:
		printf '\x08'
		printf '\x08'
		} >> "$SCPATH"
		
		writelog "INFO" "${FUNCNAME[0]} - Finished adding new $NSGA"
	fi
}


function getActiveSteamCollections {
	getParsableGameList | grep "\"tags\"" | awk -F '{+' '{print $NF}' | sed 's/\"/'$'\\\n/g' | sort -u | grep -i "^[a-z]"
}

function getParsableGameList {
	if [ -d "$SUSDA" ]; then
		SC="$STUIDPATH/$SRSCV"
		APPI="Apps"
		APPO="StartMenuShortcutCheck"
		LIST="$(awk "/$APPI/,/$APPO/" "$SC" | grep -v "$APPI\|$APPO" | awk '{printf "%s+",$0} END {print ""}' | sed 's/"[0-9][0-9]/\n&/g')"
		LISTCNT="$(wc -l <<< "$LIST")"
		if [ "$LISTCNT" -eq 0 ]; then
			writelog "SKIP" "${FUNCNAME[0]} - No game found in any Steam collection"
		fi
		echo "$LIST"
	else
		writelog "SKIP" "${FUNCNAME[0]} - '$SUSDA' not found - this should not happen! - skipping"
	fi
}

# Set artwork for Steam game by copying/linking/moving passed artwork to steam grid folder
function setGameArt {
	function applyGameArt {
		GAMEARTAPPID="$1"
		GAMEARTSOURCE="$2"  # e.g. /home/gaben/GamesArt/cs2_hero.png
		GAMEARTSUFFIX="$3"  # e.g. "_hero" etc
		GAMEARTCMD="$4"

		SGGRIDDIR="$STUIDPATH/config/grid"
		GAMEARTBASE="$( basename "$GAMEARTSOURCE" )"
		GAMEARTDEST="${SGGRIDDIR}/${GAMEARTAPPID}${GAMEARTSUFFIX}.${GAMEARTBASE#*.}"  # path to filename in grid e.g. turns "/home/gaben/GamesArt/cs2_hero.png" into "~/.local/share/Steam/userdata/1234567/config/grid/4440654_hero.png"

		if [ -n "$GAMEARTSOURCE" ]; then
			if [ -f "$GAMEARTDEST" ]; then
				writelog "WARN" "${FUNCNAME[0]} - Existing art already exists at '$GAMEARTDEST' - Removing file..."
				rm "$GAMEARTDEST"
			fi

			if [ -f "$GAMEARTSOURCE" ]; then
				$GAMEARTCMD "$GAMEARTSOURCE" "$GAMEARTDEST"
				writelog "INFO" "${FUNCNAME[0]} - Successfully set game art for '$GAMEARTSOURCE' at '$GAMEARTDEST'"
			else
			 	writelog "WARN" "${FUNCNAME[0]} - Given game art '$GAMEARTSOURCE' does not exist, skipping..."
			fi
		fi
	}

	GAME_APPID="$1"  # We don't validate AppID as it would drastically slow down the process for large libraries

	SETARTCMD="cp"  # Default command will copy art
	for i in "$@"; do
		case $i in
			-hr=*|--hero=*)
				SGHERO="${i#*=}"  # <appid>_hero.png -- Banner used on game screen, logo goes on top of this 
				shift ;;
			-lg=*|--logo=*)
				SGLOGO="${i#*=}"  # <appid>_logo.png -- Logo used e.g. on game screen
				shift ;;
			-ba=*|--boxart=*)
				SGBOXART="${i#*=}"  # <appid>p.png -- Used in library
				shift ;;
			-tf=*|--tenfoot=*)
				SGTENFOOT="${i#*=}"  # <appid>.png -- Used as small boxart for e.g. most recently played banner
				shift ;;
			--copy)
				SETARTCMD="cp"  # Copy file to grid folder -- Default
				shift ;;
			--link)
				SETARTCMD="ln -s"  # Symlink file to grid folder
				shift ;;
			--move)
				SETARTCMD="mv"  # Move file to grid folder
				shift ;;
		esac
	done

	applyGameArt "$GAME_APPID" "$SGHERO" "_hero" "$SETARTCMD"
	applyGameArt "$GAME_APPID" "$SGLOGO" "_logo" "$SETARTCMD"
	applyGameArt "$GAME_APPID" "$SGBOXART" "p" "$SETARTCMD"
	applyGameArt "$GAME_APPID" "$SGTENFOOT" "" "$SETARTCMD"

	writelog "INFO" "${FUNCNAME[0]} - Finished setting game art for '$GAME_APPID'. Restart Steam for the changes to take effect."
	# echo "Finished setting game art for '$GAME_APPID'. Restart Steam for the changes to take effect."
}

function check_shortcut_exists {
	SSCEXISTS=0
	if [ -f "$FSCV" ]; then
		SEARCH_STRING=$1
		((skip=0)) # read bytes at this offset
		((count=1024)) # read bytes at this offset
		ramtmp="$(mktemp -p /dev/shm/)"
		ramshorts="$(mktemp -p /dev/shm/)"
		cp $FSCV $ramshorts
		fsize=$(wc -c < "$ramshorts")
		while [ $skip -le $fsize ] ; do
			dd if=$ramshorts bs=1 skip=$skip count=$count of=$ramtmp 2>/dev/null
			pos=$(cat $ramtmp | grep -aobPi $SEARCH_STRING)
			if [ ! -z "$pos" ]; then
				SSCEXISTS=1
				writelog INFO "${FUNCNAME[0]} - Found pre-existing game with palia steam helper."
				return
			else
				((skip=skip+(count-20)))
			fi
		done
	fi
	writelog INFO "${FUNCNAME[0]} - Palia steam helper isn't installed in Steam, let's install it."
}

function msg()
{
    which zenity >/dev/null 2>&1
    if [ $? = 0 ]; then
        zenity $([[ -z $3 ]] && echo "--info" || echo "--question") --width=600 --height=400 --title="Install Palia Steam Helper"  --ok-label="Click/tap here to ${2:-proceed}" "$([[ -z $3 ]] && echo "" || echo "--cancel-label=$3")" --text="$1"
    else
        clear
        echo ""
        echo ""
        echo "$1"
        echo ""
        echo ""
        echo "Press enter to ${2:-proceed}"
        read >/dev/null
    fi
}

if [[ $(pwd)/ = ~/ ]]; then
    msg "$(cat << EndOfMessage
<big>This script should NOT be run in your home directory, please do it somewhere else.</big>
EndOfMessage
    )" "exit"
    exit
fi

rm -f "$LOGFILE"
setSteamPaths

mkdir -p "$TOOLS/$VKEYVALPATH"
writelog MSG "main - Downloading compat_tool and steam kv library.."
curl -sS -L -o $COMPATTOOL $COMPATTOOLSURL
chmod +x $COMPATTOOL
curl -sS -L -o $TOOLS/$VKEYVALS $VKEYVALSURL

writelog MSG "main - Downloading images..."
mkdir -p $IMGS
if [ ! -f $IMGS/$IMG_ICON ]; then
    curl -sS -L -o $IMGS/$IMG_ICON $PSH_REPO/images/$IMG_ICON
fi
if [ ! -f $IMGS/$IMG_LOGO ]; then
    curl -sS -L -o $IMGS/$IMG_LOGO $PSH_REPO/images/$IMG_LOGO
fi
if [ ! -f $IMGS/$IMG_HERO ]; then
    curl -sS -L -o $IMGS/$IMG_HERO $PSH_REPO/images/$IMG_HERO
fi
if [ ! -f $IMGS/$IMG_BOXART ]; then
    curl -sS -L -o $IMGS/$IMG_BOXART $PSH_REPO/images/$IMG_BOXART
fi
if [ ! -f $IMGS/$IMG_TENFOOT ]; then
    curl -sS -L -o $IMGS/$IMG_TENFOOT $PSH_REPO/images/$IMG_TENFOOT
fi
if [ ! -f $IMGS/$IMG_SQUARE ]; then
    curl -sS -L -o $IMGS/$IMG_SQUARE $PSH_REPO/images/$IMG_SQUARE
fi

writelog MSG "main - Downloading Palia Steam Helper script..."
curl -sS -L -O $PSH_REPO/$PSH_SCRIPT
chmod +x $PSH_SCRIPT

if [ ! -f $PSH_REPO/$KNOWN_HASH_FILE ]; then
	writelog MSG "main - Downloading known hashes for base game..."
	curl -sS -L -O $PSH_REPO/$KNOWN_HASH_FILE
fi

check_shortcut_exists $PSH_SCRIPT
if [ $SSCEXISTS -eq 1 ]; then
    msg "$(cat << EndOfMessage
<big>The Palia Steam Helper has been updated.</big>
EndOfMessage
    )" "exit"
else
	steamcmd=$(ps xo command | grep "/steam.sh\( [^/]*\$\|\$\)")
	steampid=$(ps aux | grep "/steam\( [^/]*\$\|\$\)" | awk '{print $2}')
	if [ ! -z "$steampid" ]; then
		writelog INFO "main - The script can't work if Steam is running, so killing Steam, first"
		msg "$(cat << EndOfMessage
<big>We are going to close Steam now!</big>

The script can't do it's work with Steam running, so we are going to close it.
Once the script completes, it will re-launch Steam for you.
EndOfMessage
    	)" "Continue" "Cancel and Exit"
		if (($?==0)); then
			kill $steampid
			while kill -0 $steampid 2>/dev/null; do 
				sleep 1
			done
		else
			exit 0
		fi
	fi

    addNonSteamGame	-ep="$(pwd)/$PSH_SCRIPT" -an="$PALIA_TITLE" -ip="$IMGS/$IMG_ICON" -ao=1

    mkdir -p "$SUIC/grid"
	$COMPATTOOL -c $CFGVDF $shortAppId proton_experimental
	writelog INFO "main - Set AppID: '$shortAppId' in '$CFGVDF' to 'proton_experimental'"

    setGameArt $shortAppId --hero="$IMGS/$IMG_HERO" --logo="$IMGS/$IMG_LOGO" --boxart="$IMGS/$IMG_BOXART" --tenfoot="$IMGS/$IMG_TENFOOT"

    msg "$(cat << EndOfMessage
<big>Palia Steam Setup Complete</big>
- You can head back to Steam or return to Game Mode, select Palia, press play, and continue from there.
- You can close this window and the terminal
EndOfMessage
    )" "exit"

    exit 0
fi
