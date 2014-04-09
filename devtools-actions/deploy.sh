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

ACTION_NAME="Deploy"
ACTION_VERSION="1.0.0-alpha"
ACTION_DESCRIPTION_MANPAGE="Will search for files suffixed by '__ENV__' in the project path and over-write the original ones (without suffix).";
ACTION_OPTIONS="--env =ENV\tthe environment shortcut to deploy (default is 'DEFAULT' - config var: 'DEFAULT_DEPLOY_ENV')";
ACTION_SYNOPSIS="[--env=env]"
ACTION_CFGVARS=( DEFAULT_DEPLOY_ENV )
if ${SCRIPTMAN}; then return; fi

if [ -z ${DEFAULT_DEPLOY_ENV} ]; then
    error "Configuration var 'DEFAULT_DEPLOY_ENV' not found !"
fi
TARGETENV=${DEFAULT_DEPLOY_ENV}

OPTIND=1
while getopts ":${OPTIONS_ALLOWED}" OPTION; do
    OPTARG="${OPTARG#=}"
    case ${OPTION} in
        -) LONGOPTARG="`get_long_option_arg \"${OPTARG}\"`"
            case ${OPTARG} in
                path*|help|man|usage|vers*|interactive|verbose|force|debug|dry-run|quiet|libvers) ;;
                env*) TARGETENV=${LONGOPTARG};;
                *) simple_error "Unkown option '${OPTARG%=*}'";;
            esac ;;
        \?) ;;
    esac
done
#SUFFIX="__`echo ${TARGETENV} | tr '[:lower:]' '[:upper:]'`__"
SUFFIX="__`string_to_upper ${TARGETENV}`__"

_TARGET=$(realpath "${_TARGET}")

verecho "> deploying files with '${SUFFIX}' suffix in '${_TARGET}' ..."
iexec "find \"${_TARGET}\" -name \"*${SUFFIX}\" -exec sh -c 'cp -v \"\$1\" \"\${1%%\$2}\"' _ {} \"${SUFFIX}\" \;"
verecho "_ ok"

# Endfile
