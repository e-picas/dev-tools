#!/bin/bash
# 
# action for ../deploy.sh
#

ACTION_DESCRIPTION="Will search for files suffixed by '__ENV__' in 'path' and over-write the original ones (without suffix).\n\
\t\t<bold>--set=ENV</bold>\tthe environment shortcut to deploy (default is 'DEFAULT')";
if $SCRIPTMAN; then return; fi

targetdir_required
TARGETENV='default'

OPTIND=1
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

verecho "> deploying files with '$SUFFIX' suffix in '$_TARGET' ..."
iexec "find \"$_TARGET\" -name \"*${SUFFIX}\" -exec sh -c 'cp -v \"\$1\" \"\${1%%\$2}\"' _ {} \"$SUFFIX\" \;"
verecho "_ ok"

# Endfile
