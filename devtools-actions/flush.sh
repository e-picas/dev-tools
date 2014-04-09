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

ACTION_NAME="Flush files"
ACTION_VERSION="1.0.0-alpha"
ACTION_DESCRIPTION="This will clean contents of temporary directories (config var: 'DEFAULT_FLUSH_DIRNAMES').";
ACTION_OPTIONS="Current settings are : ${DEFAULT_FLUSH_DIRNAMES[@]}";
ACTION_CFGVARS=( DEFAULT_FLUSH_DIRNAMES )
if ${SCRIPTMAN}; then return; fi

if [ -z ${DEFAULT_FLUSH_DIRNAMES} ]; then
    error "Configuration var 'DEFAULT_FLUSH_DIRNAMES' not found !"
fi

_TARGET=$(realpath "${_TARGET}")

verecho "> cleaning temporary files in '${_TARGET}' ..."
for FNAME in "${DEFAULT_FLUSH_DIRNAMES[@]}"; do
    for DIRNAME in $(find ${_TARGET} -type d -name ${FNAME}); do
        if ${VERBOSE}; then
            iexec "rm -vr ${DIRNAME}/*"
        elif ${FORCED}; then
            iexec "rm -rf ${DIRNAME}/*"
        else
            iexec "rm -r ${DIRNAME}/*"
        fi
    done
done
verecho "_ ok"

# Endfile
