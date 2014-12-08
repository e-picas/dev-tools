#!/usr/bin/env bash
# 
# DevTools - Packages development & deployment facilities
# Copyleft (c) 2013 Pierre Cassat and contributors
# License GPL-3.0 <http://www.opensource.org/licenses/gpl-3.0.html>
# Sources <http://github.com/piwi/dev-tools>
#
# action for Dev-Tools
#

ACTION_DESCRIPTION_MANPAGE="Build a manpage file based on script help string.";
ACTION_OPTIONS="<bold>--type=TYPE</bold>\t\tthe action name to create manpage from, or 'lib' to create global dev tools manpage (default is 'lib' - config var: 'DEFAULT_MANPAGE_TYPE') \n\
\t<bold>--filename</bold>\t\tthe filename to use to create the manpage (default is 'TYPE.man')";
ACTION_SYNOPSIS="[--type=action | lib]  [--filename=filename]"
ACTION_CFGVARS=( DEFAULT_MANPAGE_TYPE )
if $SCRIPTMAN; then return; fi

targetdir_required
MANPAGE_TYPE=""
MANPAGE_FILENAME="dev-tools.man"

#### substitue_in_manpage( match , replace , filename )
substitue_in_manpage() {
    local MATCH="$1"
    local REPLACE="$2"
    local FILENAME="$3"
# On GNU sed (linux) try "... -i ..." (no empty arg '')
#    iexec "sed -i '' \"s/$MATCH/$REPLACE/g\" \"$FILENAME\""
    sed -i '' "s/^[ \t]*//;s/$MATCH/$REPLACE/g" "$FILENAME"
}

strip_leading_tabs() {
    sed "s/^[ \\\t]*//g" <<< "$1"
}

#### substitue_in_manpage( match , replace , filename )
substitue_in_content() {
    local MATCH="$1"
    local REPLACE="$2"
    local FILENAME="$3"
# On GNU sed (linux) try "... -i ..." (no empty arg '')
#    iexec "sed -i '' \"s/$MATCH/$REPLACE/g\" \"$FILENAME\""
    sed "s/$MATCH/$REPLACE/g" <<< "$FILENAME"
}

#### substitue_tabs_newlines( string )
substitue_tabs_newlines() {
    sed "s/\([\\\t]+\)/\\\t/g;s/\\\t/\\\n/g" <<< "$1"
}

#### substitue_tabs_newlines( string )
format_options() {
    sed "s/<bold>\(.[^\bold]*\)<\/bold>[ \\\t]*\(.*\)$/**\1**\\\n:    \2\\\n/g" <<< "$1"
}

#### library_usage ()
## this function must echo the usage information of the library itself (with option "--libhelp")
manpage_library_usage () {
    for section in "${MANPAGE_VARS[@]}"; do
        eval "old_$section=\$$section"
        eval "$section=\$LIB_$section"
    done
    for section in "${SCRIPT_VARS[@]}"; do
        eval "old_$section=\$$section"
        eval "$section=\$LIB_$section"
    done
    manpage_usage false
    for section in "${MANPAGE_VARS[@]}"; do
        eval "$section=\$old_$section"
    done
    for section in "${SCRIPT_VARS[@]}"; do
        eval "$section=\$old_$section"
    done
}

#### manpage_usage ( type = lib , lib_info = true )
## this function must echo the usage information USAGE (with option "-h")
manpage_usage () {
    local type="${1:-lib}"
    local lib_info="${2:-true}"
    local TMP_VERS="`library_info`"

    echo "Man: ${NAME} Manual"
    echo "Name: ${NAME}"
    if [ -n "$VERSION" ]; then echo "Version: ${VERSION}"; fi
    if [ -n "$DATE" ]; then echo "Date: ${DATE}"; fi
    if [ ! "x${USAGE}" = 'x' -a "$lib_info" == 'true' ]; then
        echo "${USAGE}\n\n${TMP_VERS}"
    else
        local TMP_USAGE="\n## NAME\n\n<bold>${NAME:-?}</bold>\n";
        if [ -n "$PRESENTATION" ]; then
            TMP_PRESENTATION=$(substitue_tabs_newlines "${PRESENTATION}")
            TMP_USAGE="${TMP_USAGE}\n${TMP_PRESENTATION}\n";
        fi
        for section in "${MANPAGE_VARS[@]}"; do
            eval "section_ctt=\"\$$section\""
            if [ "$section" != 'NAME' -a -n "$section_ctt" ]; then
                if [ "$section" == 'OPTIONS' ]
                then
                    TMP_SECTION=$(format_options "${section_ctt}")
                    TMP_USAGE="${TMP_USAGE}\n## ${section}\n\n${TMP_SECTION}\n";
                else
                    TMP_USAGE="${TMP_USAGE}\n## ${section}\n\n${section_ctt}\n";
                fi
            fi
        done
        if ! ${MANPAGE_NODEPEDENCY:-true}; then
            if [ "$lib_info" == 'true' ]; then
                TMP_USAGE="${TMP_USAGE}\n## DEPENDENCIES\n\n${LIB_INFO}\n";
            fi
        fi
        TMP_USAGE="${TMP_USAGE}\n<${COLOR_COMMENT}>${TMP_VERS}</${COLOR_COMMENT}>";
        echo "$TMP_USAGE"
    fi
    return 0;
}

