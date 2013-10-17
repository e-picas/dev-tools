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

ACTION_DESCRIPTION="Will search for files suffixed by '__ENV__' in the project path and over-write the original ones (without suffix).";
ACTION_OPTIONS="<bold>--env=ENV</bold>\tthe environment shortcut to deploy (default is 'DEFAULT' - config var: 'DEFAULT_DEPLOY_ENV')";
ACTION_SYNOPSIS="[--env=env]"
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
                env*) TARGETENV=$LONGOPTARG;;
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
