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

ACTION_DESCRIPTION="This will fix files and directories UNIX rights recursively on the project.";
ACTION_OPTIONS="<bold>--dirs=CHMOD</bold>\tthe rights level setted for directories (default is '0755' - config var: 'DEFAULT_FIXRIGHTS_DIRS_CHMOD') \n\
\t<bold>--files=CHMOD</bold>\tthe rights level setted for files (default is '0644' - config var: 'DEFAULT_FIXRIGHTS_FILES_CHMOD') \n\
\t<bold>--bin=PATH</bold>\tdirname of the binaries, to define their rights on 'a+x' (default is 'bin/' - config var: 'DEFAULT_FIXRIGHTS_BIN_DIR')";
ACTION_SYNOPSIS="[--files=chmod] [--dirs=chmod] [--bin=path]"
ACTION_CFGVARS=( DEFAULT_FIXRIGHTS_BIN_DIR DEFAULT_FIXRIGHTS_FILES_CHMOD DEFAULT_FIXRIGHTS_DIRS_CHMOD )
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
    iexec "find ${_TARGET_BIN} -type f -exec chmod a+x {} \;"
fi
verecho "_ ok"

# Endfile
