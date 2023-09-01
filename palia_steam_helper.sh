#!/usr/bin/env python

# Author:    Madalee
# Purpose:   Launch either the PaliaLauncher for install, or the installed PaliaLauncher
# Arguments: None for now

import os
import zipfile
from pathlib import Path
from subprocess import run, Popen, PIPE, STDOUT
import sys
import json
import re
import logging
import hashlib

if os.path.exists("palia_steam_helper.log"):
  os.remove("palia_steam_helper.log")
logging.basicConfig(filename='palia_steam_helper.log', encoding='utf-8', level=logging.DEBUG)

def download_progress(url, target_path, title, text):
    zenity = Popen(['zenity', '--progress', '--percentage=0','--time-remaining', f'--title={title}', f'--text={text}', '--width=400', '--height=300'], text=True, stdin=PIPE, stdout=PIPE)
    cur_line = ""
    curl = Popen(['curl', '--progress-bar', '--retry=5', '--retry-max-time=120', '-L', '-O','-C', '-', url], text=True, stdin=PIPE, stdout=None, stderr=PIPE)
    for c in iter(lambda: curl.stderr.read(1), ""):
        if zenity.poll() != None:
            curl.terminate()
            return zenity.returncode
        if c == '\r' or c == '\n' or c == '\0' or c == '%':
            f = re.findall(r'(\d+\.\d*)', cur_line)
            if len(f) > 0:
                zenity.stdin.write(f"# {f[0]}% complete: {text}\n")
                zenity.stdin.write(f"{f[0]}\n")
                zenity.stdin.flush()
            cur_line = ""
        else:
            cur_line += c
    zenity.terminate()
    return curl.returncode

def extract(zip_path, target_path, title, text, filename=None):
    zenity = Popen(['zenity', '--progress', '--percentage=0','--time-remaining', f'--title={title}', f'--text={text}', '--width=400', '--height=300'], text=True, stdin=PIPE, stdout=PIPE)
    block_size = 8192
    z = zipfile.ZipFile(zip_path)
    total_size = sum((file.file_size for file in z.infolist()))
    offset = 0
    prog = 0
    if filename == None:
        for entry_name in z.namelist():
            if zenity.poll() != None:
                return zenity.returncode
            entry_info = z.getinfo(entry_name)
            i = z.open(entry_name)
            if entry_name[-1] != '/':
                dir_name = os.path.dirname(entry_name)
                p = Path(f"{target_path}/{dir_name}")
                p.mkdir(parents=True, exist_ok=True)
                o = open(f"{target_path}/{entry_name}", 'wb')
                while True:
                    if zenity.poll() != None:
                        i.close()
                        return zenity.returncode
                    b = i.read(block_size)
                    offset += len(b)
                    prog = round(float(offset)/float(total_size) * 100,1)
                    zenity.stdin.write(f"# {prog}% complete: {text}\n")
                    zenity.stdin.write(f"{prog}\n")
                    zenity.stdin.flush()
                    if b == b'':
                        break
                    o.write(b)
                o.close()
            i.close()
        z.close()
    else:
        i = z.open(filename)
        dir_name = os.path.dirname(filename)
        p = Path(f"{target_path}/{dir_name}")
        p.mkdir(parents=True, exist_ok=True)
        o = open(f"{target_path}/{filename}", 'wb')
        while True:
            if zenity.poll() != None:
                i.close()
                return zenity.returncode
            b = i.read(block_size)
            offset += len(b)
            prog = round(float(offset)/float(total_size) * 100,1)
            zenity.stdin.write(f"# {prog}% complete: {text}\n")
            zenity.stdin.write(f"{prog}\n")
            zenity.stdin.flush()
            if b == b'':
                break
            o.write(b)
        o.close()
        i.close()
        z.close()
    zenity.terminate()
    return 0

def save_known_hashes():
    with open(KNOWN_HASH_FILE,"w") as khf:
        khf.write(json.dumps(KNOWN_HASHES))

def load_known_hashes():
    if os.path.isfile(KNOWN_HASH_FILE):
        with open(KNOWN_HASH_FILE,"r") as khf:
            KNOWN_HASHES.clear()
            KNOWN_HASHES.update(json.load(khf))

def file_hash(filename):
    sha256_hash = hashlib.sha256()
    with open(filename,"rb") as f:
        for byte_block in iter(lambda: f.read(4096),b""):
            sha256_hash.update(byte_block)
    return sha256_hash.hexdigest()

