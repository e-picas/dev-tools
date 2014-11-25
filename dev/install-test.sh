#!/bin/bash

    # download last master version archive
    wget --no-check-certificate https://github.com/atelierspierrot/dev-tools/archive/master.tar.gz
    # extract it
    tar -xvf master.tar.gz
    # install piwi-bash-library
#    ???????
    # install the devtools.sh script
    sudo install -CD -o root -g root -m 0655 dev-tools-*/devtools.sh /usr/share/bin/devtools.sh
    # symlink it to simple 'devtools"
    sudo ln -s /usr/share/bin/devtools.sh /usr/share/bin/devtools
    # install each action in "devtools-actions/" as "devtools-action.sh"
    for f in dev-tools-*/devtools-actions/; do
        sudo install -CD -o root -g root -m 0655 dev-tools-*/devtools-actions/$f /usr/share/bin/devtools-$f
    done
    # copy the devtools manpage in manpages section 3
    sudo install -CD -o root -g root -m 0644 dev-tools-*/devtools.man /usr/share/man/man3/devtools.man
    # gzip it
    sudo gzip /usr/share/man/man3/devtools.man
    # update the manpages DB
    makewathis
