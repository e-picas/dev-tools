#!/usr/bin/env bash
# 
# Dev-Tools - Packages development & deployment facilities
# Copyleft (C) 2013-2014 Pierre Cassat & contributors
# <http://github.com/piwi/dev-tools>
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

ACTION_NAME="Extract"
ACTION_VERSION="1.0.0-dev"
ACTION_DESCRIPTION="Will search and extract strings from files contents recursively ; result is written on STDOUT but can be stored in a file.";
ACTION_ALLOWED_OPTIONS=""
ACTION_ALLOWED_LONG_OPTIONS="begin:,end:,output:,show-filename"
ACTION_OPTIONS="--begin\t\t=MASK\t\tthe mask to use to begin the matching\n\t\t\t\t\tconfig var: 'DEFAULT_EXTRACT_BEGIN_MASK'\n\
\t--end\t\t=MASK\t\tthe mask to use to end the matching\n\t\t\t\t\tconfig var: 'DEFAULT_EXTRACT_END_MASK'\n\
\t--output\t=FILENAME\ta filename to write results in (this will overwrite any existing file)\n\
\t--show-filename\t\t\twrite matching filenames before extracted content\n\t\t\t\t\tconfig var: 'DEFAULT_EXTRACT_SHOW_FILENAME'";
ACTION_SYNOPSIS="[--begin=mask]  [--end=mask]  [--output=filename]  [--show-filename]"
ACTION_CFGVARS=( DEFAULT_EXTRACT_BEGIN_MASK DEFAULT_EXTRACT_END_MASK DEFAULT_EXTRACT_SHOW_FILENAME )
if [ "$SCRIPTMAN" = 'true' ]; then return; fi

BEGIN=""
END=""
OUTPUT=""
SHOW_FILENAME=false

if [ ! -z "$DEFAULT_EXTRACT_BEGIN_MASK" ]; then
    BEGIN="$DEFAULT_EXTRACT_BEGIN_MASK"
fi
if [ ! -z "$DEFAULT_EXTRACT_END_MASK" ]; then
    END="$DEFAULT_EXTRACT_END_MASK"
fi
if [ ! -z "$DEFAULT_EXTRACT_SHOW_FILENAME" ]; then
    SHOW_FILENAME="$DEFAULT_EXTRACT_SHOW_FILENAME"
fi

OPTIND=1
while getopts ":${OPTIONS_ALLOWED}" OPTION; do
    OPTARG="${OPTARG#=}"
    case "$OPTION" in
        -) LONGOPTARG="$(get_long_option_arg "$OPTARG")"
            case "$OPTARG" in
                path*|help|man|usage|vers*|interactive|verbose|force|debug|dry-run|quiet|libvers) ;;
                begin*) BEGIN="$LONGOPTARG";;
                end*) END="$LONGOPTARG";;
                output*) OUTPUT="$LONGOPTARG";;
                show-filename*) SHOW_FILENAME=true;;
                *) simple_error "Unkown option '${OPTARG#=*}'";;
            esac ;;
        \?) ;;
    esac
done

if [ -z "$BEGIN" ]; then
    simple_error "No mask defined to begin matching !\n\tuse the '--begin' option or the 'DEFAULT_EXTRACT_BEGIN_MASK' configuration var"
fi
if [ -z "$END" ]; then
    simple_error "No mask defined to end matching !\n\tuse the '--end' option or the 'DEFAULT_EXTRACT_END_MASK' configuration var"
fi

verecho "> extracting from '${_TARGET}' between '${BEGIN}' and '${END}' ..."
if [ ! -z "$OUTPUT" ] && [ -f "$OUTPUT" ]; then
    rm "$OUTPUT"
fi
for f in $(find "$_TARGET" -type f -name "*.php" | xargs grep -l "$BEGIN" 2> /dev/null); do
    if [ "$SHOW_FILENAME" = 'true' ]; then
        if [ ! -z "$OUTPUT" ]; then
            echo "$f" >> "$OUTPUT"
        else
            echo "$f"
        fi
    fi
    if [ ! -z "$OUTPUT" ]; then
        sed -n -e "/${BEGIN}/,/${END}/p" "$f" >> "$OUTPUT"
    else
        sed -n -e "/${BEGIN}/,/${END}/p" "$f"
    fi
done
if [ ! -z "$OUTPUT" ]; then
    echo "Results have been written to file '${OUTPUT}'"
fi
verecho "_ ok"

# Endfile
