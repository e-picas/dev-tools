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

ACTION_DESCRIPTION="This will clean all OS or IDE specific files from the project (config var: 'DEFAULT_CLEANUP_NAMES').";
ACTION_OPTIONS="Current settings are <bold>${DEFAULT_CLEANUP_NAMES[@]}</bold>";
ACTION_CFGVARS=( DEFAULT_CLEANUP_NAMES )
if $SCRIPTMAN; then return; fi

targetdir_required

if [ -z $DEFAULT_CLEANUP_NAMES ]; then
    error "Configuration var 'DEFAULT_CLEANUP_NAMES' not found !"
fi

_TARGET=$(realpath "$_TARGET")

verecho "> cleaning files in '$_TARGET' ..."
for FNAME in "${DEFAULT_CLEANUP_NAMES[@]}"; do
    if $VERBOSE; then
        iexec "find $_TARGET -type f -name $FNAME -exec rm -v {} \;"
    else
        iexec "find $_TARGET -type f -name $FNAME -exec rm {} \;"
    fi
done
verecho "_ ok"

# Endfile
