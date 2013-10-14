#!/bin/bash
# 
# action for ../deploy.sh
#

ACTION_DESCRIPTION="This will clean all OS or IDE specific files from the project (config var: 'CLEANUP_FILES')";
if $SCRIPTMAN; then return; fi

targetdir_required

if [ -z $CLEANUP_FILES ]; then
    error "Configuration var 'CLEANUP_FILES' not found !"
fi

verecho "> cleaning files in '$_TARGET' ..."
for FNAME in "${CLEANUP_FILES[@]}"; do
    if $VERBOSE; then
        iexec "find $_TARGET -type f -name $FNAME -exec rm -v {} \;"
    else
        iexec "find $_TARGET -type f -name $FNAME -exec rm {} \;"
    fi
done
verecho "_ ok"

# Endfile
