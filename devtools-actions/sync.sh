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

ACTION_NAME="Synchronize"
ACTION_VERSION="1.0.0-alpha"
ACTION_DESCRIPTION="Will 'rsync' a project directory to a target, which can use SSH protocol if so ; use the '-x' option to process a '--dry-run' rsync.";
ACTION_OPTIONS="--method\t=METHOD\t\t\tthe synchronization method to use in 'rsync' (default) or 'ftp' (config var: 'DEFAULT_SYNC_METHOD') \n\
\t--target\t=SERVER\t\t\tthe server name to use for synchronization (config var: 'DEFAULT_SYNC_SERVER') \n\
\t--options\t=\"RSYNC/FTP OPTIONS\"\tan options string used for the 'rsync' or 'ftp' command (config var: 'DEFAULT_SYNC_RSYNC_OPTIONS' 'DEFAULT_SYNC_FTP_OPTIONS') \n\
\t--env\t\t=ENV\t\t\tthe environment shortcut to deploy if so (config var: 'DEFAULT_SYNC_ENV') ; pease note that deployment is not possible via FTP \n\
\t--no-env\t\t\t\tskip environment deployment \n\
\t--env-options\t=\"RSYNC OPTIONS\"\tan options string used for the 'rsync' command deploying env (config var: 'DEFAULT_SYNC_RSYNC_ENV_OPTIONS')";
ACTION_SYNOPSIS="[--method=method]  [--env=env]  [--target=server]  [--options=\"rsync/ftp options\"]  [--env-options=\"rsync options\"]  [--no-env]"
ACTION_CFGVARS=( DEFAULT_SYNC_SERVER DEFAULT_SYNC_RSYNC_OPTIONS DEFAULT_SYNC_RSYNC_ENV_OPTIONS DEFAULT_SYNC_ENV DEFAULT_SYNC_METHOD DEFAULT_SYNC_FTP_OPTIONS )
if ${SCRIPTMAN}; then return; fi

METHOD="rsync"
TARGETENV=""
TARGETSERVER=""
RSYNC_OPTIONS=""
RSYNC_ENV_OPTIONS=""
FTP_OPTIONS=""
FTP_EXCLUDED_FILES=()
FTP_EXCLUDED_DIRS=()

if [ ! -z "${DEFAULT_SYNC_METHOD}" ]; then
    METHOD="${DEFAULT_SYNC_METHOD}"
fi
if [ ! -z "${DEFAULT_SYNC_SERVER}" ]; then
    TARGETSERVER="${DEFAULT_SYNC_SERVER}"
fi
if [ ! -z "${DEFAULT_SYNC_RSYNC_OPTIONS}" ]; then
    RSYNC_OPTIONS="${DEFAULT_SYNC_RSYNC_OPTIONS}"
fi
if [ ! -z "${DEFAULT_SYNC_ENV}" ]; then
    TARGETENV="${DEFAULT_SYNC_ENV}"
fi
if [ ! -z "${DEFAULT_SYNC_RSYNC_ENV_OPTIONS}" ]; then
    RSYNC_ENV_OPTIONS="${DEFAULT_SYNC_RSYNC_ENV_OPTIONS}"
fi
if [ ! -z "${DEFAULT_SYNC_FTP_OPTIONS}" ]; then
    FTP_OPTIONS="${DEFAULT_SYNC_FTP_OPTIONS}"
fi
if [ ! -z "${DEFAULT_SYNC_FTP_EXCLUDED_FILES}" ]; then
    FTP_EXCLUDED_FILES=( "${DEFAULT_SYNC_FTP_EXCLUDED_FILES[@]}" )
fi
if [ ! -z "${DEFAULT_SYNC_FTP_EXCLUDED_DIRS}" ]; then
    FTP_EXCLUDED_DIRS=( "${DEFAULT_SYNC_FTP_EXCLUDED_DIRS[@]}" )
fi

OPTIND=1
while getopts ":${OPTIONS_ALLOWED}" OPTION; do
    OPTARG="${OPTARG#=}"
    case ${OPTION} in
        -) LONGOPTARG="`get_long_option_arg \"${OPTARG}\"`"
            case ${OPTARG} in
                path*|help|man|usage|vers*|interactive|verbose|force|debug|dry-run|quiet|libvers) ;;
                method*) METHOD=${LONGOPTARG};;
                env*) TARGETENV=${LONGOPTARG};;
                no-env) TARGETENV="";;
                target*) TARGETSERVER=${LONGOPTARG};;
                options*) RSYNC_OPTIONS=${LONGOPTARG}; FTP_OPTIONS=${LONGOPTARG};;
                env-options*) RSYNC_ENV_OPTIONS=${LONGOPTARG};;
                *) simple_error "Unkown option '${OPTARG#=*}'";;
            esac ;;
        \?) ;;
    esac
