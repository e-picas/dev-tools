#!/bin/bash
# 
# action for ../deploy.sh
#

ACTION_DESCRIPTION="Will search for files suffixed by '__ENV__' in 'path' and over-write the original ones (without suffix).\n\
\t\t<bold>--set=ENV</bold>\tthe environment shortcut to deploy (default is 'DEFAULT' - config var: 'DEFAULT_DEPLOY_ENV')";
ACTION_SYNOPSIS="[--set=env]"
ACTION_CFGVARS=( DEFAULT_DEPLOY_ENV )
if $SCRIPTMAN; then return; fi

targetdir_required

if [ -z $DEFAULT_DEPLOY_ENV ]; then
    error "Configuration var 'DEFAULT_DEPLOY_ENV' not found !"
fi
TARGETENV=$DEFAULT_DEPLOY_ENV

OPTIND=1
options=$(getscriptoptions "$@")
while getopts "${COMMON_OPTIONS_ARGS}" OPTION $options; do
    OPTARG="${OPTARG#=}"
    case $OPTION in
        -) LONGOPTARG="`getlongoptionarg \"${OPTARG}\"`"
            case $OPTARG in
                set*) TARGETENV=$LONGOPTARG;;
                \?) ;;
            esac ;;
        \?) ;;
    esac
done
SUFFIX="__`echo ${TARGETENV} | tr '[:lower:]' '[:upper:]'`__"

_TARGET=$(realpath "$_TARGET")

verecho "> deploying files with '$SUFFIX' suffix in '$_TARGET' ..."
iexec "find \"$_TARGET\" -name \"*${SUFFIX}\" -exec sh -c 'cp -v \"\$1\" \"\${1%%\$2}\"' _ {} \"$SUFFIX\" \;"
verecho "_ ok"

# Endfile