def validate_launcher():
    load_known_hashes()
    download_progress(PALIA_LAUNCHER_MANIFEST_URL, PALIA_LAUNCHER_MANIFEST, "Validate Palia Launcher", "Checking Launcher Version")
    manifest_hash_new = file_hash(PALIA_LAUNCHER_MANIFEST)
    if KNOWN_HASHES.get(PALIA_LAUNCHER_MANIFEST, "") != manifest_hash_new or ( os.path.isfile(PALIA_LAUNCHER) and KNOWN_HASHES.get(PALIA_LAUNCHER_EXE, "") != file_hash(PALIA_LAUNCHER) ):
        with open(PALIA_LAUNCHER_MANIFEST, "r") as mf:
            mani = json.load(mf)
        launcherurl = mani['url']
        download_progress(launcherurl, PALIA_LAUNCHER_ZIP, "Validate Palia Launcher", "Downloading New Launcher Version")
        extract(PALIA_LAUNCHER_ZIP, PALIA_LAUNCHER_PATH, "Validate Palia Launcher", "Installing New Launcher Version", PALIA_LAUNCHER_EXE)
        os.remove(PALIA_LAUNCHER_ZIP)
        KNOWN_HASHES[PALIA_LAUNCHER_EXE] = file_hash(PALIA_LAUNCHER)
        KNOWN_HASHES[PALIA_LAUNCHER_MANIFEST] = manifest_hash_new
        save_known_hashes()
    os.remove(PALIA_LAUNCHER_MANIFEST)

def launch_palia():
    validate_launcher()
    with Popen(['proton', 'run', f'{PALIA_LAUNCHER}'], text=True, stdout=PIPE, stderr=STDOUT) as palia_proc:
        logging.debug(palia_proc.stdout.read())
    run(['proton', 'run', f'reg query HKEY_CLASSES_ROOT\\Installer\\Products\\A12B171E85ADD2347AB41DB302B44A77'])

f = re.findall(r'compatdata/([^/]+)/', os.environ['WINEPREFIX'])
if len(f) > 0:
    os.environ['SteamAppId'] = f[0]
os.environ['SteamPath'] = os.environ['OLDPWD']
os.chdir(os.path.dirname(os.path.abspath(sys.argv[0])))
os.environ['STEAM_COMPAT_DATA_PATH'] = "%s/steam" % os.getcwd()
os.environ['STEAM_COMPAT_CLIENT_INSTALL_PATH'] = os.environ['SteamPath']
os.environ['WINEPREFIX'] = "%s/pfx" % os.environ['STEAM_COMPAT_DATA_PATH']
KNOWN_HASH_FILE = "know-hashes.json"
KNOWN_HASHES = {}
PALIA_ROOT = f"{os.environ['WINEPREFIX']}/drive_c/users/steamuser/AppData/Local/Palia"
PALIA_INSTALLER_EXE = "PaliaInstaller.exe"
PALIA_LAUNCHER_EXE = "PaliaLauncher.exe"
PALIA_LAUNCHER_ZIP = "PaliaLauncher-0.3.6.zip"
PALIA_LAUNCHER_MANIFEST = "PaliaLauncher.json"
PALIA_LAUNCHER_PATH = f"{PALIA_ROOT}/Launcher"
PALIA_LAUNCHER = f"{PALIA_LAUNCHER_PATH}/{PALIA_LAUNCHER_EXE}"
#For later
#PALIA_LAUNCHER = f"{PALIA_ROOT}/Client/Palia/Binaries/Win64/PaliaClient-Win64-Shipping.exe"
PALIA_LAUNCHER_HASH = "724640ab262eab5d52544717cdefa68122c2a688cc250a47cd8db595ec516349"
PALIA_INSTALLER_URL = "https://update.palia.com/launcher/PaliaInstaller.exe"
PALIA_LAUNCHER_URL = "https://update.palia.com/bundles/PaliaLauncher-0.3.6.zip"
PALIA_LAUNCHER_MANIFEST_URL = "https://update.palia.com/manifest/PaliaLauncher.json"
PALIA_MANIFEST_URL = "https://update.palia.com/manifest/PatchManifest.json"
PALIA_MANIFEST = PALIA_MANIFEST_URL.rsplit('/', 1)[-1]
PALIA_EULA_URL = "https://palia.com/terms"
REGFILE = "regimport.reg"
NOTICEFILE = "notice.txt"
REGBATFILE = "reg.bat"
VCREDIST_URL = "https://aka.ms/vs/17/release/vc_redist.x64.exe"
VCREDIST = VCREDIST_URL.rsplit('/', 1)[-1]

os.environ['PATH'] = "%s:%s" % (os.environ['STEAM_COMPAT_TOOL_PATHS'], os.environ['PATH'])
os.environ['DXVK_CONFIG_FILE'] = f"{os.getcwd()}/dxvk.conf"
os.environ['DXVK_HUD'] = "compiler"
os.environ['DXVK_STATE_CACHE_PATH'] = f"{os.getcwd()}"
os.environ['VKD3D_SHADER_CACHE_PATH'] = f"{os.getcwd()}"
os.environ['STAGING_SHARED_MEMORY'] = "0"
os.environ['__GL_SHADER_DISK_CACHE'] = "1"
os.environ['__GL_SHADER_DISK_CACHE_PATH'] = f"{os.getcwd()}"
os.environ['__GL_SHADER_DISK_CACHE_SKIP_CLEANUP'] = "1"
os.environ['RADV_PERFTEST'] = "GPL,ACO"
os.environ['mesa_glthread'] = "true"
os.environ['PROTON_NO_FSYNC'] = "1"
os.environ['DXVK_ASYNC'] = "1"

