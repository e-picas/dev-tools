#!/bin/bash
#
# Dev-Tools - Packages development & deployment facilities
# Copyright (C) 2013-2014 Les Ateliers Pierrot
# Created & maintained by Pierre Cassat & contributors
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
# ------------------
#
# Global help : `devtools.sh -h` OR `devtools.sh help`
# Action help : `devtools.sh action -h` OR `devtools.sh help action`
# Action usage : `devtools.sh action [-vix] -p=PROJECT_PATH [action options]`
#

###### Current version
NAME="DevTools"
VERSION="1.3.1"
DATE="2014-05-18"
VCSVERSION="master@9dcc051d17be093f12c53dd6ac243aeb47d853fe"

###### First paths
##@ _REALPATH _REALDIRPATH _DEVTOOLS_CONFIGFILE _DEVTOOLS_ACTIONSDIR
declare -rx _REALPATH="$0"
declare -rx _REALDIRPATH="`dirname ${_REALPATH}`"
declare -rx _DEVTOOLS_CONFIGFILE="${_REALDIRPATH}/devtools.conf"
declare -rx _DEVTOOLS_ACTIONSDIR="${_REALDIRPATH}/devtools-actions"

##@ ACTION_VARS = ( ACTION_NAME ACTION_VERSION ACTION_SYNOPSIS ACTION_DESCRIPTION ACTION_OPTIONS ACTION_CFGVARS ACTION_ADDITIONAL_INFO ) (read-only)
declare -rxa ACTION_VARS=(ACTION_NAME ACTION_VERSION ACTION_SYNOPSIS ACTION_DESCRIPTION ACTION_OPTIONS ACTION_CFGVARS ACTION_ADDITIONAL_INFO)

#### findRequirements ( path , info string )
# search for a relative or root path
# this needs to be defined first as it is used to find the library
findRequirements() {
    REQFILE="$1"
    ROOTREQFILE="${_REALDIRPATH}/${REQFILE}"
    REQINFO="$2"
    if [ -e "${REQFILE}" ]; then
        echo "${REQFILE}"
        return 0
    elif [ -e "${ROOTREQFILE}" ]; then
        echo "${ROOTREQFILE}"
        return 0
    else
        PADDER=$(printf '%0.1s' "#"{1..1000})
        printf "\n### %*.*s\n    %s\n    %s\n%*.*s\n\n" 0 $(($(tput cols)-4)) "ERROR! ${PADDER}" \
            "Unable to find required ${REQINFO} '${REQFILE}'!" \
            "Sent in '$0' line '${LINENO}' by '`whoami`' - pwd is '`pwd`'" \
            0 $(tput cols) "${PADDER}";
        return 1
    fi
}

######## Inclusion of the config
declare -rx CFGFILE=`findRequirements "${_DEVTOOLS_CONFIGFILE}" "configuration file"`
if [ -f "${CFGFILE}" ]; then source "${CFGFILE}"; else echo "${CFGFILE}"; exit 1; fi

######## Inclusion of the lib
declare -rx LIBFILE=`findRequirements "${DEFAULT_BASHLIBRARY_PATH}" "bash library"`
declare -rx USERBINLIBFILE=`findRequirements "${HOME}/bin/piwi-bash-library.sh" "bash library"`
declare -rx BINLIBFILE=`findRequirements "/usr/local/bin/piwi-bash-library.sh" "bash library"`
if [ -f "${LIBFILE}" ]; then source "${LIBFILE}";
elif [ -f "${USERBINLIBFILE}" ]; then source "${USERBINLIBFILE}";
elif [ -f "${BINLIBFILE}" ]; then source "${BINLIBFILE}";
else echo "${LIBFILE}"; exit 1;
fi

######## Path of the actions
declare -rx _BASEDIR=`findRequirements "${_DEVTOOLS_ACTIONSDIR}" "actions directory"`
if [ ! -d "${_BASEDIR}" ]; then echo "${_BASEDIR}"; exit 1; fi

