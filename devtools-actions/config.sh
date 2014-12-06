#!/usr/bin/env bash
# 
# Dev-Tools - Packages development & deployment facilities
# Copyleft (C) 2013-2014 Pierre Cassat & contributors
# <http://github.com/atelierspierrot/dev-tools>
# <www.ateliers-pierrot.fr> - <contact@ateliers-pierrot.fr>
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# action for Dev-Tools
#

ACTION_NAME="Configuration tool"
ACTION_VERSION="1.0.0-alpha"
ACTION_DESCRIPTION="Manage the deploy facilities configuration for a package (stored in '${DEFAULT_PROJECT_CONFIG_FILE}' or '${DEFAULT_USER_CONFIG_FILE}') ; with no option, current config will be shown.";
ACTION_ALLOWED_OPTIONS=""
ACTION_ALLOWED_LONG_OPTIONS="filename,global,var:,val:,full"
ACTION_OPTIONS="--global\twork with the global user configuration (in 'HOME/$DEFAULT_USER_CONFIG_FILE' file)\n\
\t--var\t=NAME\tselect a configuration variable to read or define\n\
\t--val\t=VALUE\tdefine a configuration variable value (requires the '--var' option to be defined)\n\
\t--filename\tsee current configuration file path for the project\n\
\t--full\t\tsee the full configuration entries for the project (defaults, user and custom)";
ACTION_SYNOPSIS="[--global]  [--var=name]  [--val=value]  [--filename]  [--full]"
if $SCRIPTMAN; then return; fi

CFG_FILE="$DEFAULT_PROJECT_CONFIG_FILE"
CFG_FILEPATH="${_TARGET}/${DEFAULT_PROJECT_CONFIG_FILE}"
CFGVAR=''
CFGVAL=''
CFGACTION='read'

OPTIND=1
while getopts ":${OPTIONS_ALLOWED}" OPTION; do
    OPTARG="${OPTARG#=}"
    case "$OPTION" in
        -) LONGOPTARG="$(get_long_option_arg "$OPTARG")"
            case "$OPTARG" in
                path*|help|man|usage|vers*|interactive|verbose|force|debug|dry-run|quiet|libvers) ;;
                global)
                    CFG_FILE="${DEFAULT_USER_CONFIG_FILE}"
                    CFG_FILEPATH="${HOME}/${DEFAULT_USER_CONFIG_FILE}"
                    ;;
                var*) CFGVAR="$LONGOPTARG" && CFGACTION='get';;
                val*) CFGVAL="$LONGOPTARG" && CFGACTION='set';;
                filename) CFGACTION='file';;
                full) CFGACTION='readfull';;
                *) simple_error "Unkown option '${OPTARG#=*}'";;
            esac ;;
        \?) ;;
    esac
done

_TARGET=$(realpath "$_TARGET")
filepath=$(realpath "$CFG_FILEPATH")

if [ ! -z "$CFGACTION" ]
then
    case "$CFGACTION" in
        read)
            verecho "Reading config file '${filepath}':"
            if [ -f "$filepath" ]; then
                cat "$filepath"
            else
                echo "No configuration file found"
            fi
            ;;
        readfull)
            tmpconfigfile=$(get_tempfile_path "$(basename "$_TARGET")${CFG_FILE}")
            sed -e '/^#/d' -e '/^$/d' "$CFGFILE" > "$tmpconfigfile"
            if [ -f "$filepath" ]; then
                while read p; do
                    CFGVAR="${p%=*}"
                    CFGVAL="${p#*=}"
                    set_configval "$tmpconfigfile" "$CFGVAR" "$CFGVAL"
                done < "${filepath}"
            fi
            verecho "Reading merged default config with config file '${filepath}':"
            if [ -f "$tmpconfigfile" ]; then
                cat "$tmpconfigfile"
            else
                echo "No configuration file found"
            fi
            ;;
        file)
            echo "$filepath"
            ;;
        get)
            verecho "Getting config value '${CFGVAR}' from config file '${filepath}':"
            iexec "get_configval ${filepath} ${CFGVAR}"
            ;;
        set)
            verecho "Setting value '${CFGVAR}=${CFGVAL}' in config file '${filepath}':"
            iexec "set_configval ${filepath} ${CFGVAR} ${CFGVAL}"
            verecho "_ ok"
            ;;
    esac
fi

# Endfile
