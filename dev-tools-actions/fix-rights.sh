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

ACTION_DESCRIPTION="This will fix files and directories UNIX rights recursively on the project.";
ACTION_OPTIONS="<bold>--dirs=CHMOD</bold>\tthe rights level setted for directories (default is '0755' - config var: 'DEFAULT_FIXRIGHTS_DIRS_CHMOD') \n\
\t<bold>--files=CHMOD</bold>\tthe rights level setted for files (default is '0644' - config var: 'DEFAULT_FIXRIGHTS_FILES_CHMOD') \n\
\t<bold>--bin=PATH</bold>\tdirname of the binaries, to define their rights on 'a+x' (default is 'bin/' - config var: 'DEFAULT_FIXRIGHTS_BIN_DIR')\n\
\t<bold>--bin-mask=MASK</bold>\tmask to match binary files in 'bin' (default is empty - config var: 'DEFAULT_FIXRIGHTS_BIN_MASK')";
ACTION_SYNOPSIS="[--files=chmod]  [--dirs=chmod]  [--bin=path]  [--bin-mask=mask]"
ACTION_CFGVARS=( DEFAULT_FIXRIGHTS_BIN_MASK DEFAULT_FIXRIGHTS_BIN_DIR DEFAULT_FIXRIGHTS_FILES_CHMOD DEFAULT_FIXRIGHTS_DIRS_CHMOD )
if $SCRIPTMAN; then return; fi

targetdir_required

if [ -z $DEFAULT_FIXRIGHTS_DIRS_CHMOD ]; then
    error "Configuration var 'DEFAULT_FIXRIGHTS_DIRS_CHMOD' not found !"
fi
DIRS_CHMOD=$DEFAULT_FIXRIGHTS_DIRS_CHMOD
if [ -z $DEFAULT_FIXRIGHTS_FILES_CHMOD ]; then
    error "Configuration var 'DEFAULT_FIXRIGHTS_FILES_CHMOD' not found !"
fi
FILES_CHMOD=$DEFAULT_FIXRIGHTS_FILES_CHMOD
if [ -z $DEFAULT_FIXRIGHTS_BIN_DIR ]; then
    error "Configuration var 'DEFAULT_FIXRIGHTS_BIN_DIR' not found !"
fi
BIN_DIR=$DEFAULT_FIXRIGHTS_BIN_DIR

BIN_MASK=""
if [ ! -z $DEFAULT_FIXRIGHTS_BIN_MASK ]; then
    BIN_MASK="$DEFAULT_FIXRIGHTS_BIN_MASK"
fi

OPTIND=1
options=$(getscriptoptions "$@")
while getopts "${COMMON_OPTIONS_ARGS}" OPTION $options; do
    OPTARG="${OPTARG#=}"
    case $OPTION in
        -) LONGOPTARG="`getlongoptionarg \"${OPTARG}\"`"
            case $OPTARG in
                dirs*) DIRS_CHMOD=$LONGOPTARG;;
                files*) FILES_CHMOD=$LONGOPTARG;;
                bin*) BIN_DIR=$LONGOPTARG;;
                bin-mask*) BIN_MASK=$LONGOPTARG;;
                \?) ;;
            esac ;;
        \?) ;;
    esac
done

_TARGET=$(realpath "$_TARGET")
_TARGET_BIN=$(realpath "${_TARGET}/${BIN_DIR}")

verecho "> fixing rights in '$_TARGET' ..."
iexec "find ${_TARGET} -type d -exec chmod ${DIRS_CHMOD} {} \;"
iexec "find ${_TARGET} -type f -exec chmod ${FILES_CHMOD} {} \;"
if [ -d "${_TARGET}/${BIN_DIR}" ]; then
    if [ ! -z $BIN_MASK ]; then
        iexec "find ${_TARGET_BIN} -type f -name \"${BIN_MASK}\" -exec chmod a+x {} \;"
    else
        iexec "find ${_TARGET_BIN} -type f -exec chmod a+x {} \;"
    fi
fi
verecho "_ ok"

# Endfile
