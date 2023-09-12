#!/usr/bin/env python3

# Author:    Madalee
# Purpose:   Python based interface to get/set the Compatability Tool for a game.
# Arguments: --help to see argument detail

import argparse
import re
import shutil

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
	vdf_file = open(config_file)
	vdf_str = vdf_file.read()
	vdf_file.close()
	return vdf_str

config_vdf = load_config_vdf()

def update_config_vdf( vdf = load_config_vdf(), config_file = args.config ):
	shutil.move(config_file, f"{config_file}.psh_bak")
	with open(config_file, "w") as vdf_file:
		vdf_file.write(vdf)

def get_by_id( gid, config_file = args.config, vdf = config_vdf ):
	m = re.search( r'"CompatToolMapping"\W+{.+?"' + re.escape(gid) + r'"\W+{\W+"name"\W+"([^"]*)"\W+"config"\W+"[^"]*"\W+"priority"\W+"[^"]*"\W+}.+?}', vdf, flags=re.DOTALL | re.MULTILINE | re.IGNORECASE )
	return m.group(0)

def set_by_id( gid, value = None, config_file = args.config, vdf = config_vdf ):
	newctm = f'''
				"CompatToolMapping"
				{{
					"{gid}"
					{{
						"name"		"{value}"
						"config"		""
						"priority"		"250"
					}}
				}}'''
	newgctm = f'''
					"{gid}"
					{{
						"name"		"{value}"
						"config"		""
						"priority"		"250"
					}}'''

	newvdf = vdf
	if re.search( r'"CompatToolMapping"', vdf, flags=re.DOTALL | re.MULTILINE | re.IGNORECASE ) == None:
		newvdf = re.sub( r'("Steam".+?)(\n\t\t\t})', rf'\1{newctm}\2', vdf, flags=re.DOTALL | re.MULTILINE | re.IGNORECASE )
	else:
		if re.search( r'"CompatToolMapping"\W+{.+?"' + re.escape(gid) + r'"\W+{\W+"name"\W+"proton_experimental"\W+"config"\W+""\W+"priority"\W+"250"\W+}.+?}', vdf, flags=re.DOTALL | re.MULTILINE | re.IGNORECASE ) == None:
			if re.search( r'"CompatToolMapping"\W+{.+?"' + re.escape(gid) + r'"\W+{\W+"name"\W+"[^"]*"\W+"config"\W+"[^"]*"\W+"priority"\W+"[^"]*"\W+}.+?}', vdf, flags=re.DOTALL | re.MULTILINE | re.IGNORECASE ) == None:
				newvdf = re.sub( r'("CompatToolMapping"\W+?{.*?)(\n\t\t\t\t})', rf"\1{newgctm}\2", vdf, flags=re.DOTALL | re.MULTILINE | re.IGNORECASE )
			else:
				newvdf = re.sub( r'("CompatToolMapping"\W+?{.*?)\n\t\t\t\t\t"' + re.escape(gid) + r'"\W+?{\W+?"name"\W+?"[^"]*"\W+?"config"\W+?"[^"]*"\W+?"priority"\W+?"[^"]*"\W+?}(.+?})', rf"\1{newgctm}\2", vdf, flags=re.DOTALL | re.MULTILINE | re.IGNORECASE )
	if newvdf != vdf:
		update_config_vdf(newvdf, config_file)
	 

if args.new_value is None and args.remove == False:
	get_by_id( args.id )
else:
	set_by_id( args.id, None if args.remove else args.new_value )
