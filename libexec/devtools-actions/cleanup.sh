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

ACTION_NAME="Clean-Up"
ACTION_VERSION="1.0.0-alpha"
ACTION_DESCRIPTION="This will clean all OS or IDE specific files from the project (config var: 'DEFAULT_CLEANUP_NAMES').";
ACTION_OPTIONS="Current settings are: ${DEFAULT_CLEANUP_NAMES[*]}";
ACTION_CFGVARS=( DEFAULT_CLEANUP_NAMES )
if [ "$SCRIPTMAN" = 'true' ]; then return; fi

if [ -z "$DEFAULT_CLEANUP_NAMES" ]; then
    error "Configuration var 'DEFAULT_CLEANUP_NAMES' not found !"
fi

_TARGET=$(realpath "$_TARGET")

verecho "> cleaning files in '${_TARGET}' ..."
for FNAME in "${DEFAULT_CLEANUP_NAMES[@]}"; do
    if [ "$VERBOSE" = 'true' ]; then
        iexec "find ${_TARGET} -type f -name ${FNAME} -exec rm -v {} \;"
    elif [ "$FORCED" = 'true' ]; then
        iexec "find ${_TARGET} -type f -name ${FNAME} -exec rm -f {} \;"
    else
        iexec "find ${_TARGET} -type f -name ${FNAME} -exec rm {} \;"
    fi
done
verecho "_ ok"

# Endfile
