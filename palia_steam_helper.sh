#!/usr/bin/env python

# Author:    Madalee
# Purpose:   Launch either the PaliaLauncher for install, or the installed PaliaLauncher
# Arguments: None for now

import os
from zipfile import (
    ZipFile,
    ZipExtFile,
    sizeFileHeader,
    BadZipFile,
    _FH_SIGNATURE,
    structFileHeader,
    stringFileHeader,
    _FH_FILENAME_LENGTH,
    _FH_EXTRA_FIELD_LENGTH,
    _FH_GENERAL_PURPOSE_FLAG_BITS,
    ZipInfo,
    sizeEndCentDir,
    structEndArchive,
    _ECD_OFFSET,
    _ECD_SIZE,
    structEndArchive64,
    _CD64_DIRECTORY_SIZE,
    _CD64_OFFSET_START_CENTDIR,
)
from pathlib import Path
from subprocess import run, Popen, PIPE, STDOUT
import sys
import json
import re
import logging
import hashlib
from fileinput import FileInput
import io
import struct
from copy import copy
from urllib.request import Request
import urllib.request
import atexit

EOCD_RECORD_SIZE = sizeEndCentDir
ZIP64_EOCD_RECORD_SIZE = 56
ZIP64_EOCD_LOCATOR_SIZE = 20
MAX_STANDARD_ZIP_SIZE = 4_294_967_295


f = re.findall(r"compatdata/([^/]+)/", os.environ.get("WINEPREFIX", ""))
if len(f) > 0:
    os.environ["SteamAppId"] = f[0]
os.environ["SteamPath"] = os.environ.get("OLDPWD", "")
os.chdir(os.path.dirname(os.path.abspath(sys.argv[0])))
os.environ["STEAM_COMPAT_DATA_PATH"] = "%s/steam" % os.getcwd()
os.environ["STEAM_COMPAT_CLIENT_INSTALL_PATH"] = os.environ["SteamPath"]
os.environ["WINEPREFIX"] = "%s/pfx" % os.environ["STEAM_COMPAT_DATA_PATH"]
USER_REG = f"{os.environ['WINEPREFIX']}/user.reg"
PSH_REPO = "https://raw.githubusercontent.com/t3nk3y/palia_steam_helper/main"
BASE_HASH_FILE = "base-hashes.json"
KNOWN_HASH_FILE = "known-hashes.json"
KNOWN_HASHES = {}
BASE_HASHES = {}
MANIFEST_HASHES = {}
PALIA_ROOT = f"{os.environ['WINEPREFIX']}/drive_c/users/steamuser/AppData/Local/Palia"
PALIA_INSTALLER_EXE = "PaliaInstaller.exe"
PALIA_LAUNCHER_EXE = "PaliaLauncher.exe"
PALIA_LAUNCHER_ZIP = "PaliaLauncher-0.3.6.zip"
PALIA_LAUNCHER_MANIFEST = "PaliaLauncher.json"
PALIA_LAUNCHER_PATH = f"{PALIA_ROOT}/Launcher"
PALIA_LAUNCHER = f"{PALIA_LAUNCHER_PATH}/{PALIA_LAUNCHER_EXE}"
PALIA_CLIENT_PATH = f"{PALIA_ROOT}/Client"
PALIA_BIN_PATH = f"{PALIA_CLIENT_PATH}/Palia/Binaries/Win64"
PALIA_EXE = f"{PALIA_BIN_PATH}/PaliaClient-Win64-Shipping.exe"
PALIA_PAK_PATH = f"{PALIA_CLIENT_PATH}/Palia/Content/Paks"

# For later
# PALIA_LAUNCHER = f"{PALIA_ROOT}/Client/Palia/Binaries/Win64/PaliaClient-Win64-Shipping.exe"
PALIA_LAUNCHER_HASH = "724640ab262eab5d52544717cdefa68122c2a688cc250a47cd8db595ec516349"
PALIA_INSTALLER_URL = "https://update.palia.com/launcher/PaliaInstaller.exe"
PALIA_LAUNCHER_URL = "https://update.palia.com/bundles/PaliaLauncher-0.3.6.zip"
PALIA_LAUNCHER_MANIFEST_URL = "https://update.palia.com/manifest/PaliaLauncher.json"
PALIA_MANIFEST_URL = "https://update.palia.com/manifest/PatchManifest.json"
PALIA_MANIFEST = PALIA_MANIFEST_URL.rsplit("/", 1)[-1]
PALIA_EULA_URL = "https://palia.com/terms"
PALIA_DISP_VER = ""
PALIA_BASE_VER = ""
PALIA_BASE_VER_URL = ""
PALIA_BASE_VER_ZIP = ""
REGFILE = "regimport.reg"
NOTICEFILE = "notice.txt"
REGBATFILE = "reg.bat"
VCREDIST_URL = "https://aka.ms/vs/17/release/vc_redist.x64.exe"
VCREDIST = VCREDIST_URL.rsplit("/", 1)[-1]

