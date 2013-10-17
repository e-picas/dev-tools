#!/bin/sh

#git --no-pager log --format="%ai %aN %n%n%x09* %s%d%n"
echo 'ok' && exit 0


CHANGELOG=`ls | egrep 'change|history' -i`
if test "$CHANGELOG" = ""; then CHANGELOG='History.md'; fi
DATE=`date +'%Y-%m-%d'`
HEAD="\nn.n.n / $DATE \n==================\n"

if test "$1" = "--list"; then
	version=`git for-each-ref refs/tags --sort="-*authordate" --format='%(refname)' \
    --count=1 | sed 's/^refs\/tags\///'`
  if test -z "$version"; then
		git log --pretty="format: * %s"
  else
		git log --pretty="format: * %s" $version..
  fi
else
	tmp="/tmp/changelog"
    echo $HEAD > $tmp
    ./changelog.sh --list >> $tmp
    echo '' >> $tmp
    if test -f "$CHANGELOG"; then cat $CHANGELOG >> $tmp; fi
    mv "$tmp" "$CHANGELOG"
    test -n "$EDITOR" && $EDITOR $CHANGELOG
fi
echo 'ok' && exit 0

if test -d ".git"; then
    git log --date-order --date=short | \
    sed -e '/^commit.*$/d' | \
    awk '/^Author/ {sub(/\\$/,""); getline t; print $0 t; next}; 1' | \
    sed -e 's/^Author: //g' | \
    sed -e 's/>Date:   \([0-9]*-[0-9]*-[0-9]*\)/>\t\1/g' | \
    sed -e 's/^\(.*\) \(\)\t\(.*\)/\3    \1    \2/g' > ChangeLog
    exit 0
else
    echo "No git repository present."
    exit 1
fi
echo 'ok' && exit 0
