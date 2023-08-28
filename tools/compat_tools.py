#!/usr/bin/env python3

# Author:    Madalee
# Purpose:   Python based interface to get/set the Compatability Tool for a game.
# Arguments: --help to see argument detail

from valve_keyvalues_python.keyvalues import KeyValues
from collections import OrderedDict
import argparse

VDF_FILENAME = "config.vdf"

parser = argparse.ArgumentParser(description='Set/get Steam Compatability options for games, via the VDF file.')
parser.add_argument('id', metavar='SteamAppID',
                    help='The SteamAppID of the game to modify Compat options for.')
parser.add_argument('new_value', metavar='New Value', default=None,
                    help='Set compatability tool to this value')
parser.add_argument('-c', '--config', dest='config', default=VDF_FILENAME,
                    help='Specify the config.vdf file/location')
parser.add_argument('-r', '--remove', dest='remove', action='store_true', 
                    help='Specify the config.vdf file/location')

args = parser.parse_args()

def load_config_vdf( config_file = args.config ):
    return KeyValues(filename = config_file)

config_vdf = load_config_vdf()

def get_steam( vdf = config_vdf ):
    if vdf == None:
        vdf = load_config_vdf()
    return vdf["InstallConfigStore"]["Software"]["Valve"]["Steam"], vdf

def get_ctm( steam = None, vdf = config_vdf ):
    if steam == None:
        steam, vdf = get_steam(vdf)
    return steam.get("CompatToolMapping", OrderedDict()), vdf

def get_by_id( gid, default = None, ctm = None, vdf = config_vdf ):
    if ctm == None:
        ctm, vdf = get_ctm(vdf)
    return ctm.get( gid, default)

def update_config_vdf( ctm, vdf = load_config_vdf(), config_file = args.config ):
    vdf["InstallConfigStore"]["Software"]["Valve"]["Steam"]["CompatToolMapping"] = ctm
    vdf.write(config_file)

def set_by_id( gid, value = None, config_file = args.config, ctm = None, vdf = config_vdf ):
    if ctm == None:
        ctm, vdf = get_ctm( None, vdf )
    cur_compat = ctm.get( gid )
    if value == None:
        if cur_compat != None:
            del ctm[gid]
            update_config_vdf(ctm, vdf, config_file)
    else:
        new_compat = OrderedDict({
            'name' : value,
            'config' : '',
            'priority' : '250'
        })
        if cur_compat != None:
            new_compat = cur_compat.copy()
            new_compat['name'] = value
        if cur_compat is None or cur_compat["name"] != new_compat["name"]:
            ctm[gid] = new_compat
            update_config_vdf(ctm, vdf, config_file)

if args.new_value is None and args.remove == False:
    get_by_id( args.id )
else:
    set_by_id( args.id, None if args.remove else args.new_value )
