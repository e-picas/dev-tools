#!/bin/bash
# 
# DEPLOY - dev tools
#
# deploy.sh -vi --project=PROJECT action
#

###### First paths
_REALPATH="$0"
_REALDIRPATH="`dirname $_REALPATH`"

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
CFGFILE=`findRequirements "deploy.conf" "configuration file"`
if [ -f "$CFGFILE" ]; then source "$CFGFILE"; else echo "$CFGFILE"; exit 1; fi

######## Inclusion of the lib
LIBFILE=`findRequirements "${BASHLIBRARY_PATH}" "bash library"`
if [ -f "$LIBFILE" ]; then source "$LIBFILE"; else echo "$LIBFILE"; exit 1; fi

######## Path of the actions
BASEDIRPATH=`findRequirements "deploy-actions" "actions directory"`
if [ ! -d "$BASEDIRPATH" ]; then echo "$BASEDIRPATH"; exit 1; fi

#### load_actions_infos ()
# load the available actions in $ACTIONS_LIST
# load the available actions synopsis in $ACTIONS_SYNOPSIS
# load the available actions synopsis in $ACTIONS_DESCRIPTIONS
# this needs to be defined here as it is used for strings below
load_actions_infos () {
    ACTIONS_LIST=()
    ACTIONS_SYNOPSIS=()
    ACTIONS_DESCRIPTIONS=()
    export SCRIPTMAN=true
    for action in $_BASEDIR/*.sh; do
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
    done
    export ACTIONS_LIST ACTIONS_SYNOPSIS ACTIONS_DESCRIPTIONS
    export SCRIPTMAN=false
}

#### script settings ##########################

declare -x _BASEDIR="$BASEDIRPATH"
declare -x _BACKUP_DIR="${_BASEDIR}/backup/"
declare -x _PROJECT="project"
declare -x _TARGET=`pwd`
declare -x ACTION
declare -x ACTION_DESCRIPTION=""
declare -x SCRIPTMAN=false
declare -xa ACTIONS_LIST=() && declare -xa ACTIONS_SYNOPSIS=() && declare -xa ACTIONS_DESCRIPTIONS=() && load_actions_infos
MANPAGE_NODEPEDENCY=true

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
        actionsdescription="${actionsdescription}\t${itemdesc}"
    fi
    itemsyn=${ACTIONS_SYNOPSIS[$i]}
    if [ -n "${itemsyn}" ]; then
        actionssynopsis="${actionssynopsis}\n\t${itemsyn} ..."
    fi
done

NAME="DevTools - Deployment facilities"
DESCRIPTION="This helper script will assist you in creating version tags of a git repository, deploying a project and its environment dependencies etc."
DESCRIPTION="${DESCRIPTION}\n\n<bold>AVAILABLE ACTIONS</bold>${actionsdescription}"
SYNOPSIS="$LIB_SYNOPSIS_ACTION"
OPTIONS="<bold>-p | --project=PATH</bold>\tthe project path (default is 'pwd' - 'PATH' must exist)\n\
\t<bold>-d | --working-dir=PATH</bold>\tredefine the working directory (default is 'pwd' - 'PATH' must exist)\n\
\t<bold>-h | --help</bold>\t\tshow this information message \n\
\t<bold>-v | --verbose</bold>\t\tincrease script verbosity \n\
\t<bold>-q | --quiet</bold>\t\tdecrease script verbosity, nothing will be written unless errors \n\
\t<bold>-f | --force</bold>\t\tforce some commands to not prompt confirmation \n\
\t<bold>-i | --interactive</bold>\task for confirmation before any action \n\
\t<bold>-x | --dry-run</bold>\t\tsee commands to run but not run them actually";
declare -rx SYNOPSIS_ERROR="<bold>error:</bold> no action to execute \n\
<bold>usage:</bold> ${0}  [-${COMMON_OPTIONS_ARGS}] [-x|--dry-run] ... ${actionssynopsis}\n\
\t-p | --project=path <action : ${actionsstr}>  -- \n\
Run option '-h' for help.";
COMMON_OPTIONS_ARGS="p:${COMMON_OPTIONS_ARGS}"

#### internal lib ##########################

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
}

#### trigger_event ( command )
## trigger a user defined command for an event
trigger_event () {
    iexec "$1"
}

#### first setup & options treatment ##########################

parsecomonoptions "$@"

if [ ! -d "${_BASEDIR}" ]; then
    error "Unknown dependencies directory '${_BASEDIR}' (this is where you must put your dependencies dirs/files) !"
fi

if [ ! -d "${_BACKUP_DIR}" ]; then
    mkdir "${_BACKUP_DIR}" && chmod 775 "${_BACKUP_DIR}"
    if [ ! -d "${_BACKUP_DIR}" ]; then
        error "Backup directory '${_BACKUP_DIR}' can't be created (try to run this script as 'sudo') !"
    fi
fi

OPTIND=1
options=$(getscriptoptions "$@")
ACTION=$(getlastargument $options)
while getopts "p:${COMMON_OPTIONS_ARGS}" OPTION $options; do
    OPTARG="${OPTARG#=}"
    case $OPTION in
        d|f|h|i|l|q|v|V|x) rien=rien;;
        p) _TARGET=$OPTARG;;
        -) LONGOPTARG="`getlongoptionarg \"${OPTARG}\"`"
            case $OPTARG in
                dry-run*) DEBUG=true;;
                project*) _TARGET=$LONGOPTARG;;
                \?) ;;
            esac ;;
        \?) ;;
    esac
done

#### process ##########################
if [ ! -z "$ACTION" ]
then
    ACTIONFILE="${_BASEDIR}/${ACTION}.sh"
    PREACTION="EVENT_PRE_${ACTION}"
    POSTACTION="EVENT_POST_${ACTION}"
    if [ -f "$ACTIONFILE" ]
    then
        export _BASEDIR _BACKUP_DIR _PROJECT _TARGET
        if [ ! -z "${!PREACTION}" ]; then
            trigger_event "${!PREACTION}"
        fi
        source "$ACTIONFILE"
        if [ ! -z "${!POSTACTION}" ]; then
            trigger_event "${!POSTACTION}"
        fi
    else
        error "Unknown action '${ACTION}' !"
    fi
else
    parsecolortags "${SYNOPSIS_ERROR}"
fi

exit 0
# Endfile
