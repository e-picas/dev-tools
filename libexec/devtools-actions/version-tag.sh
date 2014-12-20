#!/usr/bin/env bash
# 
# Dev-Tools - Packages development & deployment facilities
# Copyleft (C) 2013-2014 Pierre Cassat & contributors
# <http://github.com/piwi/dev-tools>
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

ACTION_NAME="Version TAG"
ACTION_VERSION="1.0.0-alpha"
ACTION_DESCRIPTION="This will create a new GIT version TAG according to the semantic versioning (see <http://semver.org/>).";
ACTION_ALLOWED_OPTIONS=""
ACTION_ALLOWED_LONG_OPTIONS="name:,branch:,hook:,no-hook"
ACTION_OPTIONS="--name\t\t=VERSION\tthe name of the new tag ; default will be next increased version number \n\
\t--branch\t=NAME\t\twhich branch to use (default is 'master' - config var: 'DEFAULT_VERSIONTAG_BRANCH')\n\
\t--hook\t\t=PATH\t\tdefine a pre-tag hook file (config var: 'DEFAULT_VERSIONTAG_HOOK' - see 'pre-tag-hook.sample')\n\
\t--no-hook\t\t\tdo not run any pre-tag hook file (disable config setting)";
ACTION_SYNOPSIS="[--name=version]  [--branch=name]  [--hook=path]  [--no-hook]"
ACTION_CFGVARS=( DEFAULT_VERSIONTAG_BRANCH DEFAULT_VERSIONTAG_HOOK )
if [ "$SCRIPTMAN" = 'true' ]; then return; fi

TAG_NAME=""
BRANCH_NAME=""
HOOK_PATH=""

if ! $(git_is_clone "$_TARGET"); then
    error "Project directory '${_TARGET}' is not a git clone !"
fi

if [ -z "${DEFAULT_VERSIONTAG_BRANCH}" ]; then
    error "Configuration var 'DEFAULT_VERSIONTAG_BRANCH' not found !"
fi
BRANCH_NAME="${DEFAULT_VERSIONTAG_BRANCH}"

if [ ! -z "${DEFAULT_VERSIONTAG_HOOK}" ]; then
    HOOK_PATH="${DEFAULT_VERSIONTAG_HOOK}"
fi

OPTIND=1
while getopts ":${OPTIONS_ALLOWED}" OPTION; do
    OPTARG="${OPTARG#=}"
    case "${OPTION}" in
        -)  parse_long_option "$OPTARG" "${!OPTIND}"
            case "${OPTARG}" in
                path*|help|man|usage|vers*|interactive|verbose|force|debug|dry-run|quiet|libvers) ;;
                name*) TAG_NAME="$LONGOPTARG";;
                branch*) BRANCH_NAME="$LONGOPTARG";;
                hook*) HOOK_PATH="$LONGOPTARG";;
                no-hook) declare -rx HOOK_PATH="";;
                *) ;;
            esac ;;
        \?) ;;
    esac
done

_TARGET=$(realpath "${_TARGET}")
if [ ! -z "${HOOK_PATH}" ]; then
    HOOK_PATH=$(realpath "${_TARGET}/${HOOK_PATH}")
fi

if [ -z "${TAG_NAME}" ]; then
    gittags=( $(cd ${_TARGET} && git tag | sort -n) )
    if [ ! -z "$gittags" ]; then
        lasttag="${gittags[${#gittags[@]} - 1]}"
        # see: http://stackoverflow.com/a/8653732/2512020
        #TAG_NAME=$(echo "$lasttag" | awk -F. -v OFS=. 'NF==1{print ++$NF}; NF>1{if(length($NF+1)>length($NF))$(NF-1)++; $NF=sprintf("%0*d", length($NF), ($NF+1)%(10^length($NF))); print}')
        # new version to only increment last part of X.Y.Z
        TAG_NAME=$(echo "${lasttag}" | awk -F. -v OFS=. 'NF==1{print ++$NF}; NF>1{if(length($NF+1)>length($NF))$(NF-1)++; $NF=sprintf("%0*d", length($NF), ($NF+1)%(10^length($NF))); print}')
    fi
else
    if [ "${TAG_NAME:0:1}" != 'v' ]; then
        TAG_NAME="v${TAG_NAME}"
    fi
    already=$(cd ${_TARGET} && git tag | grep ${TAG_NAME})
    if [ ! -z "${already}" -a "${already}" == "${TAG_NAME}" ]; then
        simple_error "A tag named '${TAG_NAME}' already exists !"
    fi
fi

if [ -z "${TAG_NAME}" ]; then
    error "Can't guess tag name ..."
else
    debecho "> will create tag '${TAG_NAME}' ..."
fi

if [ ! -z "${BRANCH_NAME}" ]; then
    exists=$(cd ${_TARGET} && git branch | grep ${BRANCH_NAME})
    if [ "${exists}" == '' ]; then
        error "Branch '${BRANCH_NAME}' doesn't exist !"
    fi
    iexec "cd ${_TARGET} && git checkout ${BRANCH_NAME} 1>&2"
fi

if [ "$VERBOSE" = 'true' ]; then
    verecho "> repository tags:"
    cd "${_TARGET}" && git tag
fi

if [ ! -z "${HOOK_PATH}" ]; then
    if [ -f "${HOOK_PATH}" ]; then
        verecho "> calling pre-tag-hook '${HOOK_PATH}' ..."
        iexec "source \"${HOOK_PATH}\" \"${_TARGET}\" \"${TAG_NAME}\" \"${BRANCH_NAME}\""
    else
        simple_error "pre-tag-hook script '${HOOK_PATH}' not found!"
    fi
fi

verecho "> creating git tag named '${TAG_NAME}' ..."
iexec "cd ${_TARGET} && git checkout ${BRANCH_NAME} && git tag -a ${TAG_NAME} -m 'Automatic versioning tag'"
if [ "$VERBOSE" = 'true' ]; then
    verecho "> tag ${TAG_NAME} created - pushing to remote ..."
else
    echo "tag ${TAG_NAME} created - pushing to remote ..."
fi
iexec "git push origin ${TAG_NAME}"
verecho "_ ok"

# Endfile