#### init_action ()
# initialize all action's variables to empty string
init_action () {
    for section in "${ACTION_VARS[@]}"; do
        eval export ${section}=''
    done
}

#### load_actions_infos ()
# load the available actions in $ACTIONS_LIST
# load the available actions synopsis in $ACTIONS_SYNOPSIS
# load the available actions synopsis in $ACTIONS_DESCRIPTION
# this needs to be defined here as it is used for strings below
load_actions_infos () {
    export SCRIPTMAN=true
    for action in ${_BASEDIR}/*.sh; do
        init_action
        myaction=${action##$_BASEDIR/}
        pos=${#ACTIONS_LIST[@]}
        source "${action}"
        ACTIONS_LIST[${pos}]="${myaction%%.sh}"
        if [ -n "${ACTION_SYNOPSIS}" ]; then
            ACTIONS_SYNOPSIS[${pos}]="${ACTION_SYNOPSIS}"
        fi
        if [ -n "${ACTION_DESCRIPTION}" ]; then
            ACTIONS_DESCRIPTION[${pos}]="${ACTION_DESCRIPTION}"
        fi
        if [ -n "${ACTION_CFGVARS}" ]; then
            ACTIONS_CFGVARS=("${ACTIONS_CFGVARS[@]}" "${ACTION_CFGVARS[@]}")
        fi
        if [ -n "${ACTION_OPTIONS}" ]; then
            ACTIONS_OPTIONS[${pos}]="${ACTION_OPTIONS}"
        fi
    done
    for section in "${ACTION_VARS[@]}"; do
        eval "export ${section}"
    done
    export SCRIPTMAN=false
}

#### prepare_actionslist_strings ()
# parse all actions and prepare required information strings
prepare_actionslist_strings () {
    local itemstr
    local itemdesc
    local itemsyn
    for i in ${!ACTIONS_LIST[*]}; do
        itemstr=${ACTIONS_LIST[$i]}
        ACTIONS_DESCRIPTION_STR+="\n<bold>${itemstr}</bold>\n"
        itemdesc=${ACTIONS_DESCRIPTION[$i]}
        if [ -n "${itemdesc}" ]; then
            ACTIONS_DESCRIPTION_STR+="\t${itemdesc}";
        fi
        itemsyn=${ACTIONS_SYNOPSIS[$i]}
        if [ -n "${itemsyn}" ]; then
            ACTIONS_DESCRIPTION_STR+="\n\tusage: `printf \"${ACTION_SYNOPSIS_MASK}\" \"${itemstr}\" \"${itemsyn}\"`";
            ACTIONS_SYNOPSIS_STR+="\n\t... ${itemstr} ${itemsyn}"
        else
            ACTIONS_DESCRIPTION_STR+="\n\tusage: `printf \"${ACTION_SYNOPSIS_MASK}\" \"${itemstr}\" ''`";
            ACTIONS_SYNOPSIS_STR+="\n\t... ${itemstr}"
        fi
    done
    export ACTIONS_DESCRIPTION_STR ACTIONS_SYNOPSIS_STR
}

#### script settings ##########################

# bash-lib settings
MANPAGE_NODEPEDENCY=true

##@ _BACKUP_DIR _TARGET _PATHARG
# paths
declare -x _BACKUP_DIR="${_BASEDIR}/backup/"
declare -x _TARGET=`pwd`
declare -x _PATHARG

##@ SCRIPTMAN : bool to enable when an action file is loaded just for "usage" infos
declare -x SCRIPTMAN=false

##@ ACTION ACTION_FILE ACTION_INDEX
# per action vars
declare -x ACTION
declare -x ACTION_FILE
declare -xi ACTION_INDEX

##@ ACTION_LIST ACTIONS_SYNOPSIS ACTIONS_OPTIONS ACTIONS_DESCRIPTION
# all actions vars
declare -xa ACTIONS_LIST=()
declare -xa ACTIONS_SYNOPSIS=()
declare -xa ACTIONS_OPTIONS=()
declare -xa ACTIONS_DESCRIPTION=()

##@ ACTIONS_CFGVARS =( DEFAULT_USER_CONFIG_FILE DEFAULT_PROJECT_CONFIG_FILE DEFAULT_BASHLIBRARY_PATH )
declare -xa ACTIONS_CFGVARS=(DEFAULT_USER_CONFIG_FILE DEFAULT_PROJECT_CONFIG_FILE DEFAULT_BASHLIBRARY_PATH)
load_actions_infos

# script infos
declare -rx LICENSE_TYPE="GPL-3.0"
declare -rx LICENSE_URL="http://www.gnu.org/licenses/gpl-3.0.html"
declare -rx SOURCES_HOME="https://github.com/atelierspierrot/dev-tools"
declare -x COMMON_OPTIONS_GLOBAL="-h|-V"
declare -x COMMON_OPTIONS_INTERACT="-f|-i|-q|-v"
OPTIONS_ALLOWED="p:${COMMON_OPTIONS_ALLOWED}"
LONG_OPTIONS_ALLOWED="${COMMON_LONG_OPTIONS_ALLOWED}"
COPYRIGHT="Copyright (c) 2013-2014 Les Ateliers Pierrot <http://www.ateliers-pierrot.fr/>"
SCRIPT_VCS='git'
LICENSE="License ${LICENSE_TYPE}: <${LICENSE_URL}>"
SOURCES="Sources & updates: <${SOURCES_HOME}>"
ADDITIONAL_INFO="This is free software: you are free to change and redistribute it ; there is NO WARRANTY, to the extent permitted by law.";
DESCRIPTION="Packages development & deployment facilities"
DESCRIPTION_MANPAGE="This helper script will assist you to execute various common actions on a project and its environment dependencies during development.\n\
Run option 'help <action>' to see the help about a specific action and use option '--dry-run' to make dry runs.";

# actions infos
declare -x DEPLOY_ACTIONS_HELP="Run 'help action' to get help about a specific action.";
declare -rx ACTION_PRESENTATION_MASK="## Help for action \"<bold>%s</bold>\" (version %s)";
declare -rx ACTION_SYNOPSIS_MASK="${0}  %s  [common options]  %s  --";
declare -x ACTIONS_DESCRIPTION_STR=""
declare -x ACTIONS_SYNOPSIS_STR=""
prepare_actionslist_strings
declare -x OPTIONS="\n\
\tinstall\t\t\tinstall the package somewhere in your sytem\n\
\tuninstall\t\tuninstall an installed package\n\
\tself-check\t\tcheck if an installed package needs to be updated\n\
\tself-update\t\tupdate an installed package\n\
\tlist-actions\t\tsee available actions list\n\n\
\t-p, --path=PATH\t\tthe project path (default is 'pwd' - 'PATH' must exist)\n\
\t-h, --help\t\tshow this information message \n\
\t-v, --verbose\t\tincrease script verbosity \n\
\t-q, --quiet\t\tdecrease script verbosity, nothing will be written unless errors \n\
\t-f, --force\t\tforce some commands to not prompt confirmation \n\
\t-i, --interactive\task for confirmation before any action \n\
\t-x, --debug\t\tsee commands to run but not run them actually\n\
\t--dry-run\t\talias of '-x'";
declare -x SYNOPSIS_MANPAGE="~\$ <bold>${0}</bold>  [<underline>ACTION</underline>]  -[<underline>COMMON OPTIONS</underline>]  -[<underline>SCRIPT OPTIONS</underline> [=<underline>VALUE</underline>]]  --"
declare -x SYNOPSIS_ERROR="${0}  [${COMMON_OPTIONS_GLOBAL}]  [${COMMON_OPTIONS_INTERACT}]  [-x|--dry-run]  [-p|--project=path] ...${ACTIONS_SYNOPSIS_STR}";
declare -x SYNOPSIS="${SYNOPSIS_ERROR}"

#### internal lib ##########################

#### action_file ( action name )
# find action file and its filename in ACTION_FILE
action_file () {
    local ACTION="$1"
    if [ ! -z "${ACTION}" ]; then
        ACTION_FILE="${_BASEDIR}/${ACTION}.sh"
        # hack to allow direct call of a file as action (with path from root)
        if [ ! -f "${ACTIONFILE}" ]; then
            TMP_ACTIONFILE="${_REALDIRPATH}/${ACTION}"
            if [ -f "${TMP_ACTIONFILE}" ]; then
                ACTION_FILE="${TMP_ACTIONFILE}"
            fi
        fi    
    fi
    export ACTION_FILE
}

#### action_exists ( action name , error[=true] )
# test if an action exists and throw an error if not
action_exists () {
    local ACTION="$1"
    local THROWERROR="${2:-true}"
    action_file "${ACTION}"
    if [ -z "${ACTION_FILE}" -o ! -f "${ACTION_FILE}" ]&& $THROWERROR; then
        simple_error "unknown action '${ACTION}'"
    fi
    return 0
}

#### load_action ( action name )
load_action () {
    local ACTION="$1"
    find_action "${ACTION}"
    # which options are allowed
    if [ ! -z "${ACTION_INDEX}" ]; then
        action_file "${ACTION}"
        if [ ! -z "${ACTIONS_OPTIONS[$ACTION_INDEX]}" ]; then
            ALLOWED_OPTIONS="${COMMON_OPTIONS_ARGS}${ACTIONS_OPTIONS[$ACTION_INDEX]}"
        fi
        if [ ! -z "${ACTIONS_SYNOPSIS[$ACTION_INDEX]}" ]
            then SYNOPSIS_ERROR="${0}  ${ACTION}  ...\n\t[${COMMON_OPTIONS_GLOBAL}]  [${COMMON_OPTIONS_INTERACT}]  [-x|--dry-run]  [-p|--project=path] ...\n\t${ACTIONS_SYNOPSIS[$ACTION_INDEX]}";
            else SYNOPSIS_ERROR="${0}  ${ACTION}  ...\n\t[${COMMON_OPTIONS_GLOBAL}]  [${COMMON_OPTIONS_INTERACT}]  [-x|--dry-run]  [-p|--project=path] ";
        fi
    fi
    export ALLOWED_OPTIONS SYNOPSIS_ERROR
    return 0
}

#### find_action ( action name )
# find action and load its index in ACTION_INDEX
find_action () {
    local ACTION="$1"
    if [ ! -z "${ACTION}" ]; then
        for i in ${!ACTIONS_LIST[*]}; do
            if [ "${ACTIONS_LIST[$i]}" == "${ACTION}" ]; then
                export ACTION_INDEX=${i}
            fi
        done
    fi
    return 0
}

#### list_actions ()
# list available action scripts
list_actions () {
    local actions_str="\n<underline>Available actions:</underline>\n${DEPLOY_ACTIONS_HELP}\n"
    for i in ${!ACTIONS_LIST[*]}; do
        myaction=${ACTIONS_LIST[$i]}
        actions_str+="\n    <bold>${myaction%%.sh}</bold>\n"
        itemdesc=${ACTIONS_DESCRIPTION[$i]}
        if [ -n "${itemdesc}" ]; then
            actions_str+="\t${itemdesc/\\n/\\n\t}";
        fi
        itemsyn=${ACTIONS_SYNOPSIS[$i]}
        if [ -n "${itemsyn}" ]; then
            actions_str+="\n\t<${COLOR_COMMENT}>`printf \"${ACTION_SYNOPSIS_MASK}\" \"${itemstr}\" \"${itemsyn}\"`</${COLOR_COMMENT}>\n";
        else
            actions_str+="\n\t<${COLOR_COMMENT}>`printf \"${ACTION_SYNOPSIS_MASK}\" \"${itemstr}\" ''`</${COLOR_COMMENT}>\n";
        fi
    done
    actions_str+="\n<${COLOR_COMMENT}>`library_info`</${COLOR_COMMENT}>";
    parse_color_tags "${actions_str}\n"
}

#### action_usage ( action name , action file )
# usage string per action
action_usage () {
    local ACTION_FILENAME="$1"
    local ACTION_FILE="$2"
    local TMP_USAGE=$(parse_color_tags  "`script_short_title`")
    export SCRIPTMAN=true
    if [ -f ${ACTION_FILE} ]; then
        init_action
        source "${ACTION_FILE}"
        TMP_USAGE+="\n\n`printf \"${ACTION_PRESENTATION_MASK}\" \
            \"${ACTION_NAME:-${ACTION_FILENAME}}\" \
            \"${ACTION_VERSION:-?}\"`";
        if [ -n "${ACTION_DESCRIPTION}" ]; then
            TMP_USAGE+="\n${ACTION_DESCRIPTION}";
        fi
        if [ -n "${ACTION_ADDITIONAL_INFO}" ]; then
            TMP_USAGE+="\n${ACTION_ADDITIONAL_INFO}";
        fi
        TMP_USAGE+="\n\n<bold>usage:</bold>\
\t`printf \"${ACTION_SYNOPSIS_MASK}\" \"${ACTION_FILENAME}\" \"${ACTION_SYNOPSIS}\"`";
        if [ -n "${ACTION_OPTIONS}" ]; then
            TMP_USAGE+="\n\n\t${ACTION_OPTIONS}";
        fi
        if [ -n "${ACTION_CFGVARS}" ]; then
            TMP_USAGE+="\n\n<bold>config vars:</bold>\t<${COLOR_NOTICE}>${ACTION_CFGVARS[@]}</${COLOR_NOTICE}>";
        fi
        if [ -n "${ACTION_FILE}" ]; then
            TMP_USAGE+="\n\n<bold>file:</bold>\t${ACTION_FILE}";
        fi
        TMP_USAGE+="\n\n<${COLOR_COMMENT}>`library_info`</${COLOR_COMMENT}>";
        parse_color_tags "${TMP_USAGE}"
    else
        simple_error "Action file ${ACTION_FILE} not found!"
    fi
    export SCRIPTMAN=false
    return 0;
}

#### show_help ()
show_help () {
    if ${HELP_LESS} || ${HELP_MORE}; then
        local tmp_file=$(get_tempfile_path devtoolsusage)
    fi
    if [ -z ${ACTION} ]
    then
        if ${HELP_LESS} || ${HELP_MORE}
        then script_long_usage > "${tmp_file}"
        else script_long_usage
        fi
    else
        action_exists "${ACTION}"
        if ${HELP_LESS} || ${HELP_MORE}
        then action_usage "${ACTION}" "${ACTION_FILE}" > "${tmp_file}";
        else action_usage "${ACTION}" "${ACTION_FILE}";
        fi
    fi
    local _done=false
    if [ "${#SCRIPT_PROGRAMS[@]}" -gt 0 ]; then
        if $(in_array "less" "${SCRIPT_PROGRAMS[@]}"); then
            cat "${tmp_file}" | less -cfre~
            _done=true
        elif $(in_array "more" "${SCRIPT_PROGRAMS[@]}"); then
            cat "${tmp_file}" | more -cf
            _done=true
        fi
    fi
    if ! ${_done}; then cat "${tmp_file}"; fi
    exit 0
}

#### root_required ()
# ensure current user is root
root_required () {
    THISUSER=`whoami`
    if [ "${THISUSER}" != "root" ]; then
        error "You need to run this as a 'sudo' user!"
    fi
}

#### targetdir_required ()
# ensure the project root directory is defined
targetdir_required () {
    if [ -z "${_TARGET}" ]; then
        prompt 'Target directory of the project to work on' `pwd` ''
        export _TARGET=${USERRESPONSE}
    fi
    if [ ! -d "${_TARGET}" ]; then error "Unknown root directory '${_TARGET}' !"; fi
    load_target_config
}

#### backupdir_required ()
# ensure the project backup directory exists
backupdir_required () {
    if [ ! -d "${_BACKUP_DIR}" ]; then
        mkdir "${_BACKUP_DIR}" && chmod 775 "${_BACKUP_DIR}"
        if [ ! -d "${_BACKUP_DIR}" ]; then
            error "Backup directory '${_BACKUP_DIR}' can't be created (try to run this script as 'sudo') !"
        fi
    fi
}

#### trigger_event ( command )
## trigger a user defined command for an event
trigger_event () {
    iexec "$1"
}

#### load_user_config ()
# overwrite current deploy config with user's one if so
# searched in '$HOME/.devtools_globals'
load_user_config () {
    if [ ! -z ${HOME} ]; then
        local target_configfile=$(realpath "${HOME}/${DEFAULT_USER_CONFIG_FILE}")
        if [ -f "${target_configfile}" ]; then
            source "${target_configfile}"
        fi
        for p in "${ACTIONS_CFGVARS[@]}"; do
            export "${p}"
        done
    fi
}

#### load_target_config ()
# overwrite current deploy config with target's custom one if so
load_target_config () {
    local target_configfile=$(realpath "${_TARGET}/${DEFAULT_PROJECT_CONFIG_FILE}")
    if [ -f "${target_configfile}" ]; then
        source "${target_configfile}"
    fi
    for p in "${ACTIONS_CFGVARS[@]}"; do
        export "${p}"
    done
}

#### internal actions ##########################

helpAction () {
    get_next_argument
    if [ ${ARGIND} -gt 1 ]
    then
        export ACTION="${ARGUMENT}"
        load_action "${ACTION}"
    else
        export ACTION=''
    fi
    show_help
}

usageAction () {
    script_usage
}

installAction () {
    local _info=${1:-true}
    local _git_get_version=$(git_get_version)
    _PWD=`pwd`
    _BIN=${_PATHARG}
    if [ -z ${_BIN} ]; then
        _BIN=${HOME}/bin
    fi
    if [ ! -d ${_BIN} ]; then mkdir ${_BIN}; fi
    if [ "${_info}" == 'true' ]; then
        verecho "> installing ${NAME} to \"${_BIN}\""
    fi
    iexec "cp ${_PWD}/devtools.sh ${_BIN} \
        && cp -R ${_PWD}/devtools-actions ${_BIN} \
        && cp ${_PWD}/devtools.conf ${_BIN} \
        && cp ${_PWD}/devtools.man ${_BIN} \
        && chmod a+x ${_BIN}/devtools.sh \
        && echo $_git_get_version > ${_BIN}/devtools.version";
    local _libdir=${_BIN}/piwi-bash-library
    if [ ! -d ${_libdir} ]; then
        iexec "cp -R ${_PWD}/piwi-bash-library ${_BIN}"
    fi
    if [ "${_info}" == 'true' ]; then
        quietecho "OK - ${NAME} version [${_git_get_version}] installed in \"${_BIN}\""
    fi
}

uninstallAction () {
    _BIN=${_PATHARG}
    if [ -z ${_BIN} ]; then
        _BIN=${HOME}/bin
    fi
    verecho "> uninstalling ${NAME} from \"${_BIN}\""
    iexec "for FILE in \$(find ${_BIN} -name \"devtools*\"); do rm -rf \${FILE}; done"
    local _libdir=${_BIN}/piwi-bash-library
    if [ -d ${_libdir} ]; then
        iexec "rm -rf ${_libdir}"
    fi
    quietecho "OK - ${NAME} un-installed from \"${_BIN}\""
}

selfCheckAction () {
    _BIN=${_PATHARG}
    if [ -z ${_BIN} ]; then
        _BIN=${HOME}/bin
    fi
    local target_vers=$(git_get_version)
    local target_sha=$(git_get_version_extract_sha "${target_vers}")
    local target_branch=$(git_get_version_extract_branch "${target_vers}")
    if [ "${target_branch}" == 'master' ]; then target_branch='HEAD'; fi;
    local remote_vers=$(git fetch --all 1> /dev/null; git ls-remote | awk "/${target_branch}/ {print \$1}")
    local remote_sha=$(git_get_version_extract_sha "${remote_vers}")
    local remote_branch=$(git_get_version_extract_branch "${remote_vers}")
    if [ "${target_sha}" != "${remote_sha}" ]
        then echo "A new version is available ...  You should run '$0 self-update [opts]' to get last version."; return 1;
        else
            echo "OK - ${NAME} is up-to-date"
            if [ -f ${_BIN}/devtools.sh ]; then touch "${_BIN}/devtools.sh";
            elif [ -f ${_BIN}/devtools ]; then touch "${_BIN}/devtools";
            fi
    fi
}

selfUpdateAction () {
    _BIN=${_PATHARG}
    if [ -z ${_BIN} ]; then
        _BIN=${HOME}/bin
    fi
    verecho "> updating ${NAME} in \"${_BIN}\""
    installAction false
    local _git_get_version=$(git_get_version)
    quietecho "OK - ${NAME} updated to version [${_git_get_version}] in \"${_BIN}\""
}

listActions () {
    script_title
    list_actions
#    parse_color_tags "${DESCRIPTION_LISTACTIONS}"
}

#### first setup & options treatment ##########################

# transform options and get action
rearrange_script_options "$@"
[ "${#SCRIPT_OPTS[@]}" -gt 0 ] && set -- "${SCRIPT_OPTS[@]}";
[ "${#SCRIPT_ARGS[@]}" -gt 0 ] && set -- "${SCRIPT_ARGS[@]}";
[ "${#SCRIPT_OPTS[@]}" -gt 0 -a "${#SCRIPT_ARGS[@]}" -gt 0 ] && set -- "${SCRIPT_OPTS[@]}" -- "${SCRIPT_ARGS[@]}";

# action requested
get_next_argument
ACTION="${ARGUMENT}"
if [ -n "${ACTION}" ]; then load_action "${ACTION}"; fi

# common options parsing
parse_common_options_strict
if ${DEBUG}; then library_debug "$*" && echo; fi
OPTIND=1
while getopts ":at:${OPTIONS_ALLOWED}" OPTION; do
    OPTARG="${OPTARG#=}"
    case ${OPTION} in
        p) export _PATHARG=${OPTARG}; export _TARGET=${_PATHARG};;
        -) LONGOPTARG="`get_long_option_arg \"${OPTARG}\"`"
            case ${OPTARG} in
                path*) export _PATHARG=${OPTARG}; export _TARGET=${_PATHARG};;
                ?) ;;
            esac ;;
        ?);;
    esac
done

# special help option
if [ ! -z "$ACTION" ]; then
    case "$ACTION" in
        help) helpAction; exit 0;;
        usage) usageAction; exit 0;;
        install) installAction; exit 0;;
        uninstall) uninstallAction; exit 0;;
        self-update) selfUpdateAction; exit 0;;
        self-check) selfCheckAction; exit 0;;
        list-actions) listActions; exit 0;;
        *) ;;
    esac
fi

# target project
targetdir_required

# config
load_user_config
load_target_config

# let's go
if [ ! -z "${ACTION}" ]
then
    action_exists "${ACTION}"
    ACTION_TOUPPER=$(echo "${ACTION}" | tr '[:lower:]' '[:upper:]')
    PREACTION="EVENT_PRE_${ACTION_TOUPPER}"
    POSTACTION="EVENT_POST_${ACTION_TOUPPER}"
    # executing requested action
    export _BASEDIR _BACKUP_DIR _TARGET
    if [ ! -z "${!PREACTION}" ]; then
        trigger_event "${!PREACTION}"
    fi
    source "${ACTION_FILE}"
    if [ ! -z "${!POSTACTION}" ]; then
        trigger_event "${!POSTACTION}"
    fi
else
    simple_error "no action to execute"
fi

exit 0
# Endfile