#### parse_color_tags ( "string with <bold>tags</bold>" )
man_parse_color_tags () {
    transformed=""
    while read -r line; do
        doneopts=()
        transformedline="$line"
        for opt in $(echo "$line" | grep -Po '<.[^/>]*>' | sed "s|^.*<\(.[^>]*\)>.*\$|\1|g"); do
            opt="${opt/\//}"
            case $opt in
                bold) tag='**';;
                underline) tag='*';;
                default|black|red|green|yellow|blue|magenta|cyan|grey|white|lightred|lightgreen|lightyellow|lightblue|lightmagenta|lightcyan|lightgrey) tag='\`'
            esac
            strsubstituted=$(echo "$transformedline" | sed "s|<${opt}>|${tag}|g;s|</${opt}>|${tag}|g");
            if [ ! -z "$strsubstituted" ]; then transformedline="${strsubstituted}"; fi
        done
        if [ -n "$transformed" ]; then transformed="${transformed}\n"; fi
        transformed="${transformed}${transformedline}"
    done <<< "$1"
    _echo "$transformed"
    return 0
}

if [ ! -z "$DEFAULT_MANPAGE_TYPE" ]; then
    MANPAGE_TYPE="$DEFAULT_MANPAGE_TYPE"
fi

OPTIND=1
options=$(getscriptoptions "$*")
while getopts "${COMMON_OPTIONS_ARGS}" OPTION $options; do
    OPTARG="${OPTARG#=}"
    case $OPTION in
        -) LONGOPTARG="`get_long_option_arg \"${OPTARG}\"`"
            case $OPTARG in
                type*) MANPAGE_TYPE=$LONGOPTARG;;
                filename*) MANPAGE_FILENAME=$LONGOPTARG;;
                \?) ;;
            esac ;;
        \?) ;;
    esac
done

MANPAGE_FILENAME_TMP="${MANPAGE_FILENAME}.tmp"
verecho "> writing temporary help string in '${MANPAGE_FILENAME_TMP}' ..."
if [ -f "$MANPAGE_FILENAME_TMP" ]; then
    rm "$MANPAGE_FILENAME_TMP"
fi



#str="\t<bold>qsdf</bold>\tqsdfqsdfqsdf"

#format_options "$str"

#exit 0

MAN=$(manpage_usage)
MAN=$(strip_leading_tabs "$MAN")
MAN=$(substitue_in_content "'<bold>\(.[^\/bold]*\)<\/bold>'" '\`\1\`' "$MAN")
MAN=$(substitue_in_content "^[ \\\t]*\(<bold>[^\/bold]<\/bold>\)[ \\\t]*$" '\1\\\n' "$MAN")
MAN=$(man_parse_color_tags "$MAN")
#MAN=$(substitue_in_content '<underline>\(.[^\/underline]*\)<\/underline>' '*\1*' "$MAN")

echo "$MAN"
exit 0
iexec "manpage_usage >> $MANPAGE_FILENAME_TMP"
iexec "substitue_in_manpage '<bold>\(.[^\/bold]*\)<\/bold>' '**\1**' $MANPAGE_FILENAME_TMP"
iexec "substitue_in_manpage '<underline>\(.[^\/underline]*\)<\/underline>' '*\1*' $MANPAGE_FILENAME_TMP"

verecho "_ ok"

# Endfile
