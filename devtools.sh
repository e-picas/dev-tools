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
# ------------------
#
# Global help : `devtools.sh -h` OR `devtools.sh help`
# Action help : `devtools.sh action -h` OR `devtools.sh help action`
# Action usage : `devtools.sh action [-vix] -p=PROJECT_PATH [action options]`
#

###### Current version
declare -x NAME="DevTools"
declare -rx VERSION="1.2.4"

###### First paths
declare -rx _REALPATH="$0"
declare -rx _REALDIRPATH="`dirname $_REALPATH`"
declare -rx _DEVTOOLS_CONFIGFILE="devtools.conf"
declare -rx _DEVTOOLS_ACTIONSDIR="devtools-actions"

#### findRequirements ( path , info string )
# search for a relative or root path
# this needs to be defined first as it is used to find the library
findRequirements() {
    REQFILE="$1"
    ROOTREQFILE="${_REALDIRPATH}/${REQFILE}"
    REQINFO="$2"
    if [ -e "$REQFILE" ]; then
        echo "$REQFILE"
        return 0
    elif [ -e "$ROOTREQFILE" ]; then
        echo "$ROOTREQFILE"
        return 0
    else
        PADDER=$(printf '%0.1s' "#"{1..1000})
        printf "\n### %*.*s\n    %s\n    %s\n%*.*s\n\n" 0 $(($(tput cols)-4)) "ERROR! $PADDER" \
            "Unable to find required $REQINFO '$REQFILE'!" \
            "Sent in '$0' line '${LINENO}' by '`whoami`' - pwd is '`pwd`'" \
            0 $(tput cols) "$PADDER";
        exit 1
    fi
}

######## Inclusion of the config
declare -rx CFGFILE=`findRequirements "${_DEVTOOLS_CONFIGFILE}" "configuration file"`
if [ -f "$CFGFILE" ]; then source "$CFGFILE"; else echo "$CFGFILE"; exit 1; fi

######## Inclusion of the lib
declare -rx LIBFILE=`findRequirements "${DEFAULT_BASHLIBRARY_PATH}" "bash library"`
if [ -f "$LIBFILE" ]; then source "$LIBFILE"; else echo "$LIBFILE"; exit 1; fi

######## Path of the actions
declare -rx _BASEDIR=`findRequirements "${_DEVTOOLS_ACTIONSDIR}" "actions directory"`
if [ ! -d "$_BASEDIR" ]; then echo "$_BASEDIR"; exit 1; fi

