#!/usr/bin/env bash

# git command to build inter-tags log
_LOGCMD="git --no-pager \
        log --decorate --name-only --first-parent --date-order --date=short \
        --format=\"%n%ad %aN <%aE>%n%n%x09* %s%d%n%b\"";

# git command to get tag infos
#git log --tags --simplify-by-decoration --pretty="format:%ai %d"
#        show --quiet --decorate --date=short --abbrev-commit  \
#        --pretty=oneline \
_TAGCMD="git --no-pager \
        log -1 --simplify-by-decoration --date=short \
        --format=\"%n## %ad %d (%h)%n%s\"";

# get concerned paths
_CONCERNEDFILES="libexec/devtools.sh libexec/devtools.conf MANPAGE.md"

# prepare the file
_TMPFILE=CHANGELOG
if [ -f ${_TMPFILE} ]; then rm -f ${_TMPFILE}; fi
touch ${_TMPFILE}

# let's go
_MIN=''
_MAX=''
_versions=$(git for-each-ref refs/tags --sort="-*authordate" --format='%(refname)'  | sed 's/^refs\/tags\///' | sort -u)
for _vers in ${_versions}; do
    gitarg=''
    if [ ! -z ${_MAX} ]; then _MIN=${_MAX}; fi
    _MAX=${_vers}
    if [ ! -z ${_MIN} ]
        then gitarg+="${_MIN}..${_MAX}"
        else gitarg+="..${_MAX}"
    fi

    echo "> building changelog on range ${_MIN}..${_MAX} "

    # log
    if [ ! -z "${_CONCERNEDFILES}" ]
        then toexec="${_LOGCMD} ${gitarg} -- ${_CONCERNEDFILES}"
        else toexec="${_LOGCMD} ${gitarg}"
    fi
    eval ${toexec} \
        | cat - ${_TMPFILE} > ${_TMPFILE}.tmp \
            && mv ${_TMPFILE}.tmp ${_TMPFILE};

    # tag name
    eval ${_TAGCMD} ${_vers} \
        | cat - ${_TMPFILE} > ${_TMPFILE}.tmp \
            && mv ${_TMPFILE}.tmp ${_TMPFILE};

done
echo "> OK: changelog file is '${_TMPFILE}'"

cat ${_TMPFILE}

