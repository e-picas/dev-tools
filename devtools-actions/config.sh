#!/bin/bash
# 
# DevTools - Packages development & deployment facilities
# Copyleft (c) 2013 Pierre Cassat and contributors
# <www.ateliers-pierrot.fr> - <contact@ateliers-pierrot.fr>
# License GPL-3.0 <http://www.opensource.org/licenses/gpl-3.0.html>
# Sources <http://github.com/atelierspierrot/dev-tools>
# 
# action for Dev-Tools
#

ACTION_DESCRIPTION="Manage the deploy facilities configuration for a package (stored in '$DEFAULT_PROJECT_CONFIG_FILE' or '$DEFAULT_USER_CONFIG_FILE') ; with no option, current config will be shown.";
ACTION_OPTIONS="<bold>--global</bold>\twork with the global user configuration (in 'HOME/$DEFAULT_USER_CONFIG_FILE' file)\n\
\t<bold>--var=NAME</bold>\tselect a configuration variable to read or define\n\
\t<bold>--val=VALUE</bold>\tdefine a configuration variable value (requires the '--var' option to be defined)\n\
\t<bold>--filename</bold>\tsee current configuration file path for the project\n\
\t<bold>--full</bold>\t\tsee the full configuration entries for the project (defaults, user and custom)";
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
    case $OPTION in
        -) LONGOPTARG="`getlongoptionarg \"${OPTARG}\"`"
            case $OPTARG in
                project*|help|man|usage|vers*|interactive|verbose|force|debug|dry-run|quiet|libhelp|libvers|libdoc) ;;
                global)
                    CFG_FILE="$DEFAULT_USER_CONFIG_FILE"
                    CFG_FILEPATH="${HOME}/${DEFAULT_USER_CONFIG_FILE}"
                    ;;
                var*) CFGVAR=$LONGOPTARG && CFGACTION='get';;
                val*) CFGVAL=$LONGOPTARG && CFGACTION='set';;
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
            tmpconfigfile=$(gettempfilepath "`basename $_TARGET`$CFG_FILE")
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
