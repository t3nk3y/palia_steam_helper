#!/usr/bin/env bash

# Author:    Madalee
# Purpose:   Launch either the PaliaLauncher for install, or the installed PaliaLauncher
# Arguments: None for now

set -e

#parse the SteamAppId from the available Steam variables
regex="shadercache/([^/]+)/"
[[ $STEAM_COMPAT_MEDIA_PATH =~ $regex ]]
export SteamAppId=${BASH_REMATCH[1]}
export SteamPath=$OLDPWD
export ProtonPath="$SteamPath/steamapps/common/Proton - Experimental/proton"
export STEAM_COMPAT_DATA_PATH="$PWD/steam"
export STEAM_COMPAT_CLIENT_INSTALL_PATH="$SteamPath"
export WINEPREFIX="$STEAM_COMPAT_DATA_PATH/pfx"
export PALIAROOT="$WINEPREFIX/drive_c/users/steamuser/AppData/Local/Palia"
export PALIALAUNCHER="$PALIAROOT/Launcher/PaliaLauncher.exe"
export PALIALAUNCHERURL="https://update.palia.com/launcher/PaliaLauncher.exe"
export SKIPUE=skipue.reg
export LAUNCHERBAT=launcher.bat
export INITPALIA=initpalia.sh

function run_palia_launcher {
    "$ProtonPath" run ./PaliaLauncher.exe
    #export STEP=rpl
    #konsole
}

function run_palia {
    "$ProtonPath" run "$PALIALAUNCHER"
    "$ProtonPath" runinprefix reg query HKEY_CLASSES_ROOT\\Installer\\Products\\A12B171E85ADD2347AB41DB302B44A77
    #export STEP=rp
    #konsole
}

function make_skipue {
    cat > $SKIPUE <<- EOM
Windows Registry Editor Version 5.00

[HKEY_CLASSES_ROOT\\Installer\\Products\\A12B171E85ADD2347AB41DB302B44A77]
"PackageCode"="BB3908D00C04BD54FBD8A0D013C6B052"
"ProductName"="UE Prerequisites (x64)"

[HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\Palia]
"DisplayIcon"="C:\\\\users\\\\steamuser\\\\AppData\\\\Local\\\\Palia\\\\Launcher\\\\PaliaLauncher.exe"
"DisplayName"="Palia"
"DisplayVersion"="$basever"
"EstimatedSize"=dword:00000001
"InstallDate"="20230801"
"InstallLocation"="C:\\\\users\\\\steamuser\\\\AppData\\\\Local\\\\Palia"
"NoModify"=dword:00000001
"NoRepair"=dword:00000001
"Publisher"="Singularity 6 Corporation"
"UninstallString"="C:\\\\users\\\\steamuser\\\\AppData\\\\Local\\\\Palia\\\\Launcher\\\\PaliaLauncher.exe uninstall"
"X-BaseVersion"="$basever"
"X-Entry"="Palia.exe"
"X-NdaAcceptedVersion"=dword:00000001
"X-PatchMethod"="pak"
EOM
}

function make_bat {
    cat > $LAUNCHERBAT <<- EOM
@echo off
echo Installing VCRedist...
vc_redist.x64.exe /q
echo Skipping UE Prerequisites...
reg import skipue.reg
reg query HKEY_CLASSES_ROOT\\Installer\\Products\\A12B171E85ADD2347AB41DB302B44A77
rem cmd
EOM
}

function get_manifest {
    curl -L -O https://update.palia.com/manifest/PatchManifest.json
    export baseverurl=$(cat PatchManifest.json | python -c "import sys, json; mani = json.load(sys.stdin); blv = list(filter(lambda x: mani[x]['BaseLineVer'], mani))[0]; print(mani[blv]['Files'][0]['URL'])")
    export basever=$(cat PatchManifest.json | python -c "import sys, json; mani = json.load(sys.stdin); blv = list(filter(lambda x: mani[x]['BaseLineVer'], mani))[0]; print(blv)")
    export baseverzip=${baseverurl##*/}
    rm PatchManifest.json
}

function bash_init {
cat > $INITPALIA <<- EOM
#!/usr/bin/env bash 2>/dev/null
set -e
konsole
exit
    echo Downloading VC Redist...
    curl --progress-bar -L -O -C - https://aka.ms/vs/17/release/vc_redist.x64.exe
    echo Downloading Palia laincher...
    curl --progress-bar -L -O -C - $PALIALAUNCHERURL
    echo Downloading base Palia version...
    curl --progress-bar -L -O -C - $baseverurl
    echo Extracting base Palia version...
    mkdir -p $PALIAROOT/Client
    unzip -u $baseverzip -d $PALIAROOT/Client/
    rm $baseverzip
    mkdir -p $PALIAROOT/Launcher/Downloads
    mv PaliaLauncher.exe $PALIAROOT/Launcher/
EOM
}

#if we've stored the path to the Palia install, then use it, and quit
#if [ -f ./PaliaLinuxLocation.txts ]; then
#    export PaliaLinuxLocation=$(cat ./PaliaLinuxLocation.txt)
#    if [ ! -z $PaliaLinuxLocation ]; then
#        if [ -d $PaliaLinuxLocation ]; then
#            run_palia
#            exit
#        fi
#    fi
#fi

if [ -f "$PALIALAUNCHER" ]; then
    run_palia
    #we don't know the Palia path, try going in to the Proton Prefix's registry to find it(this takes a few seconds)
    #export PaliaInstallLocation=$("$ProtonPath" runinprefix reg query HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\Palia /v InstallLocation | grep InstallLocation)

    #if [ ! -z "$PaliaInstallLocation" ]; then
        #try parsing the Palia, Windows install location from the output given by the reg command
    #    regex="InstallLocation +REG_SZ +(.+)"
    #    [[ $PaliaInstallLocation =~ $regex ]]
    #    export PaliaInstallLocation=$(echo ${BASH_REMATCH[1]} | tr -d '\r')
    #fi
else
#konsole
    get_manifest
    bash_init
    xterm -fg grey -bg black -geometry 100x25 -fa 'Monospace' -fs 10 -e bash $INITPALIA
    rm $INITPALIA
    make_skipue
    make_bat
    "$ProtonPath" run $LAUNCHERBAT
    rm $SKIPUE
    rm $LAUNCHERBAT
    rm vc_redist.x64.exe
    run_palia
fi

#get the Linux path from the Windows path(this takes a few seconds)
#if [ ! -z "$PaliaInstallLocation" ]; then
#    export PaliaLinuxLocation=$("$ProtonPath" getnativepath "$PaliaInstallLocation")
#fi

#if [ -z "$PaliaLinuxLocation" ]; then
    #we didn't find an installation, so let's run the PaliaLauncher.exe from the helper path
#    run_palia_launcher
#else
    #we found an existing installation, so store it's path to speed things up next time, then run it
    #echo $PaliaLinuxLocation > ./PaliaLinuxLocation.txt
    #run_palia
#fi
