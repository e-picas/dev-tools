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

ACTION_NAME="MD2Man"
ACTION_VERSION="1.0.0-alpha"
ACTION_DESCRIPTION="Build a manpage file based on a markdown content.";
ACTION_OPTIONS="--source\t=FILENAME\tthe manpage source file (default is 'MANPAGE.md' - config var: 'DEFAULT_MD2MAN_SOURCE') \n\
\t--filename\t=FILENAME\tthe filename to use to create the manpage (config var: 'DEFAULT_MD2MAN_FILENAME') \n\
\t--markdown\t=BIN_PATH\tthe binary to use for the 'markdown' command (default is installed MarkdownExtended package - config var: 'DEFAULT_MD2MAN_MARKDOWN_BIN')";
ACTION_SYNOPSIS="[--source=path]  [--filename=filename]  [--markdown=bin path]"
ACTION_CFGVARS=( DEFAULT_MD2MAN_SOURCE DEFAULT_MD2MAN_FILENAME DEFAULT_MD2MAN_MARKDOWN_BIN )
if ${SCRIPTMAN}; then return; fi

MANPAGE_FILENAME=""
MANPAGE_SOURCE=""
MARKDOWN_BIN=`which markdown-extended`

# internal MarkdownExtended path
_vendor_mde="vendor/bin/markdown-extended"
if [ -f ${_vendor_mde} ]; then MARKDOWN_BIN="${_vendor_mde}"; fi
_mde="bin/markdown_extended"
if [ -f ${_mde} ]; then MARKDOWN_BIN="${_mde}"; fi

# config values
if [ ! -z ${DEFAULT_MD2MAN_SOURCE} ]; then
    MANPAGE_SOURCE=${DEFAULT_MD2MAN_SOURCE}
fi
if [ ! -z ${DEFAULT_MD2MAN_FILENAME} ]; then
    MANPAGE_FILENAME=${DEFAULT_MD2MAN_FILENAME}
fi
if [ ! -z ${DEFAULT_MD2MAN_MARKDOWN_BIN} ]; then
    MARKDOWN_BIN=${DEFAULT_MD2MAN_MARKDOWN_BIN}
fi

# options
OPTIND=1
while getopts ":${OPTIONS_ALLOWED}" OPTION; do
    OPTARG="${OPTARG#=}"
    case ${OPTION} in
        -) LONGOPTARG="`get_long_option_arg \"${OPTARG}\"`"
            case ${OPTARG} in
                path*|help|man|usage|vers*|interactive|verbose|force|debug|dry-run|quiet|libvers) ;;
                source*) MANPAGE_SOURCE=${LONGOPTARG};;
                filename*) MANPAGE_FILENAME=${LONGOPTARG};;
                markdown*) MARKDOWN_BIN=${LONGOPTARG};;
                *) ;;
            esac ;;
        \?) ;;
    esac
done

_TARGET=$(realpath "${_TARGET}")
MANPAGE_SOURCE_RP="${_TARGET}/${MANPAGE_SOURCE}"
MANPAGE_FILENAME_RP="${_TARGET}/${MANPAGE_FILENAME}"
MANPAGE_NAME=$(basename "${MANPAGE_FILENAME}")

if [ -z ${MARKDOWN_BIN} ]; then
    error "Markdown binary not defined!"
elif [ ! -f "${MARKDOWN_BIN}" ]; then
    error "The binary '${MARKDOWN_BIN}' can't be found!"
fi

if [ ! -f ${MANPAGE_SOURCE_RP} ]; then
    error "source file '${MANPAGE_SOURCE_RP}' not found"
fi

verecho "> parsing markdown source '${MANPAGE_SOURCE_RP}' to '${MANPAGE_FILENAME_RP}' ..."
if ${QUIET}
then
    iexec "${MARKDOWN_BIN} -f man -o ${MANPAGE_FILENAME_RP} ${MANPAGE_SOURCE_RP} > /dev/null"
else
    iexec "${MARKDOWN_BIN} -f man -o ${MANPAGE_FILENAME_RP} ${MANPAGE_SOURCE_RP}"
fi

verecho "> opening the new manpage ..."
iexec "man ${MANPAGE_FILENAME_RP}"

# Endfile
