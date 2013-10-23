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

ACTION_DESCRIPTION="Build a manpage file based on a markdown content.";
ACTION_OPTIONS="<bold>--source=FILENAME</bold>\tthe manpage source file (default is 'MANPAGE.md' - config var: 'DEFAULT_MD2MAN_SOURCE') \n\
\t<bold>--filename=FILENAME</bold>\tthe filename to use to create the manpage (config var: 'DEFAULT_MD2MAN_FILENAME') \n\
\t<bold>--markdown=BIN_PATH</bold>\tthe binary to use for the 'markdown' command (default is installed MarkdownExtended package - config var: 'DEFAULT_MD2MAN_MARKDOWN_BIN')";
ACTION_SYNOPSIS="[--source=path]  [--filename=filename]  [--markdown=bin path]"
ACTION_CFGVARS=( DEFAULT_MD2MAN_SOURCE DEFAULT_MD2MAN_FILENAME DEFAULT_MD2MAN_MARKDOWN_BIN )
if $SCRIPTMAN; then return; fi

MANPAGE_FILENAME=""
MANPAGE_SOURCE=""
MARKDOWN_BIN=`which markdown-extended`

# internal MarkdownExtended path
_vendor_mde="vendor/bin/markdown-extended"
if [ -f $_vendor_mde ]; then MARKDOWN_BIN="$_vendor_mde"; fi
_mde="bin/markdown_extended"
if [ -f $_mde ]; then MARKDOWN_BIN="$_mde"; fi

# config values
if [ ! -z $DEFAULT_MD2MAN_SOURCE ]; then
    MANPAGE_SOURCE=$DEFAULT_MD2MAN_SOURCE
fi
if [ ! -z $DEFAULT_MD2MAN_FILENAME ]; then
    MANPAGE_FILENAME=$DEFAULT_MD2MAN_FILENAME
fi
if [ ! -z $DEFAULT_MD2MAN_MARKDOWN_BIN ]; then
    MARKDOWN_BIN=$DEFAULT_MD2MAN_MARKDOWN_BIN
fi

# options
OPTIND=1
while getopts "${ALLOWED_OPTIONS}" OPTION "${SCRIPT_OPTS[@]}"; do
    OPTARG="${OPTARG#=}"
    case $OPTION in
        -) LONGOPTARG="`getlongoptionarg \"${OPTARG}\"`"
            case $OPTARG in
                project*|help|man|usage|vers*|interactive|verbose|force|debug|dry-run|quiet|libhelp|libvers|libdoc) ;;
                source*) MANPAGE_SOURCE=$LONGOPTARG;;
                filename*) MANPAGE_FILENAME=$LONGOPTARG;;
                markdown*) MARKDOWN_BIN=$LONGOPTARG;;
                *) simple_error "Unkown option '${OPTARG#=*}'";;
            esac ;;
        \?) ;;
    esac
done

_TARGET=$(realpath "$_TARGET")
MANPAGE_SOURCE_RP="${_TARGET}/${MANPAGE_SOURCE}"
MANPAGE_FILENAME_RP="${_TARGET}/${MANPAGE_FILENAME}"
MANPAGE_NAME=$(basename "$MANPAGE_FILENAME")

if [ -z $MARKDOWN_BIN ]; then
    error "Markdown binary not defined!"
elif [ ! -f "$MARKDOWN_BIN" ]; then
    error "The binary '$MARKDOWN_BIN' can't be found!"
fi

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

verecho "> opening the new manpage ..."
iexec "man ${MANPAGE_FILENAME_RP}"

# Endfile