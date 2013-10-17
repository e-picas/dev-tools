#!/bin/bash
# 
# DevTools - Packages development & deployment facilities
# Copyleft (c) 2013 Pierre Cassat and contributors
# <www.ateliers-pierrot.fr> - <contact@ateliers-pierrot.fr>
# License GPL-3.0 <http://www.opensource.org/licenses/gpl-3.0.html>
# Sources <https://github.com/atelierspierrot/dev-tools>
#
# action for ../deploy.sh
#

ACTION_DESCRIPTION="Will search and extract strings from files contents recursively ; result is written on STDOUT but can be stored in a file \n\
\t\t<bold>--begin=MASK</bold>\t\tthe mask to use to begin the matching (config var: 'DEFAULT_EXTRACT_BEGIN_MASK') \n\
\t\t<bold>--end=MASK</bold>\t\tthe mask to use to end the matching (config var: 'DEFAULT_EXTRACT_END_MASK') \n\
\t\t<bold>--output=FILENAME</bold>\ta filename to write results in (this will overwrite any existing file)\n\
\t\t<bold>--filename</bold>\t\twrite matching filenames before content";
ACTION_SYNOPSIS="[--begin=mask] [--end=mask] [--output=filename] [--filename]"
ACTION_CFGVARS=( DEFAULT_EXTRACT_BEGIN_MASK DEFAULT_EXTRACT_END_MASK DEFAULT_EXTRACT_SHOW_FILENAME )
if $SCRIPTMAN; then return; fi

targetdir_required
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
    SHOW_FILENAME=$DEFAULT_EXTRACT_SHOW_FILENAME
fi

OPTIND=1
options=$(getscriptoptions "$*")
while getopts "${COMMON_OPTIONS_ARGS}" OPTION $options; do
    OPTARG="${OPTARG#=}"
    case $OPTION in
        -) LONGOPTARG="`getlongoptionarg \"${OPTARG}\"`"
            case $OPTARG in
                begin*) BEGIN=$LONGOPTARG;;
                end*) END=$LONGOPTARG;;
                output*) OUTPUT=$LONGOPTARG;;
                filename*) SHOW_FILENAME=true;;
                \?) ;;
            esac ;;
        \?) ;;
    esac
done

if [ -z "$BEGIN" ]; then
    error "No mask defined to begin matching ! (use the '--begin' option or the 'DEFAULT_EXTRACT_BEGIN_MASK' configuration var)"
fi
if [ -z "$END" ]; then
    error "No mask defined to end matching ! (use the '--end' option or the 'DEFAULT_EXTRACT_END_MASK' configuration var)"
fi

verecho "> extracting from '$_TARGET' between '${BEGIN}' and '${END}' ..."
if [ ! -z $OUTPUT ] && [ -f "$OUTPUT" ]; then
    rm "$OUTPUT"
fi
for f in $(find "${_TARGET}" -type f -name *.php | xargs grep -l "$BEGIN" 2> /dev/null); do
    if $SHOW_FILENAME; then
        if [ ! -z $OUTPUT ]; then
            echo $f >> "$OUTPUT"
        else
            echo $f
        fi
    fi
    if [ ! -z $OUTPUT ]; then
        sed -n -e "/$BEGIN/,/$END/p" $f >> "$OUTPUT"
    else
        sed -n -e "/$BEGIN/,/$END/p" $f
    fi
done
if [ ! -z $OUTPUT ]; then
    echo "Results have been written to file '$OUTPUT'"
fi
verecho "_ ok"

# Endfile