os.environ["PATH"] = "%s:%s" % (
    os.environ.get("STEAM_COMPAT_TOOL_PATHS", ""),
    os.environ["PATH"],
)
os.environ["DXVK_CONFIG_FILE"] = f"{os.getcwd()}/dxvk.conf"
os.environ["DXVK_HUD"] = "compiler"
os.environ["DXVK_STATE_CACHE_PATH"] = f"{os.getcwd()}"
os.environ["VKD3D_SHADER_CACHE_PATH"] = f"{os.getcwd()}"
os.environ["STAGING_SHARED_MEMORY"] = "0"
os.environ["__GL_SHADER_DISK_CACHE"] = "1"
os.environ["__GL_SHADER_DISK_CACHE_PATH"] = f"{os.getcwd()}"
os.environ["__GL_SHADER_DISK_CACHE_SKIP_CLEANUP"] = "1"
os.environ["RADV_PERFTEST"] = "GPL,ACO"
os.environ["mesa_glthread"] = "true"
os.environ["PROTON_NO_FSYNC"] = "1"
os.environ["DXVK_ASYNC"] = "1"

if os.environ.get("SteamDeck", "") == "1":
    PALIA_CACHE_PATH = f"{os.environ['HOME']}/.cache/Palia"
    os.makedirs(PALIA_CACHE_PATH, exist_ok=True)
    os.environ["__GL_SHADER_DISK_CACHE_PATH"] = f"{PALIA_CACHE_PATH}"
    os.environ["DXVK_STATE_CACHE_PATH"] = f"{PALIA_CACHE_PATH}"
    os.environ["VKD3D_SHADER_CACHE_PATH"] = f"{PALIA_CACHE_PATH}"


if os.path.exists("palia_steam_helper.log"):
    os.remove("palia_steam_helper.log")
logging.basicConfig(
    filename="palia_steam_helper.log", encoding="utf-8", level=logging.DEBUG
)

logging.debug(f"Starting Steam Palia Helper...")

# run(["xterm", "bash"])
# sys.exit()


class HTTPRangeRequestUnsupported(Exception):
    pass


class OnlineZip(ZipFile):
    def __init__(self, url):
        self.url = url
        self._support()
        super().__init__(self._get_central_directory())

    def _support(self):
        req: Request = Request(
            self.url, method="HEAD", headers={"User-agent": "PaliaSteamHelper/1.00.0"}
        )
        resp = urllib.request.urlopen(req)
        self.file_size = int((resp.info()["Content-Length"]))
        self.accept_bytes = resp.info()["Accept-Ranges"] == "bytes"
        if not self.accept_bytes:
            raise HTTPRangeRequestUnsupported("range request is not supported")

    def _get_central_directory(self):
        eocd_record = self._fetch_bytes(
            self.file_size - EOCD_RECORD_SIZE, EOCD_RECORD_SIZE
        )
        if self.file_size <= MAX_STANDARD_ZIP_SIZE:
            endrec = struct.unpack(structEndArchive, eocd_record)
            endrec = list(endrec)

            self.cd_start = endrec[_ECD_OFFSET]
            self.cd_size = endrec[_ECD_SIZE]

            # cd_start = self.file_size - cd_size - EOCD_RECORD_SIZE
            central_directory = self._fetch_bytes(self.cd_start, self.cd_size)
            return io.BytesIO(central_directory + eocd_record)
        else:
            zip64_eocd_record = self._fetch_bytes(
                self.file_size
                - (EOCD_RECORD_SIZE + ZIP64_EOCD_LOCATOR_SIZE + ZIP64_EOCD_RECORD_SIZE),
                ZIP64_EOCD_RECORD_SIZE,
            )
            zip64_eocd_locator = self._fetch_bytes(
                self.file_size - (EOCD_RECORD_SIZE + ZIP64_EOCD_LOCATOR_SIZE),
                ZIP64_EOCD_LOCATOR_SIZE,
            )

            endrec = struct.unpack(structEndArchive64, zip64_eocd_record)
            endrec = list(endrec)

            self.cd_start = endrec[_CD64_OFFSET_START_CENTDIR]
            self.cd_size = endrec[_CD64_DIRECTORY_SIZE]

            central_directory = self._fetch_bytes(self.cd_start, self.cd_size)
            return io.BytesIO(
                central_directory + zip64_eocd_record + zip64_eocd_locator + eocd_record
            )

    def _fetch_bytes(self, start, length):
        end = start + length - 1
        req = Request(self.url)
        req.add_header("User-agent", "PaliaSteamHelper/1.00.0")
        req.add_header("Range", f"bytes={start}-{end}")

        resp = urllib.request.urlopen(req)
        return resp.read()

    def _stream_bytes(self, start, length):
        end = start + length - 1
        req = Request(self.url)
        req.add_header("User-agent", "PaliaSteamHelper/1.00.0")
        req.add_header("Range", f"bytes={start}-{end}")

        resp = urllib.request.urlopen(req)
        return resp

    def open(self, name, mode="r", pwd=None, *, force_zip64=False):
        # Make sure we have an info object
        if isinstance(name, ZipInfo):
            # 'name' is already an info object
            file_info = name
        else:
            # Get info object for name
            file_info = self.getinfo(name)

        file_info = copy(file_info)

        # offset is calculated wrongly because file info is created from part of file,
        # adding central directory offset give us good value
        # fetching only header
        header_bytes = self._fetch_bytes(
            file_info.header_offset + self.cd_start, sizeFileHeader
        )

        try:
            # Skip the file header:
            if len(header_bytes) != sizeFileHeader:
                raise BadZipFile("Truncated file header")
            fheader = struct.unpack(structFileHeader, header_bytes)
            if fheader[_FH_SIGNATURE] != stringFileHeader:
                raise BadZipFile("Bad magic number for file header")

            offset = fheader[_FH_FILENAME_LENGTH]
            if fheader[_FH_EXTRA_FIELD_LENGTH]:
                offset += fheader[_FH_EXTRA_FIELD_LENGTH]

            # now We can fetch rest of bytes, again correction for offset plus header size
            # for size We use compressed size, file name size and extra field size
            file_stream = self._stream_bytes(
                file_info.header_offset + self.cd_start + sizeFileHeader,
                file_info.compress_size + offset,
            )

            # little trick
            file_info.header_offset = 0
            # delattr(file_info, 'CRC')
            # block_size = 8192
            in_memory_file = file_stream

            fname = in_memory_file.read(fheader[_FH_FILENAME_LENGTH])
            if fheader[_FH_EXTRA_FIELD_LENGTH]:
                in_memory_file.read(fheader[_FH_EXTRA_FIELD_LENGTH])

            if fheader[_FH_GENERAL_PURPOSE_FLAG_BITS] & 0x800:
                # UTF-8 filename
                fname_str = fname.decode("utf-8")
            else:
                fname_str = fname.decode("cp437")

            if fname_str != file_info.orig_filename:
                raise BadZipFile(
                    "File name in directory %r and header %r differ."
                    % (file_info.orig_filename, fname)
                )

            # check for encrypted flag & handle password
            is_encrypted = file_info.flag_bits & 0x1
            if is_encrypted:
                if not pwd:
                    pwd = self.pwd
                if not pwd:
                    raise RuntimeError(
                        "File %r is encrypted, password "
                        "required for extraction" % name
                    )
            else:
                pwd = None

            return ZipExtFile(in_memory_file, mode="r", zipinfo=file_info, pwd=pwd)
        except:
            in_memory_file.close()
            raise


