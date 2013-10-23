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

ACTION_DESCRIPTION="This will create a new GIT version TAG according to the semantic versioning (see <http://semver.org/>).";
ACTION_OPTIONS="<bold>--name=VERSION</bold>\tthe name of the new tag ; default will be next increased version number \n\
\t<bold>--branch=NAME</bold>\twhich branch to use (default is 'master' - config var: 'DEFAULT_VERSIONTAG_BRANCH')\n\
\t<bold>--hook=PATH</bold>\tdefine a pre-tag hook file (config var: 'DEFAULT_VERSIONTAG_HOOK' - see 'pre-tag-hook.sample')\n\
\t<bold>--no-hook</bold>\tdo not run any pre-tag hook file (disable config setting)";
ACTION_SYNOPSIS="[--name=version]  [--branch=name]  [--hook=path]  [--no-hook]"
ACTION_CFGVARS=( DEFAULT_VERSIONTAG_BRANCH DEFAULT_VERSIONTAG_HOOK )
if $SCRIPTMAN; then return; fi

TAG_NAME=""
BRANCH_NAME=""
HOOK_PATH=""

if ! $(isgitclone $_TARGET); then
    error "Project directory '$_TARGET' is not a git clone !"
fi

if [ -z $DEFAULT_VERSIONTAG_BRANCH ]; then
    error "Configuration var 'DEFAULT_VERSIONTAG_BRANCH' not found !"
fi
BRANCH_NAME=$DEFAULT_VERSIONTAG_BRANCH

if [ ! -z $DEFAULT_VERSIONTAG_HOOK ]; then
    HOOK_PATH="$DEFAULT_VERSIONTAG_HOOK"
fi

OPTIND=1
while getopts "${ALLOWED_OPTIONS}" OPTION "${SCRIPT_OPTS[@]}"; do
    OPTARG="${OPTARG#=}"
    case $OPTION in
        -) LONGOPTARG="`getlongoptionarg \"${OPTARG}\"`"
            case $OPTARG in
                project*|help|man|usage|vers*|interactive|verbose|force|debug|dry-run|quiet|libhelp|libvers|libdoc) ;;
                name*) TAG_NAME=$LONGOPTARG;;
                branch*) BRANCH_NAME=$LONGOPTARG;;
                hook*) HOOK_PATH=$LONGOPTARG;;
                no-hook) declare -rx HOOK_PATH="";;
                *) simple_error "Unkown option '${OPTARG#=*}'";;
            esac ;;
        \?) ;;
    esac
done

_TARGET=$(realpath "$_TARGET")

if [ -z "$TAG_NAME" ]; then
    gittags=( $(cd $_TARGET && git tag | sort -n) )
    if [ ! -z "$gittags" ]; then
        lasttag="${gittags[${#gittags[@]} - 1]}"
        # see: http://stackoverflow.com/a/8653732/2512020
        #TAG_NAME=$(echo "$lasttag" | awk -F. -v OFS=. 'NF==1{print ++$NF}; NF>1{if(length($NF+1)>length($NF))$(NF-1)++; $NF=sprintf("%0*d", length($NF), ($NF+1)%(10^length($NF))); print}')
        # new version to only increment last part of X.Y.Z
        TAG_NAME=$(echo "$lasttag" | awk -F. -v OFS=. 'NF==1{print ++$NF}; NF>1{if(length($NF+1)>length($NF))$(NF-1)++; $NF=sprintf("%0*d", length($NF), ($NF+1)%(10^length($NF))); print}')
    fi
else
    initial="$(echo $TAG_NAME | head -c 1)"
    if [ "$initial" != 'v' ]; then
        TAG_NAME="v${TAG_NAME}"
    fi
    already=$(cd $_TARGET && git tag | grep $TAG_NAME)
    if [ ! -z $already ]; then
        simple_error "A tag named '$TAG_NAME' already exists !"
    fi
fi

if [ -z "$TAG_NAME" ]; then
    error "Can't guess tag name ..."
fi

if [ ! -z "$BRANCH_NAME" ]; then
    exists=$(cd $_TARGET && git branch | grep $BRANCH_NAME)
    if [ "$exists" == '' ]; then
        error "Branch '$BRANCH_NAME' doesn't exist !"
    fi
    iexec "set -e && cd $_TARGET && git checkout $BRANCH_NAME 1>&2"
fi

if $VERBOSE; then
    verecho "> repository tags:"
    cd $_TARGET && git tag
fi

if [ ! -z $HOOK_PATH ]; then
    if [ -f "$HOOK_PATH" ]; then
        verecho "> calling pre-tag-hook '$HOOK_PATH' ..."
        iexec "source \"$HOOK_PATH\" \"$_TARGET\" \"$TAG_NAME\" \"$BRANCH_NAME\""
    else
        simple_error "pre-tag-hook script '$HOOK_PATH' not found!"
    fi
fi

verecho "> creating git tag named '$TAG_NAME' ..."
iexec "cd ${_TARGET} && git tag -a $TAG_NAME -m 'Automatic versioning tag'"
if $VERBOSE; then
    verecho "> tag $TAG_NAME created - pushing to remote ..."
else
    echo "tag $TAG_NAME created - pushing to remote ..."
fi
iexec "git push origin $TAG_NAME"
verecho "_ ok"

# Endfile
