#!/bin/sh
#
# An example hook script called before version tag creation.
# This will receive three arguments:
# - $1: the project path to work on
# - $2: the tag name to create 
# - $3: the branch name 
#
# To enable this hook, define the `DEFAULT_VERSIONTAG_HOOK` configuration variable on
# this script.

PROJECT_PATH="$1"
TAG_NAME="$2"
BRANCH_NAME="$3"

_VERSION="${TAG_NAME/v/}"
_DATE=$(git log -1 --format="%ci" --date=short | cut -s -f 1 -d ' ')
_BINFILE="devtools.sh"
_MANFILE="MANPAGE.md"
_MANMANFILE="devtools.man"
_MDEBIN="vendor/bin/markdown-extended"

if [ ! -f "${_MDEBIN}" ]; then
    echo "The binary '$_MDEBIN' can't be found ; the manpage will not be updated for this tag."
    echo "If you want to install the markdown tool, run 'composer update --dev' ..."
    prompt 'Do you want to continue' 'Y/n' 'y'
    if [ "${USERRESPONSE}" != 'y' ]; then exit 0; fi
fi

if [ -f "${_BINFILE}" ]; then
    debecho "> inserting version and date in ${_LIBFILE}"
    if `in_array ${USEROS} ${LINUX_OS[@]}`
        then sed -i -e "s|^declare -rx VERSION=\".*\"$|declare -rx VERSION=\"${_VERSION}\"|" "${_BINFILE}";
        else sed -i '' -e "s|^declare -rx VERSION=\".*\"$|declare -rx VERSION=\"${_VERSION}\"|" "${_BINFILE}";
    fi
    debecho "> adding ${_LIBFILE}"
    git add "${_BINFILE}"
else
    verecho "!! > Binary file '${_BINFILE}' not found! (can't update version number and date)"
fi

if [ -f "${_MANFILE}" ]; then
    debecho "> inserting version and date in ${_MANFILE}"
    if `in_array ${USEROS} ${LINUX_OS[@]}`
        then sed -i -e "s|^Version: .*$|Version: ${_VERSION}|;s|^Date: .*$|Date: ${_DATE}|" "${_MANFILE}";
        else sed -i '' -e "s|^Version: .*$|Version: ${_VERSION}|;s|^Date: .*$|Date: ${_DATE}|" "${_MANFILE}";
    fi
    debecho "> adding ${_MANFILE}"
    git add "${_MANFILE}"
    if [ -f "${_MDEBIN}" ]; then
        debecho "> generating ${_MANMANFILE} from ${_MANFILE}"
        if `in_array ${USEROS} ${LINUX_OS[@]}`
            then ${_MDEBIN} -f man -o "${_MANMANFILE}" "${_MANFILE}"
            else php ${_MDEBIN} -f man -o "${_MANMANFILE}" "${_MANFILE}"
        fi
        debecho "> adding ${_MANMANFILE}"
        git add "${_MANMANFILE}"
    else
        verecho "!! > Binary '${_MDEBIN}' not found! (can't re-generate '${_MANMANFILE}' - try to run 'composer' with '--dev' option)"
    fi
else
    verecho "!! > Manual file '${_MANFILE}' not found! (can't update version number and date)"
fi

git commit -m "Automatic version number and date insertion" && \
    LASTSHA=`git log -1 --format="%H"` && \
    git checkout wip && git cherry-pick ${LASTSHA} && \
    git checkout master && git push origin master wip;

# Endfile