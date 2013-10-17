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

filename="$DEFAULT_CONFIG_FILE"

ACTION_DESCRIPTION="Manage the deploy facilities configuration for a package (stored in '$filename') ; with no option, current config will be shown ; to read or define a value, use:\n\
\t\t<bold>--var=NAME</bold>\tselect a configuration variable\n\
\t\t<bold>--val=VALUE</bold>\tdefine a configuration variable value\n\
\t\t<bold>--filename</bold>\tsee current configuration file path\n\
\t\t<bold>--full</bold>\t\tsee full configuration for the project (defaults and custom)";
ACTION_SYNOPSIS="[--var=name] [--val=value] [--filename] [--full]"
if $SCRIPTMAN; then return; fi

targetdir_required

CFGVAR=''
CFGVAL=''
CFGACTION='read'
OPTIND=1
options=$(getscriptoptions "$@")
while getopts "${COMMON_OPTIONS_ARGS}" OPTION $options; do
    OPTARG="${OPTARG#=}"
    case $OPTION in
        -) LONGOPTARG="`getlongoptionarg \"${OPTARG}\"`"
            case $OPTARG in
                var*) CFGVAR=$LONGOPTARG && CFGACTION='get';;
                val*) CFGVAL=$LONGOPTARG && CFGACTION='set';;
                filename) CFGACTION='file';;
                full) CFGACTION='readfull';;
                \?) ;;
            esac ;;
        \?) ;;
    esac
done

_TARGET=$(realpath "$_TARGET")
filepath=$(realpath "${_TARGET}/$filename")

if [ ! -z "$CFGACTION" ]
then
    case $CFGACTION in
        read)
            verecho "Reading config file '$filepath':"
            if [ -f "$filepath" ]; then
                cat $filepath
            else
                echo "No configuration file found"
            fi
            ;;
        readfull)
            tmpconfigfile=$(gettempfilepath "`basename $_TARGET`$filename")
            sed -e '/^#/d' -e '/^$/d' "$CFGFILE" > "$tmpconfigfile"
            if [ -f "$filepath" ]; then
                while read p; do
                    CFGVAR="${p%=*}"
                    CFGVAL="${p#*=}"
                    setconfigval "$tmpconfigfile" $CFGVAR "$CFGVAL"
                done < "$filepath"
            fi
            verecho "Reading merged default config with config file '$filepath':"
            if [ -f "$tmpconfigfile" ]; then
                cat $tmpconfigfile
            else
                echo "No configuration file found"
            fi
            ;;
        file)
            echo "$filepath"
            ;;
        get)
            verecho "Getting config value '$CFGVAR' from config file '$filepath':"
            iexec "getconfigval $filepath $CFGVAR"
            ;;
        set)
            verecho "Setting value '${CFGVAR}=${CFGVAL}' in config file '$filepath':"
            iexec "setconfigval $filepath $CFGVAR $CFGVAL"
            verecho "_ ok"
            ;;
    esac
fi

# Endfile
