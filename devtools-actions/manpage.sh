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

ACTION_NAME="Manpage"
ACTION_VERSION="1.0.0-alpha"
ACTION_DESCRIPTION="Build a manpage file based on a markdown content.\n\
The manpage is added in system manpages and can be referenced if the 'whatis' and 'makewhatis' binaries are found or defined.";
ACTION_OPTIONS="--source\t=FILENAME\tthe manpage source file\n\t\t\t\t\tconfig var: 'DEFAULT_MANPAGE_SOURCE' ; default is 'MANPAGE.md'\n\
\t--filename\t=FILENAME\tthe filename to use to create the manpage\n\t\t\t\t\tconfig var: 'DEFAULT_MANPAGE_FILENAME'\n\
\t--section\t=REF\t\tthe manpage section to use\n\t\t\t\t\tconfig var: 'DEFAULT_MANPAGE_SECTION' ; default is '3'\n\
\t--dir\t\t=DIRNAME\tthe manpage system directory to install manpage in \n\
\t--markdown\t=BIN_PATH\tthe binary to use for the 'markdown' command\n\t\t\t\t\tconfig var: 'DEFAULT_MANPAGE_MARKDOWN_BIN' ; default is installed MarkdownExtended package\n\
\t--whatis\t=BIN_PATH\tthe binary to use for the 'whatis' command\n\t\t\t\t\tconfig var: 'DEFAULT_MANPAGE_WHATIS_BIN'\n\
\t--makewhatis\t=BIN_PATH\tthe binary to use for the 'makewhatis' command\n\t\t\t\t\tconfig var: 'DEFAULT_MANPAGE_MAKEWHATIS_BIN'";
ACTION_SYNOPSIS="[--source=path]  [--filename=filename]  [--section=section]  [--dir=dir path]  \\n\t\t[--markdown=bin path]  [--whatis=bin path]  [--makewhatis=bin path]"
ACTION_CFGVARS=( DEFAULT_MANPAGE_SOURCE DEFAULT_MANPAGE_FILENAME DEFAULT_MANPAGE_SECTION DEFAULT_MANPAGE_WHATIS_BIN DEFAULT_MANPAGE_MAKEWHATIS_BIN DEFAULT_MANPAGE_MARKDOWN_BIN )
if ${SCRIPTMAN}; then return; fi

MANPAGE_SECTION=""
MANPAGE_DIR=""
MANPAGE_FILENAME=""
MANPAGE_SOURCE=""
WHATIS_BIN=`which whatis`
MAKEWHATIS_BIN=`which makewhatis` || `which mandb`;
MARKDOWN_BIN=`which markdown-extended`

# internal MarkdownExtended path
_vendor_mde="vendor/bin/markdown-extended"
if [ -f ${_vendor_mde} ]; then MARKDOWN_BIN="${_vendor_mde}"; fi
_mde="bin/markdown_extended"
if [ -f ${_mde} ]; then MARKDOWN_BIN="${_mde}"; fi

# config values
if [ ! -z ${DEFAULT_MANPAGE_SOURCE} ]; then
    MANPAGE_SOURCE=${DEFAULT_MANPAGE_SOURCE}
fi
if [ ! -z ${DEFAULT_MANPAGE_FILENAME} ]; then
    MANPAGE_FILENAME=${DEFAULT_MANPAGE_FILENAME}
fi
if [ ! -z ${DEFAULT_MANPAGE_SECTION} ]; then
    MANPAGE_SECTION=${DEFAULT_MANPAGE_SECTION}
fi
if [ ! -z ${DEFAULT_MANPAGE_WHATIS_BIN} ]; then
    WHATIS_BIN=${DEFAULT_MANPAGE_WHATIS_BIN}
fi
if [ ! -z ${DEFAULT_MANPAGE_MAKEWHATIS_BIN} ]; then
    MAKEWHATIS_BIN=${DEFAULT_MANPAGE_MAKEWHATIS_BIN}
fi
if [ ! -z ${DEFAULT_MANPAGE_MARKDOWN_BIN} ]; then
    MARKDOWN_BIN=${DEFAULT_MANPAGE_MARKDOWN_BIN}
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
                section*) MANPAGE_SECTION=${LONGOPTARG};;
                whatis*) WHATIS_BIN=${LONGOPTARG};;
                makewhatis*) MAKEWHATIS_BIN=${LONGOPTARG};;
                markdown*) MARKDOWN_BIN=${LONGOPTARG};;
                dir*) MANPAGE_DIR=${LONGOPTARG};;
                *) simple_error "Unkown option '${OPTARG#=*}'";;
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
    echo "The binary '${MARKDOWN_BIN}' can't be found ; the manpage will not be updated !"
    prompt 'Do you want to continue' 'Y/n' 'y'
    if [ "${USERRESPONSE}" != 'y' ]; then exit 0; fi
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
verecho

if [ -z ${MANPAGE_DIR} ]; then
    explode "`man -w`" ":" && MANPAGES_PATHS=("${EXPLODED_ARRAY[@]}")
    selector_prompt MANPAGES_PATHS[@] "select a path in the list above" "please choose a path to install your manpage"
    MANPAGE_DIR="${USERRESPONSE}"
    echo ${MANPAGE_DIR}
    verecho
fi

MANPAGE_SUBDIR="${MANPAGE_DIR}/man${MANPAGE_SECTION}"
if [ ! -d "${MANPAGE_SUBDIR}" ]; then
    MANPAGE_SUBDIR="${MANPAGE_DIR}"
fi
MANPAGE_FULLPATH="${MANPAGE_SUBDIR}/${MANPAGE_NAME//.man/.${MANPAGE_SECTION}}"
verecho "> copying the new manpage in '${MANPAGE_FULLPATH}' ..."
iexec "sudo cp ${MANPAGE_FILENAME_RP} ${MANPAGE_FULLPATH}"
verecho

if [ ! -z ${MAKEWHATIS_BIN} ]
then
    verecho "> updating 'whatis' database ..."
    iexec "sudo ${MAKEWHATIS_BIN}"
    if ! ${QUIET}; then
        verecho "> checking for new manpage installation ..."
        iexec "${WHATIS_BIN} ${MANPAGE_NAME/.man}"
    fi
    verecho
    verecho "> opening the new manpage ..."
    iexec "man ${MANPAGE_NAME/.man}"
    verecho
else
    verecho "> no 'makewhatis' binary found ..."
    verecho "> opening the new manpage ..."
    iexec "man ${MANPAGE_FILENAME_RP}"
    verecho
fi

# Endfile

# To write good manpage, NAME must be "script-name - presentation" (no bold)

# To add manpage to 'whatis' see <http://www.schweikhardt.net/man_page_howto.html#q12>
# cp src/bash-library.man /usr/local/man/man3/bash-library.3
# /usr/sbin/makewhatis

# To generate the manpage
# vendor/bin/markdown_extended -f man -o src/bash-library.man MANPAGE.md
