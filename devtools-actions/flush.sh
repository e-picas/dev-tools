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

ACTION_DESCRIPTION="This will clean contents of temporary directories (config var: 'DEFAULT_FLUSH_DIRNAMES').";
ACTION_OPTIONS="Current settings are <bold>${DEFAULT_FLUSH_DIRNAMES[@]}</bold>";
ACTION_CFGVARS=( DEFAULT_FLUSH_DIRNAMES )
if $SCRIPTMAN; then return; fi

if [ -z $DEFAULT_FLUSH_DIRNAMES ]; then
    error "Configuration var 'DEFAULT_FLUSH_DIRNAMES' not found !"
fi

_TARGET=$(realpath "$_TARGET")

verecho "> cleaning temporary files in '$_TARGET' ..."
for FNAME in "${DEFAULT_FLUSH_DIRNAMES[@]}"; do
    for DIRNAME in $(find $_TARGET -type d -name $FNAME); do
        if $VERBOSE; then
            iexec "rm -vrf ${DIRNAME}/*"
        else
            iexec "rm -rf ${DIRNAME}/*"
        fi
    done
done
verecho "_ ok"

# Endfile