@atexit.register
def cleanup():
    if os.path.exists(PALIA_MANIFEST):
        os.remove(PALIA_MANIFEST)
    if os.path.exists(VCREDIST):
        os.remove(VCREDIST)


def download_progress(url, target_path, title, text, zeni=None):
    if zeni:
        zenity = zeni
    else:
        zenity = Popen(
            [
                "zenity",
                "--progress",
                "--percentage=0",
                "--time-remaining",
                f"--title={title}",
                f"--text={text}",
                "--width=400",
                "--height=300",
            ],
            text=True,
            stdin=PIPE,
            stdout=PIPE,
        )
    cur_line = ""
    curl = Popen(
        [
            "curl",
            "--progress-bar",
            "--retry",
            "5",
            "--retry-max-time",
            "120",
            "-L",
            "-o",
            target_path,
            "-C",
            "-",
            url,
        ],
        text=True,
        stdin=PIPE,
        stdout=None,
        stderr=PIPE,
    )
    for c in iter(lambda: curl.stderr.read(1), ""):
        if zenity.poll() != None:
            curl.terminate()
            return zenity.returncode
        if c == "\r" or c == "\n" or c == "\0" or c == "%":
            f = re.findall(r"(\d+\.\d*)", cur_line)
            if len(f) > 0:
                zenity.stdin.write(f"# {text}\\nProgress: {f[0]}%\n")
                if not zeni:
                    zenity.stdin.write(f"{f[0]}\n")
                zenity.stdin.flush()
            cur_line = ""
        else:
            cur_line += c
    if not zeni:
        zenity.terminate()
    return 0 if curl.returncode == None else curl.returncode


def download(url, target_path):
    logging.debug(f"Downloading to: {target_path} from: {url}")
    curl = run(
        [
            "curl",
            "--progress-bar",
            "--retry",
            "5",
            "--retry-max-time",
            "120",
            "-L",
            "-o",
            target_path,
            "-C",
            "-",
            url,
        ]
    )
    if curl.returncode in [None, 0]:
        logging.debug(f"Successfully downloaded: {target_path}")
    else:
        logging.debug(f"Problem downloading: {target_path} ERROR: {curl.returncode}")
    return 0 if curl.returncode == None else curl.returncode