done

if [ ! ${TARGETSERVER} 2&> /dev/null ] || [ -z "${TARGETSERVER}" ]; then
    error "No target defined for the synchronization ! (use the '--target' option or the 'DEFAULT_SYNC_SERVER' configuration var)"
fi

_TARGET="${_TARGET%/}/"

FIND_OPTS=""
if [ "${METHOD}" == 'ftp' ]||[ "${METHOD}" == 'ncftp' ]; then
    FIND_OPTS=""
    if [ "${FTP_EXCLUDED_FILES}" != '' ]; then
        length=${#FTP_EXCLUDED_FILES[@]}
        for (( i=0; i<${length}; i++ )); do
            if [ `strlen $FIND_OPTS` -gt 0 ]; then FIND_OPTS+=" -a "; fi
            FIND_OPTS+="! -iname \"${FTP_EXCLUDED_FILES[${i}]/./\.}\""
        done
    fi
    if [ "${FTP_EXCLUDED_DIRS}" != '' ]; then
        length=${#FTP_EXCLUDED_DIRS[@]}
        for (( i=0; i<${length}; i++ )); do
            if [ `strlen $FIND_OPTS` -gt 0 ]; then FIND_OPTS+=" -a "; fi
            FIND_OPTS+="! -ipath \"${FTP_EXCLUDED_DIRS[${i}]/./\.}\""
        done
    fi
    FIND_OPTS="\( ${FIND_OPTS} \)"
    if $VERBOSE; then FTP_OPTIONS="-v ${FTP_OPTIONS}"; fi
fi

verecho "> syncing '${_TARGET}' to '${TARGETSERVER}' ..."
if ${DRYRUN}; then
    if [ "${METHOD}" == 'ftp' ]||[ "${METHOD}" == 'ncftp' ]; then
        iexec "cd \"${_TARGET}\" && \
            find * -i -type d ${FIND_OPTS} -exec ncftpput ${FTP_OPTIONS} ${TARGETSERVER} {} \; && \
            find * -i -type f -maxdepth 0 ${FIND_OPTS} -exec ncftpput ${FTP_OPTIONS} ${TARGETSERVER} {} \; && \
            find . -i -type f -maxdepth 1 -name \".*\" ${FIND_OPTS} -exec ncftpput ${FTP_OPTIONS} ${TARGETSERVER} {} \;";
    else
        iexec "rsync --dry-run ${RSYNC_OPTIONS} ${_TARGET} ${TARGETSERVER}"
#       rsync --dry-run ${RSYNC_OPTIONS} ${_TARGET} ${TARGETSERVER}
    fi
else
    if [ "${METHOD}" == 'ftp' ]||[ "${METHOD}" == 'ncftp' ]; then
        iexec "cd \"${_TARGET}\" && \
            find * -type d ${FIND_OPTS} -exec ncftpput ${FTP_OPTIONS} ${TARGETSERVER} {} \; && \
            find * -type f -maxdepth 0 ${FIND_OPTS} -exec ncftpput ${FTP_OPTIONS} ${TARGETSERVER} {} \; && \
            find . -type f -maxdepth 1 -name \".*\" ${FIND_OPTS} -exec ncftpput ${FTP_OPTIONS} ${TARGETSERVER} {} \;";
    else
        iexec "rsync ${RSYNC_OPTIONS} ${_TARGET} ${TARGETSERVER}"
    fi
fi
if [ ! -z "${TARGETENV}" ]; then
    if [ "${METHOD}" == 'ftp' ]||[ "${METHOD}" == 'ncftp' ]; then
        echo "> deployment can't be done via FTP ..."
    else
        SUFFIX="__`string_to_upper ${TARGETENV}`__"
        verecho "> deploying files with '${SUFFIX}' suffix ..."
        if $DRYRUN; then
            iexec "cd \"${_TARGET}\" && find * -name \"*${SUFFIX}\" -exec sh -c 'destfile=\"\${1%%\$2}\" && destfilepath=\$(echo \"\${destfile}\" | sed \"s!${_TARGET}!${TARGETSERVER}!\") && rsync ${RSYNC_ENV_OPTIONS} --dry-run --no-R --no-implied-dirs \"\$1\" \"\${destfilepath}\"' _ {} \"${SUFFIX}\" \;"
        else
            iexec "cd \"${_TARGET}\" && find * -name \"*${SUFFIX}\" -exec sh -c 'destfile=\"\${1%%\$2}\" && destfilepath=\$(echo \"\${destfile}\" | sed \"s!${_TARGET}!${TARGETSERVER}!\") && rsync ${RSYNC_ENV_OPTIONS} --no-R --no-implied-dirs \"\$1\" \"\${destfilepath}\"' _ {} \"${SUFFIX}\" \;"
        fi
    fi
fi
verecho "_ ok"

# Endfile
