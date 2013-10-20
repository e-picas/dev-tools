#!/bin/bash
# 
# DevTools - Packages development & deployment facilities
# Copyleft (c) 2013 Pierre Cassat and contributors
# <www.ateliers-pierrot.fr> - <contact@ateliers-pierrot.fr>
# License GPL-3.0 <http://www.opensource.org/licenses/gpl-3.0.html>
# Sources <http://github.com/atelierspierrot/dev-tools>
#
# action for Dev-Tools
#

ACTION_DESCRIPTION="Build a manpage file based on a markdown content ; the manpage is added in system manpages and can be referenced if the 'whatis' and 'makewhatis' binaries are found or defined.";
ACTION_OPTIONS="<bold>--source=FILENAME</bold>\tthe manpage source file (default is 'MANPAGE.md' - config var: 'DEFAULT_MANPAGE_SOURCE') \n\
\t<bold>--filename=FILENAME</bold>\tthe filename to use to create the manpage (config var: 'DEFAULT_MANPAGE_FILENAME') \n\
\t<bold>--section=REF</bold>\t\tthe manpage section to use (default is '3' - config var: 'DEFAULT_MANPAGE_SECTION') \n\
\t<bold>--dir=DIRNAME</bold>\t\tthe manpage system directory to install manpage in \n\
\t<bold>--markdown=BIN_PATH</bold>\tthe binary to use for the 'markdown' command (default is installed MarkdownExtended package - config var: 'DEFAULT_MANPAGE_MARKDOWN_BIN') \n\
\t<bold>--whatis=BIN_PATH</bold>\tthe binary to use for the 'whatis' command (config var: 'DEFAULT_MANPAGE_WHATIS_BIN') \n\
\t<bold>--makewhatis=BIN_PATH</bold>\tthe binary to use for the 'makewhatis' command (config var: 'DEFAULT_MANPAGE_MAKEWHATIS_BIN')";
ACTION_SYNOPSIS="[--source=path]  [--filename=filename]  [--section=section]  [--dir=dir path]  [--markdown=bin path]  [--whatis=bin path]  [--makewhatis=bin path]"
ACTION_CFGVARS=( DEFAULT_MANPAGE_SOURCE DEFAULT_MANPAGE_FILENAME DEFAULT_MANPAGE_SECTION DEFAULT_MANPAGE_WHATIS_BIN DEFAULT_MANPAGE_MAKEWHATIS_BIN DEFAULT_MANPAGE_MARKDOWN_BIN )
if $SCRIPTMAN; then return; fi

targetdir_required
MANPAGE_SECTION=""
MANPAGE_DIR=""
MANPAGE_FILENAME=""
MANPAGE_SOURCE=""
WHATIS_BIN=`which whatis`
MAKEWHATIS_BIN=`which makewhatis`
MARKDOWN_BIN=""

# internal MarkdownExtended path
_vendor_mde="vendor/bin/markdown-extended"
if [ -f $_vendor_mde ]; then MARKDOWN_BIN="$_vendor_mde"; fi
_mde="bin/markdown_extended"
if [ -f $_mde ]; then MARKDOWN_BIN="$_mde"; fi

# config values
if [ ! -z $DEFAULT_MANPAGE_SOURCE ]; then
    MANPAGE_SOURCE=$DEFAULT_MANPAGE_SOURCE
fi
if [ ! -z $DEFAULT_MANPAGE_FILENAME ]; then
    MANPAGE_FILENAME=$DEFAULT_MANPAGE_FILENAME
fi
if [ ! -z $DEFAULT_MANPAGE_SECTION ]; then
    MANPAGE_SECTION=$DEFAULT_MANPAGE_SECTION
fi
if [ ! -z $DEFAULT_MANPAGE_WHATIS_BIN ]; then
    WHATIS_BIN=$DEFAULT_MANPAGE_WHATIS_BIN
fi
if [ ! -z $DEFAULT_MANPAGE_MAKEWHATIS_BIN ]; then
    MAKEWHATIS_BIN=$DEFAULT_MANPAGE_MAKEWHATIS_BIN
fi
if [ ! -z $DEFAULT_MANPAGE_MARKDOWN_BIN ]; then
    MARKDOWN_BIN=$DEFAULT_MANPAGE_MARKDOWN_BIN
fi

# options
OPTIND=1
options=$(getscriptoptions "$@")
while getopts "${COMMON_OPTIONS_ARGS}" OPTION $options; do
    OPTARG="${OPTARG#=}"
    case $OPTION in
        -) LONGOPTARG="`getlongoptionarg \"${OPTARG}\"`"
            case $OPTARG in
                source*) MANPAGE_SOURCE=$LONGOPTARG;;
                filename*) MANPAGE_FILENAME=$LONGOPTARG;;
                section*) MANPAGE_SECTION=$LONGOPTARG;;
                whatis*) WHATIS_BIN=$LONGOPTARG;;
                makewhatis*) MAKEWHATIS_BIN=$LONGOPTARG;;
                markdown*) MARKDOWN_BIN=$LONGOPTARG;;
                dir*) MANPAGE_DIR=$LONGOPTARG;;
                \?) ;;
            esac ;;
        \?) ;;
    esac
done

_TARGET=$(realpath "$_TARGET")
MANPAGE_SOURCE_RP="${_TARGET}/${MANPAGE_SOURCE}"
MANPAGE_FILENAME_RP="${_TARGET}/${MANPAGE_FILENAME}"
MANPAGE_NAME=$(basename "$MANPAGE_FILENAME")

if [ ! -f $MANPAGE_SOURCE_RP ]; then
    error "source file '${MANPAGE_SOURCE_RP}' not found"
fi

verecho "> parsing markdown source '${MANPAGE_SOURCE_RP}' to '${MANPAGE_FILENAME_RP}' ..."
if $QUIET
then
    iexec "${MARKDOWN_BIN} -f man -o ${MANPAGE_FILENAME_RP} ${MANPAGE_SOURCE_RP} > /dev/null"
else
    iexec "${MARKDOWN_BIN} -f man -o ${MANPAGE_FILENAME_RP} ${MANPAGE_SOURCE_RP}"
fi
verecho

if [ -z $MANPAGE_DIR ]; then
    explode "`man -w`" ":" && MANPAGES_PATHS=("${EXPLODED_ARRAY[@]}")
    selector_prompt MANPAGES_PATHS[@] "select a path in the list above" "please choose a path to install your manpage"
    MANPAGE_DIR="$USERRESPONSE"
    echo $MANPAGE_DIR
    verecho
fi

MANPAGE_SUBDIR="${MANPAGE_DIR}/man${MANPAGE_SECTION}"
if [ ! -d "$MANPAGE_SUBDIR" ]; then
    MANPAGE_SUBDIR="${MANPAGE_DIR}"
fi
MANPAGE_FULLPATH="${MANPAGE_SUBDIR}/${MANPAGE_NAME//.man/.${MANPAGE_SECTION}}"
verecho "> copying the new manpage in '${MANPAGE_FULLPATH}' ..."
iexec "sudo cp ${MANPAGE_FILENAME_RP} ${MANPAGE_FULLPATH}"
verecho

if [ ! -z $MAKEWHATIS_BIN ]
then
    verecho "> updating 'whatis' database ..."
    iexec "sudo ${MAKEWHATIS_BIN}"
    if ! $QUIET; then
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