def extract(zip_path, target_path, title, text, filename=None):
    zenity = Popen(
        [
            "zenity",
            "--progress",
            "--percentage=0",
            "--time-remaining",
            f"--title={title}",
            f"--text={text}",
            "--width=400",
            "--height=300",
        ],
        text=True,
        stdin=PIPE,
        stdout=PIPE,
    )
    chunk_size = 8192
    if zip_path.startswith("http"):
        logging.debug(f"Downloading and unzipping from: {zip_path}")
        z = OnlineZip(zip_path)
    else:
        z = ZipFile(zip_path)
        logging.debug(f"Unzipping from: {zip_path}")
    total_size = sum((file.file_size for file in z.infolist()))
    offset = 0
    prog = 0
    if filename == None:
        for entry_name in z.namelist():
            if zenity.poll() != None:
                return zenity.returncode
            i = z.open(entry_name)
            if entry_name[-1] != "/":
                dir_name = os.path.dirname(entry_name)
                p = Path(f"{target_path}/{dir_name}")
                p.mkdir(parents=True, exist_ok=True)
                fsize = z.getinfo(entry_name).file_size
                if (
                    Path(f"{target_path}/{entry_name}").exists()
                    and KNOWN_HASHES.get(entry_name, "") != ""
                ):
                    logging.debug(
                        f"Download/Unzip - File exists, validating it: {entry_name}"
                    )
                    if fsize > 128000000:
                        zenity.stdin.write(
                            f"# {text}\\nFile exists, validating it...\\n{Path(entry_name).name}\\nOverall progress: {prog}%\n"
                        )
                        zenity.stdin.write(f"{prog}\n")
                        zenity.stdin.flush()
                    if file_hash(f"{target_path}/{entry_name}") == KNOWN_HASHES.get(
                        entry_name, ""
                    ):
                        i.close()
                        logging.debug(
                            f"Download/Unzip - File valid, skipping it: {entry_name}"
                        )
                        offset += z.getinfo(entry_name).file_size
                        prog = round(float(offset) / float(total_size) * 100, 1)
                        zenity.stdin.write(
                            f"# {text}\\nFile is already valid, skipping...\\n{Path(entry_name).name}\\nOverall progress: {prog}%\n"
                        )
                        zenity.stdin.write(f"{prog}\n")
                        zenity.stdin.flush()
                        continue
                o = open(f"{target_path}/{entry_name}", "wb")
                progi = 0
                offseti = 0
                logging.debug(f"Download/Unzip - {entry_name}")
                while True:
                    if zenity.poll() != None:
                        i.close()
                        return zenity.returncode
                    b = i.read(chunk_size)
                    offset += len(b)
                    offseti += len(b)
                    prog = round(float(offset) / float(total_size) * 100, 1)
                    progi = round(float(offseti) / float(fsize) * 100, 1)
                    zenity.stdin.write(
                        f"# {text}\\nCurrent file downloading: {progi}%\\n{Path(entry_name).name}\\nOverall progress: {prog}%\n"
                    )
                    zenity.stdin.write(f"{prog}\n")
                    zenity.stdin.flush()
                    if b == b"":
                        break
                    o.write(b)
                o.close()
                logging.debug(f"Finished downloading, hashing: {entry_name}")
                if entry_name in KNOWN_HASHES:
                    zenity.stdin.write(
                        f"# {text}\\nRe-validating...\\n{Path(entry_name).name}\\nOverall progress: {prog}%\n"
                    )
                    zenity.stdin.write(f"{prog}\n")
                    zenity.stdin.flush()
                    if KNOWN_HASHES.get(entry_name, "") == file_hash(
                        f"{target_path}/{entry_name}"
                    ):
                        logging.debug(f"Validated after downloading: {entry_name}")
                    else:
                        logging.debug(
                            f"Failed validation after downloading: {entry_name}"
                        )
                        FAILED_REPLACEMENTS[entry_name] = zip_path
                else:
                    zenity.stdin.write(
                        f"# {text}\\nAdding to hashes...\\n{Path(entry_name).name}\\nOverall progress: {prog}%\n"
                    )
                    zenity.stdin.write(f"{prog}\n")
                    zenity.stdin.flush()
                    KNOWN_HASHES[entry_name] = file_hash(f"{target_path}/{entry_name}")
                    logging.debug(f"Added new file to known hashes: {entry_name}")
            i.close()
        z.close()
    else:
        i = z.open(filename)
        dir_name = os.path.dirname(filename)
        p = Path(f"{target_path}/{dir_name}")
        p.mkdir(parents=True, exist_ok=True)
        o = open(f"{target_path}/{filename}", "wb")
        fsize = z.getinfo(filename).file_size
        logging.debug(f"Download/Unzip - {filename}")
        while True:
            if zenity.poll() != None:
                i.close()
                return zenity.returncode
            b = i.read(chunk_size)
            offset += len(b)
            prog = round(float(offset) / float(fsize) * 100, 1)
            zenity.stdin.write(f"# {text}\\nProgress: {prog}%\n")
            zenity.stdin.write(f"{prog}\n")
            zenity.stdin.flush()
            if b == b"":
                break
            o.write(b)
        o.close()
        i.close()
        KNOWN_HASHES[filename] = file_hash(f"{target_path}/{filename}")
        logging.debug(f"Validated after downloading: {filename}")

        logging.debug(f"Finished downloading, hashing: {filename}")
        if filename in KNOWN_HASHES:
            zenity.stdin.write(f"# {text}\\nRe-validating...\\n{Path(filename).name}\n")
            zenity.stdin.flush()
            if KNOWN_HASHES.get(filename, "") == file_hash(f"{target_path}/{filename}"):
                logging.debug(f"Validated after downloading: {filename}")
            else:
                logging.debug(f"Failed validation after downloading: {filename}")
                FAILED_REPLACEMENTS[filename] = zip_path
                z.close()
                zenity.terminate()
                return 2
        else:
            zenity.stdin.write(
                f"# {text}\\nAdding to hashes...\\n{Path(filename).name}\n"
            )
            zenity.stdin.flush()
            KNOWN_HASHES[filename] = file_hash(f"{target_path}/{filename}")
            logging.debug(f"Added new file to known hashes: {filename}")
        z.close()
    zenity.terminate()
    return 0