#### load_actions_infos ()
# load the available actions in $ACTIONS_LIST
# load the available actions synopsis in $ACTIONS_SYNOPSIS
# load the available actions synopsis in $ACTIONS_DESCRIPTIONS
# this needs to be defined here as it is used for strings below
load_actions_infos () {
    export SCRIPTMAN=true
    for action in $_BASEDIR/*.sh; do
        ACTION_SYNOPSIS=''
        ACTION_DESCRIPTION=''
        ACTION_OPTIONS_ARGS=''
        ACTION_LONGDESCRIPTION=''
        ACTION_CFGVARS=''
        myaction=${action##$_BASEDIR/}
        pos=${#ACTIONS_LIST[@]}
        source "${action}"
        ACTIONS_LIST[$pos]="${myaction%%.sh}"
        if [ -n "$ACTION_SYNOPSIS" ]; then
            ACTIONS_SYNOPSIS[$pos]="${ACTION_SYNOPSIS}"
        fi
        if [ -n "$ACTION_DESCRIPTION" ]; then
            ACTIONS_DESCRIPTIONS[$pos]="${ACTION_DESCRIPTION}"
        fi
        if [ -n "$ACTION_CFGVARS" ]; then
            ACTIONS_CFGVARS=("${ACTIONS_CFGVARS[@]}" "${ACTION_CFGVARS[@]}")
        fi
        if [ -n "$ACTION_OPTIONS_ARGS" ]; then
            ACTION_OPTIONS_ARGS[$pos]="${ACTION_OPTIONS_ARGS}"
        fi
    done
    export ACTIONS_LIST ACTIONS_SYNOPSIS ACTIONS_DESCRIPTIONS ACTIONS_CFGVARS ACTION_OPTIONS_ARGS
    export SCRIPTMAN=false
}

#### script settings ##########################

# bash-lib settings
MANPAGE_NODEPEDENCY=true

# paths
declare -x _BACKUP_DIR="${_BASEDIR}/backup/"
declare -x _TARGET=`pwd`
declare -x SCRIPTMAN=false

# per action vars
declare -x ACTION
declare -x ACTION_FILE
declare -x ACTION_INDEX
declare -x OPTIONS_ALLOWED="p:${COMMON_OPTIONS_ALLOWED}"
declare -x LONG_OPTIONS_ALLOWED="${COMMON_LONG_OPTIONS_ALLOWED}"
declare -xa SCRIPT_OPTS=()

# all actions vars
declare -xa ACTIONS_LIST=()
declare -xa ACTIONS_SYNOPSIS=()
declare -xa ACTIONS_OPTIONS_ARGS=()
declare -xa ACTIONS_DESCRIPTIONS=()
declare -xa ACTIONS_CFGVARS=( DEFAULT_USER_CONFIG_FILE DEFAULT_PROJECT_CONFIG_FILE DEFAULT_BASHLIBRARY_PATH )
load_actions_infos

# script infos
declare -x PRESENTATION="Packages development & deployment facilities"
declare -x SYNOPSIS="~\$ <bold>${0}</bold>  [<underline>ACTION</underline>]  -[<underline>COMMON OPTIONS</underline>]  -[<underline>SCRIPT OPTIONS</underline> [=<underline>VALUE</underline>]]  --"
declare -x DEPLOY_HELP="Run option '-h' for help.";
declare -x DEPLOY_ACTIONS_HELP="Run option 'help action' for help about a specific action.";
declare -x SHORT_DESCRIPTION="This helper script will assist you to execute various common actions on a project and its environment dependencies during development.\n\
\tRun option '<bold>help action</bold>' to see the help about a specific action and use option '<bold>--dry-run</bold>' to make dry runs.";
declare -x SEE_ALSO="This is free software: you are free to change and redistribute it ; there is NO WARRANTY, to the extent permitted by law.\n\
\tThis tool is an open source stuff licensed under GNU/GPL v3: <http://github.com/atelierspierrot/devtools>\n\
\tTo transmit a bug or an evolution: <http://github.com/atelierspierrot/devtools/issues>\n\
\tThis tool is based on the Piwi Bash Library: <http://github.com/atelierspierrot/piwi-bash-library>";
declare -x COMMON_OPTIONS_GLOBAL="-h|-V"
declare -x COMMON_OPTIONS_INTERACT="-f|-i|-q|-v"

# actions infos
declare -rx ACTION_PRESENTATION_MASK="Help for action \"<bold>%s</bold>\"";
declare -rx ACTION_SYNOPSIS_MASK="~\$ <bold>${0}</bold>  %s  [<underline>common options</underline>]  %s --";
actionsstr=""
actionsdescription=""
actionssynopsis=""
for i in ${!ACTIONS_LIST[*]}; do
    itemstr=${ACTIONS_LIST[$i]}
    if [ "${#actionsstr}" == 0 ]; then
        actionsstr="${itemstr}"
    else
        actionsstr="${actionsstr} | ${itemstr}"
    fi
    actionsdescription="${actionsdescription}\n\n\t<bold>${itemstr}</bold>\n"
    itemdesc=${ACTIONS_DESCRIPTIONS[$i]}
    if [ -n "${itemdesc}" ]; then
        actionsdescription="${actionsdescription}\t${itemdesc}";
    fi
    itemsyn=${ACTIONS_SYNOPSIS[$i]}
    if [ -n "${itemsyn}" ]; then
        actionsdescription="${actionsdescription}\n\t`printf \"${ACTION_SYNOPSIS_MASK}\" \"${itemstr}\" \"${itemsyn}\"`";
        actionssynopsis="${actionssynopsis}\n\t... ${itemstr} ${itemsyn}"
    else
        actionsdescription="${actionsdescription}\n\t`printf \"${ACTION_SYNOPSIS_MASK}\" \"${itemstr}\" ''`";
        actionssynopsis="${actionssynopsis}\n\t... ${itemstr}"
    fi
done
declare -x DESCRIPTION="${SHORT_DESCRIPTION}\n\n<bold>AVAILABLE ACTIONS</bold>${actionsdescription}"
declare -x OPTIONS="Below is a list of common options available ; each action can accepts other options.\n\n\
\t<bold>-p | --path=PATH</bold>\tthe project path (default is 'pwd' - 'PATH' must exist)\n\
\t<bold>-h | --help</bold>\t\tshow this information message \n\
\t<bold>-v | --verbose</bold>\t\tincrease script verbosity \n\
\t<bold>-q | --quiet</bold>\t\tdecrease script verbosity, nothing will be written unless errors \n\
\t<bold>-f | --force</bold>\t\tforce some commands to not prompt confirmation \n\
\t<bold>-i | --interactive</bold>\task for confirmation before any action \n\
\t<bold>-x | --debug</bold>\t\tsee commands to run but not run them actually\n\
\t<bold>--dry-run</bold>\t\talias of '-x'\n\
\n${OPTIONS_USAGE_INFOS}";
declare -x SYNOPSIS_ERROR="${0}  [${COMMON_OPTIONS_GLOBAL}]  [${COMMON_OPTIONS_INTERACT}]  [-x|--dry-run]  [-p|--project=path] ...\
${actionssynopsis}";

#### internal lib ##########################

#### script_version ( lib = false )
## this function must echo an information about script NAME and VERSION
## setting `$lib` on true will add the library infos
script_version () {
    local TITLE="${NAME}"
    if [ "x$VERSION" != 'x' ]; then TITLE="${TITLE} ${VERSION}"; fi    
    _echo "${TITLE}"
    if ! $QUIET && isgitclone; then
        local gitcmd=$(which git)
        if [ -n "$gitcmd" ]; then
            _echo "[git: `git rev-parse --abbrev-ref HEAD` `git rev-parse HEAD`]"
        fi
    fi
    return 0
}

#### action_file ( action name )
# find action file
action_file () {
    local ACTION="$1"
    if [ ! -z "$ACTION" ]; then
        ACTION_FILE="${_BASEDIR}/${ACTION}.sh"
        # hack to allow direct call of a file as action (with path from root)
        if [ ! -f "$ACTIONFILE" ]; then
            TMP_ACTIONFILE="${_REALDIRPATH}/${ACTION}"
            if [ -f "$TMP_ACTIONFILE" ]; then
                ACTION_FILE="$TMP_ACTIONFILE"
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
    action_file "$ACTION"
    if [ -z "$ACTION_FILE" -o ! -f "$ACTION_FILE" ]; then
        simple_error "unknown action '${ACTION}'"
    fi
    return 0
}

#### load_action ( action name )
load_action () {
    local ACTION="$1"
    find_action $ACTION
    # which options are allowed
    if [ ! -z "$ACTION_INDEX" ]; then
        action_file $ACTION
        if [ ! -z "${ACTIONS_OPTIONS_ARGS[$ACTION_INDEX]}" ]; then
            ALLOWED_OPTIONS="${COMMON_OPTIONS_ARGS}${ACTIONS_OPTIONS_ARGS[$ACTION_INDEX]}"
        fi
        if [ ! -z "${ACTIONS_SYNOPSIS[$ACTION_INDEX]}" ]
            then SYNOPSIS_ERROR="${0}  ${ACTION}  ...\n\t[${COMMON_OPTIONS_GLOBAL}]  [${COMMON_OPTIONS_INTERACT}]  [-x|--dry-run]  [-p|--project=path] ...\n\t${ACTIONS_SYNOPSIS[$ACTION_INDEX]}";
            else SYNOPSIS_ERROR="${0}  ${ACTION}  ...\n\t[${COMMON_OPTIONS_GLOBAL}]  [${COMMON_OPTIONS_INTERACT}]  [-x|--dry-run]  [-p|--project=path] ";
        fi
    fi
    export ALLOWED_OPTIONS SYNOPSIS_ERROR SYNOPSIS_ERROR
    return 0
}

#### find_action ( action name )
# find action and load its index in ACTION_INDEX
find_action () {
    local ACTION="$1"
    if [ ! -z "$ACTION" ]; then
        for i in ${!ACTIONS_LIST[*]}; do
            if [ "${ACTIONS_LIST[$i]}" == "$ACTION" ]; then
                export ACTION_INDEX=$i
            fi
        done
    fi
    return 0
}

#### action_usage ( action name, action file )
# usage string per action
action_usage () {
    local ACTION_NAME="$1"
    local ACTION_FILE="$2"
    export SCRIPTMAN=true
    if [ -f $ACTION_FILE ]; then
        ACTION_SYNOPSIS=''
        ACTION_DESCRIPTION=''
        ACTION_OPTIONS=''
        ACTION_CFGVARS=''
        source "$ACTION_FILE"
        local TMP_USAGE="\n<bold>NAME</bold>\n\
\t`printf \"${ACTION_PRESENTATION_MASK}\" \"${ACTION_NAME}\"`\n\
\t${NAME}\n\n\
<bold>SYNOPSIS</bold>\n\
\t`printf \"${ACTION_SYNOPSIS_MASK}\" \"${ACTION_NAME}\" \"${ACTION_SYNOPSIS}\"`";
        if [ -n "${ACTION_DESCRIPTION}" ]; then
            TMP_USAGE="${TMP_USAGE}\n\n<bold>DESCRIIPTION</bold>\n\t${ACTION_DESCRIPTION}";
        fi
        if [ -n "${ACTION_OPTIONS}" ]; then
            TMP_USAGE="${TMP_USAGE}\n\n<bold>OPTIONS</bold>\n\t${ACTION_OPTIONS}";
        fi
        if [ -n "${ACTION_CFGVARS}" ]; then
            TMP_USAGE="${TMP_USAGE}\n\n<bold>ENVIRONMENT</bold>\n\tAvailable configuration variables: <${COLOR_NOTICE}>${ACTION_CFGVARS[@]}</${COLOR_NOTICE}>";
        fi
        if [ -n "${ACTION_FILE}" ]; then
            TMP_USAGE="${TMP_USAGE}\n\n<bold>FILE</bold>\n\t<underline>${ACTION_FILE}</underline>";
        fi
        local TMP_VERS="`library_info`"
        TMP_USAGE="${TMP_USAGE}\n\n<${COLOR_COMMENT}>${TMP_VERS}</${COLOR_COMMENT}>";
        parsecolortags "$TMP_USAGE"
    else
        simple_error "Action file $ACTION_FILE not found!"
    fi
    export SCRIPTMAN=false
    return 0;
}

#### show_help ()
show_help () {
    if $HELP_LESS || $HELP_MORE; then
        local tmp_file=$(gettempfilepath devtoolsusage)
    fi
    if [ -z $ACTION ]
    then
        if $HELP_LESS || $HELP_MORE
        then usage > "$tmp_file"
        else usage
        fi
    else
        action_exists "$ACTION"
        if $HELP_LESS || $HELP_MORE
        then action_usage "$ACTION" "$ACTION_FILE" > "$tmp_file";
        else action_usage "$ACTION" "$ACTION_FILE";
        fi
    fi
    local _done=false
    if [ "${#SCRIPT_PROGRAMS[@]}" -gt 0 ]; then
        if $(in_array "less" "${SCRIPT_PROGRAMS[@]}"); then
            cat "$tmp_file" | less -cfre~
            _done=true
        elif $(in_array "more" "${SCRIPT_PROGRAMS[@]}"); then
            cat "$tmp_file" | more -cf
            _done=true
        fi
    fi
    if ! $_done; then cat "$tmp_file"; fi
    exit 0
}

#### root_required ()
# ensure current user is root
root_required () {
    THISUSER=`whoami`
    if [ "$THISUSER" != "root" ]; then
        error "You need to run this as a 'sudo' user!"
    fi
}

#### targetdir_required ()
# ensure the project root directory is defined
targetdir_required () {
    if [ -z "$_TARGET" ]; then
        prompt 'Target directory of the project to work on' `pwd` ''
        export _TARGET=$USERRESPONSE
    fi
    if [ ! -d "$_TARGET" ]; then error "Unknown root directory '${_TARGET}' !"; fi
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
    if [ ! -z $HOME ]; then
        local target_configfile=$(realpath "${HOME}/${DEFAULT_USER_CONFIG_FILE}")
        if [ -f "$target_configfile" ]; then
            source "$target_configfile"
        fi
        for p in "${ACTIONS_CFGVARS[@]}"; do
            export "$p"
        done
    fi
}

#### load_target_config ()
# overwrite current deploy config with target's custom one if so
load_target_config () {
    local target_configfile=$(realpath "${_TARGET}/${DEFAULT_PROJECT_CONFIG_FILE}")
    if [ -f "$target_configfile" ]; then
        source "$target_configfile"
    fi
    for p in "${ACTIONS_CFGVARS[@]}"; do
        export "$p"
    done
}

#### internal actions ##########################

helpAction () {
    getnextargument
    if [ $ARGIND -gt 1 ]; then
        export ACTION="$ARGUMENT"
        load_action "$ACTION"
    else export ACTION=''
    fi
    show_help
}

usageAction () {
    echo "${SYNOPSIS_ERROR}"
    exit 0
}

installAction () {
    echo "todo"
    exit 0
}

uninstallAction () {
    echo "todo"
    exit 0
}

selfCheckAction () {
    echo "todo"
    exit 0
}

selfUpdateAction () {
    echo "todo"
    exit 0
}

#### first setup & options treatment ##########################

# transform options and get action
rearrangescriptoptions "$@"
[ "${#SCRIPT_OPTS[@]}" -gt 0 ] && set -- "${SCRIPT_OPTS[@]}";
[ "${#SCRIPT_ARGS[@]}" -gt 0 ] && set -- "${SCRIPT_ARGS[@]}";
[ "${#SCRIPT_OPTS[@]}" -gt 0 -a "${#SCRIPT_ARGS[@]}" -gt 0 ] && set -- "${SCRIPT_OPTS[@]}" -- "${SCRIPT_ARGS[@]}";

# action requested
getnextargument
ACTION="$ARGUMENT"
if [ -n "$ACTION" ]; then load_action "$ACTION"; fi

# common options parsing
parsecommonoptions_strict
if $DEBUG; then library_debug "$*"; fi
OPTIND=1
while getopts ":at:${OPTIONS_ALLOWED}" OPTION; do
    OPTARG="${OPTARG#=}"
    case $OPTION in
        p) export _TARGET=$OPTARG;;
        -) LONGOPTARG="`getlongoptionarg \"${OPTARG}\"`"
            case $OPTARG in
                path*) export _TARGET=$LONGOPTARG;;
                ?) ;;
            esac ;;
        ?);;
    esac
done

# special help option
if [ ! -z "$ACTION" ]; then
    case "$ACTION" in
        help)  helpAction;;
        usage)  usageAction;;
        install) installAction;;
        uninstall) uninstallAction;;
        self-update) selfUpdateAction;;
        self-check) selfCheckAction;;
        *) ;;
    esac
fi

# target project
targetdir_required

# config
load_user_config
load_target_config

# let's go
if [ ! -z "$ACTION" ]
then
    action_exists "$ACTION"
    ACTION_TOUPPER=$(echo "${ACTION}" | tr '[:lower:]' '[:upper:]')
    PREACTION="EVENT_PRE_${ACTION_TOUPPER}"
    POSTACTION="EVENT_POST_${ACTION_TOUPPER}"
    # executing requested action
    export _BASEDIR _BACKUP_DIR _TARGET
    if [ ! -z "${!PREACTION}" ]; then
        trigger_event "${!PREACTION}"
    fi
    source "$ACTION_FILE"
    if [ ! -z "${!POSTACTION}" ]; then
        trigger_event "${!POSTACTION}"
    fi
else
    simple_error "no action to execute"
fi

exit 0
# Endfile
