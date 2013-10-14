#!/bin/bash
# 
# action for ../deploy.sh
#

ACTION_DESCRIPTION="This will create a new GIT version TAG ; you can define: \n\
\t\t<bold>--name=VERSION</bold>\tthe name of the new tag ; default will be next increased version number \n\
\t\t<bold>--branch=NAME</bold>\twether to use an existing branch or not";
ACTION_SYNOPSIS="[--name=version] [--branch]"
if $SCRIPTMAN; then return; fi

targetdir_required
TAG_NAME=""
USE_BRANCH=""

if ! $(isgitclone $_TARGET); then
    error "Project directory '$_TARGET' is not a git clone !"
fi

OPTIND=1
options=$(getscriptoptions "$@")
while getopts "${COMMON_OPTIONS_ARGS}" OPTION $options; do
    OPTARG="${OPTARG#=}"
    case $OPTION in
        -) LONGOPTARG="`getlongoptionarg \"${OPTARG}\"`"
            case $OPTARG in
                name*) TAG_NAME=$LONGOPTARG;;
                branch*) USE_BRANCH=$LONGOPTARG;;
                \?) ;;
            esac ;;
        \?) ;;
    esac
done

if [ -z "$TAG_NAME" ]; then
    gittags=( $(cd $_TARGET && git tag | sort -n) )
    lasttag="${gittags[${#gittags[@]} - 1]}"
    # see: http://stackoverflow.com/a/8653732/2512020
    TAG_NAME=$(echo "$lasttag" | awk -F. -v OFS=. 'NF==1{print ++$NF}; NF>1{if(length($NF+1)>length($NF))$(NF-1)++; $NF=sprintf("%0*d", length($NF), ($NF+1)%(10^length($NF))); print}')
else
    initial="$(echo $TAG_NAME | head -c 1)"
    if [ "$initial" != 'v' ]; then
        TAG_NAME="v${TAG_NAME}"
    fi
    already=$(cd $_TARGET && git tag | grep $TAG_NAME)
    if [ ! -z $already ]; then
        error "A tag named '$TAG_NAME' already exists !"
    fi
fi

if [ -z "$TAG_NAME" ]; then
    error "Can't guess tag name ..."
fi

if [ ! -z "$USE_BRANCH" ]; then
    exists=$(cd $_TARGET && git branch | grep $USE_BRANCH)
    if [ "$exists" == '' ]; then
        error "Branch '$USE_BRANCH' doesn't exist !"
    fi
    iexec "cd $_TARGET && git checkout $USE_BRANCH"
fi

if $VERBOSE; then
    verecho "> repository tags:"
    cd $_TARGET && git tag
fi

verecho "> creating git tag named '$TAG_NAME' ..."
iexec "cd ${_TARGET} && git tag -a $TAG_NAME -m 'Automatic versioning tag' && git push origin $TAG_NAME"
verecho "_ ok"

# Endfile