def save_known_hashes():
    with open(KNOWN_HASH_FILE, "w") as khf:
        khf.write(json.dumps(KNOWN_HASHES))


def load_base_hashes():
    if not os.path.isfile(BASE_HASH_FILE):
        download(f"{PSH_REPO}/{KNOWN_HASH_FILE}", BASE_HASH_FILE)
    if os.path.isfile(BASE_HASH_FILE):
        with open(BASE_HASH_FILE, "r") as bhf:
            BASE_HASHES.clear()
            BASE_HASHES.update(json.load(bhf))


def load_known_hashes():
    if os.path.isfile(KNOWN_HASH_FILE):
        with open(KNOWN_HASH_FILE, "r") as khf:
            KNOWN_HASHES.clear()
            KNOWN_HASHES.update(json.load(khf))


def have_mani_hashes_changed():
    global PALIA_BASE_VER, PALIA_BASE_VER_URL, PALIA_BASE_VER_ZIP, PALIA_DISP_VER
    if not KNOWN_HASHES:
        load_known_hashes()
    if MANIFEST_HASHES:
        return False
    run(["curl", "-L", "-O", PALIA_MANIFEST_URL])
    pmh = file_hash(PALIA_MANIFEST)
    if os.path.isfile(PALIA_MANIFEST):
        logging.debug(f"loaded {PALIA_MANIFEST}")
        with open(PALIA_MANIFEST, "r") as mhf:
            MANIFEST_HASHES.clear()
            mani = json.load(mhf)
            for k in mani:
                if mani[k]["BaseLineVer"]:
                    PALIA_BASE_VER = k
                    PALIA_BASE_VER_URL = mani[k]["Files"][0]["URL"]
                    PALIA_BASE_VER_ZIP = mani[k]["Files"][0]["URL"].rsplit("/", 1)[-1]
                else:
                    PALIA_DISP_VER = k
                    for f in mani[k]["Files"]:
                        MANIFEST_HASHES[f["URL"].rsplit("/", 1)[-1]] = f
    if pmh != KNOWN_HASHES.get(PALIA_MANIFEST, ""):
        KNOWN_HASHES[PALIA_MANIFEST] = pmh

        if os.path.isfile(USER_REG):
            with FileInput(USER_REG, inplace=True, backup=".bak") as rf:
                for line in rf:
                    print(
                        re.sub(
                            '"DisplayVersion"=".+"',
                            f'"DisplayVersion"="{PALIA_DISP_VER}"',
                            line,
                        )
                    ),

        return True
    return False


def file_hash(filename):
    sha256_hash = hashlib.sha256()
    with open(filename, "rb") as f:
        for byte_block in iter(lambda: f.read(4096), b""):
            sha256_hash.update(byte_block)
    return sha256_hash.hexdigest()


def validate_file(filename):
    sfn = Path(filename).name
    if not MANIFEST_HASHES:
        have_mani_hashes_changed()
    if not KNOWN_HASHES:
        load_known_hashes()
    logging.debug(f"Validating: {filename}")
    if not os.path.isfile(filename):
        logging.debug(f"Validation failed, not found: {filename}")
        return False
    shaHash = file_hash(filename)
    if sfn in MANIFEST_HASHES:
        if MANIFEST_HASHES[sfn]["Hash"] != shaHash:
            logging.debug(f"Validation failed, doesn't match manifest: {filename}")
            logging.debug(f"Expected hash: {MANIFEST_HASHES[sfn]['Hash']}")
            logging.debug(f"Actual hash: {shaHash}")
            return False
    elif get_hash_file_key(filename) in KNOWN_HASHES:
        if KNOWN_HASHES[get_hash_file_key(filename)] != shaHash:
            logging.debug(f"Validation failed, doesn't match known hashes: {filename}")
            return False
    else:
        logging.debug(f"Added to known hashes: {get_hash_file_key(filename)}")
        KNOWN_HASHES[get_hash_file_key(filename)] = shaHash
    logging.debug(f"Successfully validated: {filename}")
    return True


FILES_FROM_ZIP = {}
FAILED_REPLACEMENTS = {}


