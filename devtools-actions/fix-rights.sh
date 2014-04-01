#!/bin/bash
# 
# Dev-Tools - Packages development & deployment facilities
# Copyleft (C) 2013-2014 Pierre Cassat & contributors
# <http://github.com/atelierspierrot/dev-tools>
# <www.ateliers-pierrot.fr> - <contact@ateliers-pierrot.fr>
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
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
while getopts ":${OPTIONS_ALLOWED}" OPTION; do
    OPTARG="${OPTARG#=}"
    case $OPTION in
        -) LONGOPTARG="`getlongoptionarg \"${OPTARG}\"`"
            case $OPTARG in
                path*|help|man|usage|vers*|interactive|verbose|force|debug|dry-run|quiet|libvers) ;;
                dirs*) DIRS_CHMOD=$LONGOPTARG;;
                files*) FILES_CHMOD=$LONGOPTARG;;
                bin*) BIN_DIR=$LONGOPTARG;;
                bin-mask*) BIN_MASK=$LONGOPTARG;;
                *) simple_error "Unkown option '${OPTARG#=*}'";;
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
