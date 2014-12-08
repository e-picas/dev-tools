#!/usr/bin/env bash

# the default installation directory
_INSTALLDIR=/usr/local
[ -d /opt/local ] && _INSTALLDIR=/opt/local;

# the default user name & group
_USERNAME=$(whoami)
_USERGROUP=$(id -g -n $_USERNAME)

# get_temp_dir ()
get_temp_dir () {
    [ -z "$_TMPDIR" ] && export _TMPDIR=$(mktemp -d);
    echo "$_TMPDIR"
}

# debug ()
debug () {
    echo "## debug:"
    echo "InstallDir:   $_INSTALLDIR"
    echo "UserName:     $_USERNAME"
    echo "UserGroup:    $_USERGROUP"
    echo "## install paths:"
    echo "binaries:     $_INSTALLDIR/bin/"
    echo "configs:      $_INSTALLDIR/etc/"
    echo "libraries:    $_INSTALLDIR/lib/"
    echo "manuals:      $_INSTALLDIR/man/man(X)/"
}

# error ( string , status=1 )
error () {
    echo "error: $1"
    echo "use options '--help' or '-h' for usage information"
    exit "${2:-1}"
}

# usage ()
usage () {
    echo "usage: $0  [install_base_path = $_INSTALLDIR]"
    exit 0
}

# safe_path ( path )
safe_path () {
    local _path=$1
    [ "$_path" == '.' ] && _path=$(pwd)
    _path="${_path/\~/${HOME}}"
    echo "$_path"
}

# help message
if [ "$1" == '-h' ]||[ "$1" == '--help' ]||[ "$1" == 'help' ]; then
    usage
fi

# the cli argument
[ $# -ne 0 ] && _INSTALLDIR="$1" && shift;

# transforming path
_INSTALLDIR=$(safe_path "$_INSTALLDIR")

# verification of the installation directory
if [ ! -d $_INSTALLDIR ]; then
    error "the target directory '$_INSTALLDIR' does not exist!"
fi

# special debug with '-x'
if [ "$1" == '-x' ]; then
    debug
    exit 0
fi

# temporary directory
cd $_TMPDIR

# info
echo "Installing 'dev-tools' and dependencies in base path '$_INSTALLDIR'"

## the `piwi-bash-library`
if ! $(which piwi-bash-library); then
    echo ">> installation of the 'piwi-bash-library' dependency ..."

    # download last master version archive
    echo "> downloading lastest master version archive ..."
    wget -q --no-check-certificate https://github.com/piwi/piwi-bash-library/archive/master.tar.gz 1>&/dev/null
    # extract it
    echo "> extracting the archive ..."
    tar -xf master

    # install the `piwi-bash-library.sh` script
    echo "> installing the 'piwi-bash-library.sh' script in '$_INSTALLDIR/bin' ..."
    install -CD -o $_USERNAME -g $_USERGROUP -m 0655 piwi-bash-library-*/src/piwi-bash-library.sh $_INSTALLDIR/bin/piwi-bash-library.sh
    # symlink it to simple `piwi-bash-library`
    [ ! -f $_INSTALLDIR/bin/piwi-bash-library ] &&
        ( cd $_INSTALLDIR/bin/ && ln -s piwi-bash-library.sh piwi-bash-library );

    # copy the piwi-bash-library manpage in manpages section 3
    echo "> installing the piwi-bash-library manpage to section 3 ..."
    install -CD -o $_USERNAME -g $_USERGROUP -m 0644 piwi-bash-library-*/src/piwi-bash-library.man $_INSTALLDIR/man/man3/piwi-bash-library.sh.3
    # gzip it
    [ -f $_INSTALLDIR/man/man3/piwi-bash-library.sh.3.gz ] && rm -f $_INSTALLDIR/man/man3/piwi-bash-library.sh.3.gz;
    gzip $_INSTALLDIR/man/man3/piwi-bash-library.sh.3
    # symlink it to simple `devtools`
    [ -f $_INSTALLDIR/man/man3/piwi-bash-library.3.gz ] && rm -f $_INSTALLDIR/man/man3/piwi-bash-library.3.gz;
    ( cd $_INSTALLDIR/man/man3/ && ln -s piwi-bash-library.sh.3.gz piwi-bash-library.3.gz );

    echo "_ ok"
else
    echo "> 'piwi-bash-library' dependency found at '$(which piwi-bash-library)' ..."
fi

## the `dev-tools`
echo ">> installation of the 'dev-tools' ..."

# download last master version archive
echo "> downloading lastest master version archive ..."
wget -q --no-check-certificate https://github.com/piwi/dev-tools/archive/master.tar.gz 1>&/dev/null
# extract it
echo "> extracting the archive ..."
tar -xf master

# install the `devtools.sh` script
echo "> installing the 'devtools.sh' command in '$_INSTALLDIR/bin' ..."
install -CD -o $_USERNAME -g $_USERGROUP -m 0655 dev-tools-*/devtools.sh $_INSTALLDIR/bin/devtools.sh
# symlink it to simple `devtools`
[ ! -f $_INSTALLDIR/bin/devtools ] &&
    ( cd $_INSTALLDIR/bin/ && ln -s devtools.sh devtools );

# install each action in "devtools-actions/" as "devtools-action.sh"
echo "> installing the 'devtools-actions' in '$_INSTALLDIR/bin' ..."
for f in $(ls dev-tools-*/devtools-actions/*.sh); do
    echo "> linking action '$f' ..."
    install -CD -o $_USERNAME -g $_USERGROUP -m 0655 $f $_INSTALLDIR/bin/devtools-$(basename $f)
done

# install the `devtools.conf` configuration file
echo "> installing the 'devtools.conf' configuration file in '$_INSTALLDIR/etc' ..."
install -CD -o $_USERNAME -g $_USERGROUP -m 0644 dev-tools-*/devtools.conf $_INSTALLDIR/etc/devtools.conf

# copy the devtools manpage in manpages section 3
echo "> installing the piwi-bash-library manpage to section 3 ..."
install -CD -o $_USERNAME -g $_USERGROUP -m 0644 dev-tools-*/devtools.man $_INSTALLDIR/man/man3/devtools.sh.3
# gzip it
[ -f $_INSTALLDIR/man/man3/devtools.sh.3.gz ] && rm -f $_INSTALLDIR/man/man3/devtools.sh.3.gz;
gzip $_INSTALLDIR/man/man3/devtools.sh.3
# symlink it to simple `devtools`
[ -f $_INSTALLDIR/man/man3/devtools.3.gz ] && rm -f $_INSTALLDIR/man/man3/devtools.3.gz;
( cd $_INSTALLDIR/man/man3/ && ln -s devtools.sh.3.gz devtools.3.gz );

# update the manpages DB
echo "> updating manual pages DB ..."
if [ `which makewhatis` ]; then
    makewathis 1>&/dev/null
elif [ `which mandb` ]; then
    mandb 1>&/dev/null
fi

# cleanup
rm -rf $_TMPDIR

# done
echo "_ ok : the 'dev-tools' are now installed in '$_INSTALLDIR'"

# Endfile