def get_mani_file_target(filename):
    cur_path = Path(filename)
    cur_ext = cur_path.suffix.lower()
    if cur_ext == ".exe":
        return f"{PALIA_BIN_PATH}/{cur_path.name}"
    elif cur_ext == ".pak":
        return f"{PALIA_PAK_PATH}/{cur_path.name}"
    else:
        logging.debug(f"Filename not found in manifest: {cur_path.name}")
        return ""


def get_hash_file_key(filename):
    return f"{filename}".removeprefix(f"{PALIA_CLIENT_PATH}/")


def get_hash_file_target(filename):
    cur_path = Path(filename)
    if cur_path.name in [PALIA_MANIFEST, PALIA_LAUNCHER_MANIFEST]:
        return filename
    else:
        return f"{PALIA_CLIENT_PATH}/{filename}"


def replace_file(filename, prog_text=None, zeni=None):
    if os.path.exists(filename):
        logging.debug(f"Replacing bad file: {filename}")
        os.remove(filename)
    else:
        logging.debug(f"Replacing missing file: {filename}")

    url = MANIFEST_HASHES.get(Path(filename).name, {"URL": ""})["URL"]
    if url == "":
        kh = KNOWN_HASHES.get(get_hash_file_key(filename), "")
        if kh == "":
            logging.debug(
                f"Unknown file, adding to hashes: {get_hash_file_key(filename)}"
            )
            return
        else:
            if Path(filename).name == PALIA_LAUNCHER_EXE:
                logging.debug(f"Must get from launcher zip: {get_hash_file_key(filename)}")
                validate_launcher()
            elif Path(filename).name == PALIA_LAUNCHER_MANIFEST:
                return
            else:
                if not BASE_HASHES:
                    load_base_hashes()
                if BASE_HASHES.get(get_hash_file_key(filename), "") == "":
                    logging.debug(f"Don't know where to get hashed file: {get_hash_file_key(filename)}")
                else:
                    logging.debug(f"Must get from zip: {get_hash_file_key(filename)}")
                    extract(
                        PALIA_BASE_VER_URL,
                        PALIA_CLIENT_PATH,
                        "Replacing File",
                        f"Downloading and extracting...\\n{Path(filename).name}",
                        get_hash_file_key(filename),
                    )
            return

    Path(filename).parent.mkdir(parents=True, exist_ok=True)
    drc = download_progress(
        url, filename, "Downloading...", f"{prog_text}{Path(filename).name}", zeni
    )
    if drc == 0:
        if not validate_file(filename):
            FAILED_REPLACEMENTS[filename] = url
    else:
        if drc == 1:
            logging.debug(f"User canceled download: {filename}")
            return drc
        logging.debug(f"Failed download: {filename}")
        FAILED_REPLACEMENTS[filename] = url


def validate_hashes(hashes, title, text):
    zenity = Popen(
        [
            "zenity",
            "--progress",
            "--percentage=0",
            "--time-remaining",
            f"--title={title}",
            f"--text={text}",
            "--width=350",
        ],
        text=True,
        stdin=PIPE,
        stdout=PIPE,
    )
    fcount = 0
    for f in hashes.keys():
        fcount = fcount + 1
        zenity.stdin.write(
            f"# {text}{ round(float(fcount)/float(len(hashes)) * 100,1) }%\\nChecking file:\\n{Path(f).name}\\nPlease wait...\n"
        )
        zenity.stdin.write(
            f"{ round(float(fcount)/float(len(hashes)) * 100,1) }%\\n\\n\n"
        )
        if zenity.poll() != None:
            sys.exit(zenity.returncode)
        zenity.stdin.flush()
        if not validate_file(f):
            if zenity.poll() != None:
                sys.exit(zenity.returncode)
            if (
                replace_file(
                    f,
                    f"{text}{ round(float(fcount)/float(len(hashes)) * 100,1) }%\\nDownloading file:\\n",
                    zenity,
                )
                == 1
            ):
                zenity.terminate()
                sys.exit()
    zenity.terminate()


def validate_launcher():
    if not KNOWN_HASHES:
        load_known_hashes()
    download(PALIA_LAUNCHER_MANIFEST_URL, PALIA_LAUNCHER_MANIFEST)
    manifest_hash_new = file_hash(f"{os.getcwd()}/{PALIA_LAUNCHER_MANIFEST}")
    if KNOWN_HASHES.get(PALIA_LAUNCHER_MANIFEST, "") != manifest_hash_new or (
        os.path.isfile(PALIA_LAUNCHER)
        and KNOWN_HASHES.get(PALIA_LAUNCHER_EXE, "") != file_hash(PALIA_LAUNCHER)
    ):
        with open(PALIA_LAUNCHER_MANIFEST, "r") as mf:
            mani = json.load(mf)
        launcherurl = mani["url"]
        download_progress(
            launcherurl,
            PALIA_LAUNCHER_ZIP,
            "Validate Palia Launcher",
            "Downloading New Launcher Version",
        )
        extract(
            PALIA_LAUNCHER_ZIP,
            PALIA_LAUNCHER_PATH,
            "Validate Palia Launcher",
            "Installing New Launcher Version",
            PALIA_LAUNCHER_EXE,
        )
        os.remove(PALIA_LAUNCHER_ZIP)
        KNOWN_HASHES[PALIA_LAUNCHER_EXE] = file_hash(PALIA_LAUNCHER)
        KNOWN_HASHES[PALIA_LAUNCHER_MANIFEST] = manifest_hash_new
        save_known_hashes()
    os.remove(PALIA_LAUNCHER_MANIFEST)