if os.environ.get('SteamDeck', '') == "1":
    PALIA_CACHE_PATH = f"{os.environ['HOME']}/.cache/Palia"
    os.makedirs(PALIA_CACHE_PATH, exist_ok = True)
    os.environ['__GL_SHADER_DISK_CACHE_PATH'] = f"{PALIA_CACHE_PATH}"
    os.environ['DXVK_STATE_CACHE_PATH'] = f"{PALIA_CACHE_PATH}"
    os.environ['VKD3D_SHADER_CACHE_PATH'] = f"{PALIA_CACHE_PATH}"

if os.path.isfile(PALIA_LAUNCHER) == True:
    launch_palia()
    sys.exit(0)

notice = open(NOTICEFILE, "w")
notice.write("""This script/launcher is not provided by or affiliated with Singularity 6 in any way.
Use this at your own risk.

Due to an issue with the PaliaLauncher under Wine, and to simplify the process, this installer will skip the EULA agreement page.

!! By running this script you agree to abide by the EULA and Terms and Conditions as laid out in the official Palia installer, as well as the one from the official Palia website at:
https://palia.com/terms""")
notice.close()
nr = run(['zenity', '--text-info', '--title=Important Notice', f'--filename={NOTICEFILE}', '--width=600', '--height=400'])
os.remove(NOTICEFILE)
if nr.returncode != 0:
    sys.exit(nr.returncode)


run(['curl', '-L', '-O', PALIA_MANIFEST_URL])
with open(PALIA_MANIFEST, "r") as mf:
    mani = json.load(mf)

basever = list(filter(lambda x: mani[x]['BaseLineVer'], mani))[0]
baseverurl = mani[basever]['Files'][0]['URL']
baseverzip = baseverurl.rsplit('/', 1)[-1]
os.remove(PALIA_MANIFEST)

rs = download_progress(VCREDIST_URL, VCREDIST, "Installing Palia", "Downloading VC Redist...")
if rs != 0:
    sys.exit(rs)
rs = download_progress(baseverurl, baseverzip, "Installing Palia", "Downloading base Palia version...")
if rs != 0:
    sys.exit(rs)
os.makedirs(f"{PALIA_ROOT}/Client", exist_ok = True)
rs = extract(baseverzip, f"{PALIA_ROOT}/Client/", "Installing Palia", "Extracting base game files...")
if rs != 0:
    sys.exit(rs)
os.remove(baseverzip)

rf = open(REGFILE, "w")
rf.write(f"""Windows Registry Editor Version 5.00

[HKEY_CLASSES_ROOT\\Installer\\Products\\A12B171E85ADD2347AB41DB302B44A77]
"PackageCode"="BB3908D00C04BD54FBD8A0D013C6B052"
"ProductName"="UE Prerequisites (x64)"

[HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\Palia]
"DisplayIcon"="C:\\\\users\\\\steamuser\\\\AppData\\\\Local\\\\Palia\\\\Launcher\\\\PaliaLauncher.exe"
"DisplayName"="Palia"
"DisplayVersion"="{basever}"
"EstimatedSize"=dword:00000001
"InstallDate"="20230801"
"InstallLocation"="C:\\\\users\\\\steamuser\\\\AppData\\\\Local\\\\Palia"
"NoModify"=dword:00000001
"NoRepair"=dword:00000001
"Publisher"="Singularity 6 Corporation"
"UninstallString"="C:\\\\users\\\\steamuser\\\\AppData\\\\Local\\\\Palia\\\\Launcher\\\\PaliaLauncher.exe uninstall"
"X-BaseVersion"="{basever}"
"X-Entry"="Palia.exe"
"X-NdaAcceptedVersion"=dword:00000001
"X-PatchMethod"="pak"
""")
rf.close()

zenity = Popen(['zenity', '--progress', '--percentage=0','--time-remaining', f'--title="Installing Palia"', f'--text=Prepping Wine environment...', '--width=350'], text=True, stdin=PIPE, stdout=PIPE)
if zenity.poll() != None:
    sys.exit(zenity.returncode)
zenity.stdin.write("# Importing registry changes...\n")
zenity.stdin.write("40\n")
zenity.stdin.flush()

rf = open(REGBATFILE, "w")
rf.write(f"""@echo off
regedit regimport.reg
reg query HKEY_CLASSES_ROOT\\Installer\\Products\\A12B171E85ADD2347AB41DB302B44A77
""")
rf.close()

run(['proton', 'run', f'{REGBATFILE}'])
os.remove(REGBATFILE)
os.remove(REGFILE)
os.makedirs(f"{PALIA_ROOT}/Launcher/Downloads", exist_ok = True)
if zenity.poll() != None:
    sys.exit(zenity.returncode)
zenity.stdin.write("# Installing VC Redist...\n")
zenity.stdin.write("60\n")
zenity.stdin.flush()
if zenity.poll() != None:
    sys.exit(zenity.returncode)
run(['proton', 'run', 'vc_redist.x64.exe', '/q'])
zenity.terminate()
os.remove(VCREDIST)

launch_palia()
