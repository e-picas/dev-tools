#!/bin/bash
# 
# action for ../deploy.sh
#

filename='.devtools'

ACTION_DESCRIPTION="Manage the deploy facilities configuration for a package (stored in '$filename') ; with no option, current config will be shown ; to read or define a value, use:\n\
\t\t<bold>--config-var=NAME</bold>\tselect a configuration variable\n\
\t\t<bold>--config-val=VALUE</bold>\tdefine a configuration variable value\n\
\t\t<bold>--config-file</bold>\t\tsee current configuration file path";
ACTION_SYNOPSIS="[--config-var=name] [--config-val=value] [--config-file]"
if $SCRIPTMAN; then return; fi

targetdir_required
filepath="${_TARGET}/$filename"

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
                config-var*) CFGVAR=$LONGOPTARG && CFGACTION='get';;
                config-val*) CFGVAL=$LONGOPTARG && CFGACTION='set';;
                config-file) CFGACTION='file';;
                \?) ;;
            esac ;;
        \?) ;;
    esac
done

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