def guarantee_known_hashes():
    if len(KNOWN_HASHES) <= 2:
        logging.debug(f"No known hashes found, downloading from github.")
        # get_base_zip()
        download(f"{PSH_REPO}/{KNOWN_HASH_FILE}", KNOWN_HASH_FILE)
        # download_progress(
        #     f"{PSH_REPO}/{KNOWN_HASH_FILE}",
        #     KNOWN_HASH_FILE,
        #     "Palia Known Hashes",
        #     "Downloading known hashes from Github...",
        # )
        load_known_hashes()


def mani_files_missing():
    if not Path(PALIA_CLIENT_PATH).exists:
        return True
    if not MANIFEST_HASHES:
        have_mani_hashes_changed()
    for (f,h) in MANIFEST_HASHES.items():
        if not Path(get_mani_file_target(f)).exists:
            logging.debug(f"File from manifest missing: {f}")
            return True
    return False


def base_files_missing():
    if not Path(PALIA_CLIENT_PATH).exists:
        return True
    if not BASE_HASHES:
        load_base_hashes()
    for (f,h) in BASE_HASHES.items():
        if not Path(get_hash_file_target(f)).exists:
            logging.debug(f"Base file missing: {f}")
            return True
    return False


def validate_all_files():
    logging.debug(f"Validating all files...")
    if not Path(PALIA_CLIENT_PATH).exists:
        get_base_zip()
    guarantee_known_hashes()
    validate_hashes(
        {get_hash_file_target(f): h for f, h in KNOWN_HASHES.items()},
        "Validate Base Files",
        "Checking Palia Base Files...\\nTotal progress: ",
    )
    if not MANIFEST_HASHES:
        have_mani_hashes_changed()
    validate_hashes(
        {get_mani_file_target(f): h["Hash"] for f, h in MANIFEST_HASHES.items()},
        "Validate/Download Update Files",
        "Checking/Downloading Palia Update Files...\\nTotal progress: ",
    )
    save_known_hashes()


def get_base_zip():
    logging.debug(f"Make client path.")
    Path(PALIA_CLIENT_PATH).parent.mkdir(parents=True, exist_ok=True)
    logging.debug(f"Extract base from web.")
    rs = extract(
        PALIA_BASE_VER_URL,
        PALIA_CLIENT_PATH,
        "Installing Palia",
        "Downloading and extracting base game files...",
    )
    if rs != 0:
        sys.exit(rs)
    # rs = download_progress(PALIA_BASE_VER_URL, PALIA_BASE_VER_ZIP, "Palia Base Game Files", "Downloading base Palia version...")
    # if rs != 0:
    #     sys.exit(rs)
    # os.makedirs(f"{PALIA_ROOT}/Client", exist_ok = True)
    # rs = extract(PALIA_BASE_VER_ZIP, f"{PALIA_ROOT}/Client/", "Installing Palia", "Extracting base game files...")
    # if rs != 0:
    #     sys.exit(rs)
    # os.remove(PALIA_BASE_VER_ZIP)


def launch_palia():
    if have_mani_hashes_changed():
        logging.debug(f"Manifest file has changed!")
        validate_all_files()
    elif len(KNOWN_HASHES) <= 2:
        logging.debug(f"Known hashes is empty!")
        validate_all_files()
    elif mani_files_missing():
        logging.debug(f"Some manifest files are missing!")
        validate_all_files()
    elif base_files_missing():
        logging.debug(f"Some base files are missing!")
        validate_all_files()
    validate_launcher()
    validate_registry()
    with Popen(
        ["proton", "run", f"{PALIA_LAUNCHER}"], text=True, stdout=PIPE, stderr=STDOUT
    ) as palia_proc:
        logging.debug(palia_proc.stdout.read())
    run(
        [
            "proton",
            "run",
            f"reg query HKEY_CLASSES_ROOT\\Installer\\Products\\A12B171E85ADD2347AB41DB302B44A77",
        ]
    )

def validate_registry():
    needs_reg_def = 2
    if os.path.isfile(USER_REG):
        with FileInput(USER_REG, inplace=True, backup=".bak") as rf:
            for line in rf:
                if re.search('"DisplayVersion"=".+"', line) != None:
                    needs_reg_def -= 1
                    logging.debug(f"Found Palia display version in registry: {line}")
                    logging.debug(f"Making sure it's set to: {PALIA_DISP_VER}")
                    print(
                        re.sub(
                            '"DisplayVersion"=".+"',
                            f'"DisplayVersion"="{PALIA_DISP_VER}"',
                            line,
                        )
                    ),
                elif re.search('"PaliaPatchVersion"=".+"', line) != None:
                    needs_reg_def -= 1
                    logging.debug(f"Found Palia patch version in registry: {line}")
                    logging.debug(f"Making sure it's set to: {PALIA_DISP_VER}")
                    print(
                        re.sub(
                            '"PaliaPatchVersion"=".+"',
                            f'"PaliaPatchVersion"="{PALIA_DISP_VER}"',
                            line,
                        )
                    ),
                else:
                    print(
                        line
                    ),
    if needs_reg_def > 0:
        logging.debug("Palia not valid in registry...")
        load_reg_defaults()

