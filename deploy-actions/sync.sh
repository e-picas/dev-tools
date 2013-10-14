#!/bin/bash
# 
# action for ../deploy.sh
#

ACTION_DESCRIPTION="Will 'rsync' a project directory to a target, which can use SSH protocol if so ; use the '-x' option to process a '--dry-run' rsync \n\
\t\t<bold>--target=SERVER</bold>\t\t\tthe server name to use for synchronization (config var: 'DEFAULT_SYNC_SERVER') \n\
\t\t<bold>--options=\"RSYNC OPTIONS\"</bold>\tan options string used for the 'rsync' command (config var: 'DEFAULT_RSYNC_OPTIONS') \n\
\t\t<bold>--set=ENV</bold>\t\t\tthe environment shortcut to deploy if so";
ACTION_SYNOPSIS="[--set=env] [--target=server] [--options=\"rsync options\"]"
if $SCRIPTMAN; then return; fi

targetdir_required
TARGETENV=false
TARGETSERVER=false
RSYNC_OPTIONS=""

if [ ! -z "$DEFAULT_SYNC_SERVER" ]; then
    TARGETSERVER="$DEFAULT_SYNC_SERVER"
fi
if [ ! -z "$DEFAULT_RSYNC_OPTIONS" ]; then
    RSYNC_OPTIONS="$DEFAULT_RSYNC_OPTIONS"
fi

OPTIND=1
options=$(getscriptoptions "$*")
while getopts "${COMMON_OPTIONS_ARGS}" OPTION $options; do
    OPTARG="${OPTARG#=}"
    case $OPTION in
        -) LONGOPTARG="`getlongoptionarg \"${OPTARG}\"`"
            case $OPTARG in
                set*) TARGETENV=$LONGOPTARG;;
                target*) TARGETSERVER=$LONGOPTARG;;
                options*) RSYNC_OPTIONS=$LONGOPTARG;;
                \?) ;;
            esac ;;
        \?) ;;
    esac
done

if [ ! $TARGETSERVER 2&> /dev/null ] || [ -z "$TARGETSERVER" ]; then
    error "No target defined for the synchronization ! (use the '--target' option or the 'DEFAULT_SYNC_SERVER' configuration var)"
fi

verecho "> syncing '$_TARGET' to '${TARGETSERVER}' ..."
if $DEBUG; then
    iexec "rsync --dry-run $RSYNC_OPTIONS $_TARGET $TARGETSERVER"
else
    iexec "rsync $RSYNC_OPTIONS $_TARGET $TARGETSERVER"
fi
verecho "_ ok"

# Endfile
