#!/usr/bin/env bash
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

ACTION_NAME="Clean-Up"
ACTION_VERSION="1.0.0-alpha"
ACTION_DESCRIPTION="This will clean all OS or IDE specific files from the project (config var: 'DEFAULT_CLEANUP_NAMES').";
ACTION_OPTIONS="Current settings are: ${DEFAULT_CLEANUP_NAMES[@]}";
ACTION_CFGVARS=( DEFAULT_CLEANUP_NAMES )
if ${SCRIPTMAN}; then return; fi

if [ -z ${DEFAULT_CLEANUP_NAMES} ]; then
    error "Configuration var 'DEFAULT_CLEANUP_NAMES' not found !"
fi

_TARGET=$(realpath "${_TARGET}")

verecho "> cleaning files in '${_TARGET}' ..."
for FNAME in "${DEFAULT_CLEANUP_NAMES[@]}"; do
    if ${VERBOSE}; then
        iexec "find ${_TARGET} -type f -name ${FNAME} -exec rm -v {} \;"
    elif ${FORCED}; then
        iexec "find ${_TARGET} -type f -name ${FNAME} -exec rm -f {} \;"
    else
        iexec "find ${_TARGET} -type f -name ${FNAME} -exec rm {} \;"
    fi
done
verecho "_ ok"

# Endfile