def write_reg_file():
    rf = open(REGFILE, "w")
    rf.write(
        f"""Windows Registry Editor Version 5.00
    [HKEY_CLASSES_ROOT\\Installer\\Products\\A12B171E85ADD2347AB41DB302B44A77]
    "PackageCode"="BB3908D00C04BD54FBD8A0D013C6B052"
    "ProductName"="UE Prerequisites (x64)"
    [HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\Palia]
    "DisplayIcon"="C:\\\\users\\\\steamuser\\\\AppData\\\\Local\\\\Palia\\\\Launcher\\\\PaliaLauncher.exe"
    "DisplayName"="Palia"
    "DisplayVersion"="{PALIA_DISP_VER}"
    "EstimatedSize"=dword:00000001
    "InstallDate"="20230801"
    "InstallLocation"="C:\\\\users\\\\steamuser\\\\AppData\\\\Local\\\\Palia"
    "NoModify"=dword:00000001
    "NoRepair"=dword:00000001
    "Publisher"="Singularity 6 Corporation"
    "UninstallString"="C:\\\\users\\\\steamuser\\\\AppData\\\\Local\\\\Palia\\\\Launcher\\\\PaliaLauncher.exe uninstall"
    "X-BaseVersion"="{PALIA_BASE_VER}"
    "X-Entry"="Palia.exe"
    "X-NdaAcceptedVersion"=dword:00000001
    "X-PatchMethod"="pak"
    [Software\\Singularity6]
    "PaliaPatchVersion"="{PALIA_DISP_VER}"
    """
    )
    rf.close()


def load_reg_defaults():
    logging.debug("Loading registry defaults...")
    write_reg_file()
    rf = open(REGBATFILE, "w")
    rf.write(
        f"""@echo off
    regedit regimport.reg
    reg query HKEY_CLASSES_ROOT\\Installer\\Products\\A12B171E85ADD2347AB41DB302B44A77
    """
    )
    rf.close()
    run(["proton", "run", f"{REGBATFILE}"])
    os.remove(REGBATFILE)
    os.remove(REGFILE)


try:
    if os.path.isfile(PALIA_LAUNCHER) == True:
        logging.debug("Existing installation found, trying to launcher Palia now...")
        launch_palia()
        sys.exit(0)

    logging.debug("Did not find existing installation, starting new install...")

    notice = open(NOTICEFILE, "w")
    notice.write(
        """This script/launcher is not provided by or affiliated with Singularity 6 in any way.
    Use this at your own risk.

    Due to an issue with the PaliaLauncher under Wine, and to simplify the process, this installer will skip the EULA agreement page.

    !! By running this script you agree to abide by the EULA and Terms and Conditions as laid out in the official Palia installer, as well as the one from the official Palia website at:
    https://palia.com/terms"""
    )
    notice.close()
    nr = run(
        [
            "zenity",
            "--text-info",
            "--title=Important Notice",
            f"--filename={NOTICEFILE}",
            "--width=600",
            "--height=400",
        ]
    )
    os.remove(NOTICEFILE)
    if nr.returncode != 0:
        sys.exit(nr.returncode)

    have_mani_hashes_changed()

    rs = download_progress(
        VCREDIST_URL, VCREDIST, "Installing Palia", "Downloading VC Redist..."
    )
    if rs != 0:
        sys.exit(rs)

    zenity = Popen(
        [
            "zenity",
            "--progress",
            "--percentage=0",
            "--time-remaining",
            f'--title="Installing Palia"',
            f"--text=Prepping Wine environment...",
            "--width=350",
        ],
        text=True,
        stdin=PIPE,
        stdout=PIPE,
    )
    if zenity.poll() != None:
        sys.exit(zenity.returncode)
    zenity.stdin.write("# Importing registry changes...\n")
    zenity.stdin.write("40\n")
    zenity.stdin.flush()

    load_reg_defaults()

    os.makedirs(f"{PALIA_ROOT}/Launcher/Downloads", exist_ok=True)
    if zenity.poll() != None:
        sys.exit(zenity.returncode)
    zenity.stdin.write("# Installing VC Redist...\n")
    zenity.stdin.write("60\n")
    zenity.stdin.flush()
    if zenity.poll() != None:
        sys.exit(zenity.returncode)
    run(["proton", "run", "vc_redist.x64.exe", "/q"])
    zenity.stdin.write("100\n")
    zenity.stdin.flush()
    zenity.terminate()

    get_base_zip()

    launch_palia()

except Exception as Argument:
    logging.exception(f"Error launching Palia:\n{str(Argument)}")
