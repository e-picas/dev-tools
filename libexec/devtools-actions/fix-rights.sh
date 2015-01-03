#!/usr/bin/env bash
# 
# This file is part of the DevTools package.
#
# Copyleft (ↄ) 2013-2015 Pierre Cassat <me@e-piwi.fr> & contributors
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
# The source code of this package is available online at 
# <http://github.com/piwi/dev-tools>
#
# action for Dev-Tools
#

ACTION_NAME="Fix rights"
ACTION_VERSION="1.0.0-alpha"
ACTION_DESCRIPTION="This will fix files and directories UNIX rights recursively on the project.";
ACTION_ALLOWED_OPTIONS=""
ACTION_ALLOWED_LONG_OPTIONS="dirs:,files:,bin:,bin-mask:"
ACTION_OPTIONS="--dirs\t\t=CHMOD\t\tthe rights level setted for directories\n\t\t\t\t\tconfig var: 'DEFAULT_FIXRIGHTS_DIRS_CHMOD' ; default is '0755'\n\
\t--files\t\t=CHMOD\t\tthe rights level setted for files\n\t\t\t\t\tconfig var: 'DEFAULT_FIXRIGHTS_FILES_CHMOD' ; default is '0644'\n\
\t--bin\t\t=PATH\t\tdirname of the binaries, to define their rights on 'a+x'\n\t\t\t\t\tconfig var: 'DEFAULT_FIXRIGHTS_BIN_DIR' ; default is 'bin/'\n\
\t--bin-mask\t=MASK\t\tmask to match binary files in 'bin'\n\t\t\t\t\tconfig var: 'DEFAULT_FIXRIGHTS_BIN_MASK' ; default is empty";
ACTION_SYNOPSIS="[--files=chmod]  [--dirs=chmod]  [--bin=path]  [--bin-mask=mask]"
ACTION_CFGVARS=( DEFAULT_FIXRIGHTS_BIN_MASK DEFAULT_FIXRIGHTS_BIN_DIR DEFAULT_FIXRIGHTS_FILES_CHMOD DEFAULT_FIXRIGHTS_DIRS_CHMOD )
if [ "$SCRIPTMAN" = 'true' ]; then return; fi

if [ -z "$DEFAULT_FIXRIGHTS_DIRS_CHMOD" ]; then
    error "Configuration var 'DEFAULT_FIXRIGHTS_DIRS_CHMOD' not found !"
fi
DIRS_CHMOD="$DEFAULT_FIXRIGHTS_DIRS_CHMOD"
if [ -z "$DEFAULT_FIXRIGHTS_FILES_CHMOD" ]; then
    error "Configuration var 'DEFAULT_FIXRIGHTS_FILES_CHMOD' not found !"
fi
FILES_CHMOD="$DEFAULT_FIXRIGHTS_FILES_CHMOD"
if [ -z "$DEFAULT_FIXRIGHTS_BIN_DIR" ]; then
    error "Configuration var 'DEFAULT_FIXRIGHTS_BIN_DIR' not found !"
fi
BIN_DIR="$DEFAULT_FIXRIGHTS_BIN_DIR"

BIN_MASK=""
if [ ! -z "$DEFAULT_FIXRIGHTS_BIN_MASK" ]; then
    BIN_MASK="$DEFAULT_FIXRIGHTS_BIN_MASK"
fi

OPTIND=1
while getopts ":${OPTIONS_ALLOWED}" OPTION; do
    OPTARG="${OPTARG#=}"
    case "$OPTION" in
        -) LONGOPTARG="$(get_long_option_arg "$OPTARG")"
            case "$OPTARG" in
                path*|help|man|usage|vers*|interactive|verbose|force|debug|dry-run|quiet|libvers) ;;
                dirs*) DIRS_CHMOD="$LONGOPTARG";;
                files*) FILES_CHMOD="$LONGOPTARG";;
                bin*) BIN_DIR="$LONGOPTARG";;
                bin-mask*) BIN_MASK="$LONGOPTARG";;
                *) simple_error "Unkown option '${OPTARG#=*}'";;
            esac ;;
        \?) ;;
    esac
done

_TARGET=$(realpath "$_TARGET")
_TARGET_BIN=$(realpath "${_TARGET}/${BIN_DIR}")

verecho "> fixing rights in '${_TARGET}' ..."
iexec "find ${_TARGET} -type d -exec chmod ${DIRS_CHMOD} {} \;"
iexec "find ${_TARGET} -type f -exec chmod ${FILES_CHMOD} {} \;"
if [ -d "${_TARGET}/${BIN_DIR}" ]; then
    if [ ! -z "$BIN_MASK" ]; then
        iexec "find ${_TARGET_BIN} -type f -name \"${BIN_MASK}\" -exec chmod a+x {} \;"
    else
        iexec "find ${_TARGET_BIN} -type f -exec chmod a+x {} \;"
    fi
fi
verecho "_ ok"

# Endfile
