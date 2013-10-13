#!/bin/bash
# 
# DEPLOY - dev tools
#
# deploy.sh -vi --project=PROJECT action
#

######## Inclusion of the lib
LIBFILE="`dirname $0`/bin/bash-library.sh"
if [ -f "$LIBFILE" ]; then source "$LIBFILE"; else
    PADDER=$(printf '%0.1s' "#"{1..1000})
    printf "\n### %*.*s\n    %s\n    %s\n%*.*s\n\n" 0 $(($(tput cols)-4)) "ERROR! $PADDER" \
        "Unable to find required library file '$LIBFILE'!" \
        "Sent in '$0' line '${LINENO}' by '`whoami`' - pwd is '`pwd`'" \
        0 $(tput cols) "$PADDER";
    exit 1
fi
######## !Inclusion of the lib

#### script settings ##########################

_REALPATH="`realpath $BASH_SOURCE`"
declare -x _BASEDIR="`dirname $_REALPATH`/deploy-actions"
declare -x _BACKUP_DIR="${_BASEDIR}/backup/"
declare -x _PROJECT="project"
declare -x _SET="full"
declare -x _TARGET
declare -x _TARGETMEDIA

declare -x ACTION
declare -x ACTION_DESCRIPTION=""
declare -x SCRIPTMAN=false
MANPAGE_NODEPEDENCY=true

NAME="DevTools - Deployment facilities"
DESCRIPTION="This helper script will assist you in creating version tags of a git repository, deploying a project and its environment dependencies etc."
SYNOPSIS="$LIB_SYNOPSIS_ACTION"
OPTIONS="<bold>-z | --actions</bold>\t\tget the list of available actions\n\
\t<bold>-p | --project=NAME</bold>\tthe project name\n\
\t<bold>-h | --help</bold>\t\tshow this information message \n\
\t<bold>-v | --verbose</bold>\t\tincrease script verbosity \n\
\t<bold>-q | --quiet</bold>\t\tdecrease script verbosity, nothing will be written unless errors \n\
\t<bold>-f | --force</bold>\t\tforce some commands to not prompt confirmation \n\
\t<bold>-i | --interactive</bold>\task for confirmation before any action \n\
\t<bold>-x | --debug</bold>\t\tsee commands to run but not run them actually \n\
\t<bold>-V | --version</bold>\t\tsee the script version when available\n\
\t<bold>-d | --working-dir=PATH</bold>\tredefine the working directory (default is 'pwd' - 'PATH' must exist)\n\
\t<bold>-l | --log=FILENAME</bold>\tdefine the log filename to use (default is '${LIB_LOGFILE}')";

#### internal lib ##########################

#### list_actions ()
# list available action scripts
list_actions () {
    local actions_str="\n<underline>Available actions:</underline>\n"
    export SCRIPTMAN=true
    for action in $_BASEDIR/*.sh; do
        myaction=${action##$_BASEDIR/}
        actions_str="${actions_str}\n    <bold>${myaction%%.sh}</bold> \n"
        source "${_BASEDIR}/${myaction}"
        if [ -n "$ACTION_DESCRIPTION" ]; then
            actions_str="${actions_str}\t${ACTION_DESCRIPTION}\n"
        fi
    done
    actions_str="${actions_str}\n<${COLOR_COMMENT}>`library_info`</${COLOR_COMMENT}>";
    parsecolortags "${actions_str}\n"
}

#### root_required ()
# ensure current user is root
root_required () {
    THISUSER=`whoami`
    if [ "$THISUSER" != "root" ]; then
        error "You need to run this as a 'sudo' user!"
    fi
}

#### project_required ()
# ensure the project name is defined
project_required () {
    if [ -z "$_PROJECT" ]; then
        prompt 'Name of the project to work on' '' ''
        export _PROJECT=$USERRESPONSE
    fi
}

#### targetdir_required ()
# ensure the project root directory is defined
targetdir_required () {
    _TARGET="$WORKINGDIR"
    if [ -z "$_TARGET" ]; then
        prompt 'Target directory of the project to work on' `pwd` ''
        export _TARGET=$USERRESPONSE
    fi
    if [ ! -d "$_TARGET" ]; then error "Unknown root directory '${_TARGET}' !"; fi
}

#### first setup ##########################

if [ ! -d "${_BASEDIR}" ]; then
    error "Unknown dependencies directory '${_BASEDIR}' (this is where you must put your dependencies dirs/files) !"
fi

if [ ! -d "${_BACKUP_DIR}" ]; then
    mkdir "${_BACKUP_DIR}" && chmod 777 "${_BACKUP_DIR}"
    if [ ! -d "${_BACKUP_DIR}" ]; then
        error "Backup directory '${_BACKUP_DIR}' can't be created (try to run this script as 'sudo') !"
    fi
fi

#### options treatment ##########################

parsecomonoptions "$@"

OPTIND=1
options=$(getscriptoptions "$@")
ACTION=$(getlastargument $options)
while getopts "zp:${COMMON_OPTIONS_ARGS}" OPTION $options; do
    OPTARG="${OPTARG#=}"
    case $OPTION in
        d|f|h|i|l|q|v|V|x) rien=rien;;
        z) title; list_actions; exit 0;;
        p) _PROJECT=$OPTARG;;
        -) LONGOPTARG="`getlongoptionarg \"${OPTARG}\"`"
            case $OPTARG in
                actions) title; list_actions; exit 0;;
                project*) _PROJECT=$LONGOPTARG;;
                \?) ;;
            esac ;;
        \?) ;;
    esac
done

#### process ##########################
if [ ! -z "$ACTION" ]
then
    ACTIONFILE="${_BASEDIR}/${ACTION}.sh"
    if [ -f "$ACTIONFILE" ]
    then
        export _BASEDIR _BACKUP_DIR _PROJECT _TARGET
        source "$ACTIONFILE"
    else
        error "Unknown action '${ACTION}' (use option '-z' to list available action scripts) !"
    fi
else
    usage
fi

exit 0
# Endfile
