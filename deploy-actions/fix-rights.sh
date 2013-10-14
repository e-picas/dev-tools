#!/bin/bash
# 
# action for ../deploy.sh
#

ACTION_DESCRIPTION="This will fix files and directories UNIX rights recursively on the project ; you can define: \n\
\t\t<bold>--dirs=CHMOD</bold>\tthe rights level setted for directories (default is '0755' - config var: 'DEFAULT_DIRS_CHMOD') \n\
\t\t<bold>--files=CHMOD</bold>\tthe rights level setted for files (default is '0644' - config var: 'DEFAULT_FILES_CHMOD')";
ACTION_SYNOPSIS="[--files=chmod] [--dirs=chmod]"
if $SCRIPTMAN; then return; fi

targetdir_required

if [ -z $DEFAULT_DIRS_CHMOD ]; then
    error "Configuration var 'DEFAULT_DIRS_CHMOD' not found !"
fi
DIRS_CHMOD=$DEFAULT_DIRS_CHMOD
if [ -z $DEFAULT_FILES_CHMOD ]; then
    error "Configuration var 'DEFAULT_FILES_CHMOD' not found !"
fi
FILES_CHMOD=$DEFAULT_FILES_CHMOD

OPTIND=1
options=$(getscriptoptions "$@")
while getopts "${COMMON_OPTIONS_ARGS}" OPTION $options; do
    OPTARG="${OPTARG#=}"
    case $OPTION in
        -) LONGOPTARG="`getlongoptionarg \"${OPTARG}\"`"
            case $OPTARG in
                dirs*) DIRS_CHMOD=$LONGOPTARG;;
                files*) FILES_CHMOD=$LONGOPTARG;;
                \?) ;;
            esac ;;
        \?) ;;
    esac
done

verecho "> fixing rights in '$_TARGET' ..."
iexec "find ${_TARGET} -type d -exec chmod ${DIRS_CHMOD} {} \;"
iexec "find ${_TARGET} -type f -exec chmod ${FILES_CHMOD} {} \;"
verecho "_ ok"

# Endfile
