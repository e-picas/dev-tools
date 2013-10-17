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

ACTION_DESCRIPTION="Will 'rsync' a project directory to a target, which can use SSH protocol if so ; use the '-x' option to process a '--dry-run' rsync \n\
\t\t<bold>--target=SERVER</bold>\t\t\tthe server name to use for synchronization (config var: 'DEFAULT_SYNC_SERVER') \n\
\t\t<bold>--options=\"RSYNC OPTIONS\"</bold>\tan options string used for the 'rsync' command (config var: 'DEFAULT_SYNC_RSYNC_OPTIONS') \n\
\t\t<bold>--env=ENV</bold>\t\t\tthe environment shortcut to deploy if so (config var: 'DEFAULT_SYNC_ENV')";
ACTION_SYNOPSIS="[--env=env] [--target=server] [--options=\"rsync options\"]"
ACTION_CFGVARS=( DEFAULT_SYNC_SERVER DEFAULT_SYNC_RSYNC_OPTIONS DEFAULT_SYNC_ENV )
if $SCRIPTMAN; then return; fi

targetdir_required
TARGETENV=false
TARGETSERVER=""
RSYNC_OPTIONS=""

if [ ! -z "$DEFAULT_SYNC_SERVER" ]; then
    TARGETSERVER="$DEFAULT_SYNC_SERVER"
fi
if [ ! -z "$DEFAULT_SYNC_RSYNC_OPTIONS" ]; then
    RSYNC_OPTIONS="$DEFAULT_SYNC_RSYNC_OPTIONS"
fi
if [ ! -z "$DEFAULT_SYNC_ENV" ]; then
    TARGETENV="$DEFAULT_SYNC_ENV"
fi

OPTIND=1
options=$(getscriptoptions "$*")
while getopts "${COMMON_OPTIONS_ARGS}" OPTION $options; do
    OPTARG="${OPTARG#=}"
    case $OPTION in
        -) LONGOPTARG="`getlongoptionarg \"${OPTARG}\"`"
            case $OPTARG in
                env*) TARGETENV=$LONGOPTARG;;
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
    rsync --dry-run $RSYNC_OPTIONS $_TARGET $TARGETSERVER
else
    iexec "rsync $RSYNC_OPTIONS $_TARGET $TARGETSERVER"
fi
if [ ! -z "$TARGETENV" ]; then
    SUFFIX="__`echo ${TARGETENV} | tr '[:lower:]' '[:upper:]'`__"
    verecho "> deploying files with '$SUFFIX' suffix ..."
    if $DEBUG; then
        iexec "find \"$_TARGET\" -name \"*${SUFFIX}\" -exec sh -c 'destfile=\"\${1%%\$2}\" && destfilepath=\$(echo \"\$destfile\" | sed \"s!${_TARGET}!${TARGETSERVER}!\") && rsync $RSYNC_OPTIONS --dry-run --no-R --no-implied-dirs \"\$1\" \"\$destfilepath\"' _ {} \"$SUFFIX\" \;"
    else
        iexec "find \"$_TARGET\" -name \"*${SUFFIX}\" -exec sh -c 'destfile=\"\${1%%\$2}\" && destfilepath=\$(echo \"\$destfile\" | sed \"s!${_TARGET}!${TARGETSERVER}!\") && rsync $RSYNC_OPTIONS --no-R --no-implied-dirs \"\$1\" \"\$destfilepath\"' _ {} \"$SUFFIX\" \;"
    fi
fi
verecho "_ ok"

# Endfile
