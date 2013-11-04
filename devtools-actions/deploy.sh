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

ACTION_DESCRIPTION="Will search for files suffixed by '__ENV__' in the project path and over-write the original ones (without suffix).";
ACTION_OPTIONS="<bold>--env=ENV</bold>\tthe environment shortcut to deploy (default is 'DEFAULT' - config var: 'DEFAULT_DEPLOY_ENV')";
ACTION_SYNOPSIS="[--env=env]"
ACTION_CFGVARS=( DEFAULT_DEPLOY_ENV )
if $SCRIPTMAN; then return; fi

if [ -z $DEFAULT_DEPLOY_ENV ]; then
    error "Configuration var 'DEFAULT_DEPLOY_ENV' not found !"
fi
TARGETENV=$DEFAULT_DEPLOY_ENV

OPTIND=1
while getopts ":${OPTIONS_ALLOWED}" OPTION; do
    OPTARG="${OPTARG#=}"
    case $OPTION in
        -) LONGOPTARG="`getlongoptionarg \"${OPTARG}\"`"
            case $OPTARG in
                path*|help|man|usage|vers*|interactive|verbose|force|debug|dry-run|quiet|libvers) ;;
                env*) TARGETENV=$LONGOPTARG;;
                *) simple_error "Unkown option '${OPTARG%=*}'";;
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
