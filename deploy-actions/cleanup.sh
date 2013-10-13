#!/bin/bash
# 
# action for ../deploy.sh
#

ACTION_DESCRIPTION="This will clean all OS or IDE specific files from the project";
if $SCRIPTMAN; then return; fi

targetdir_required
unwanted_files=(
.DS_Store
.AppleDouble
.LSOverride
.Spotlight-V100
.Trashes
Icon
._*
*~
*~lock*
Thumbs.db
ehthumbs.db
Desktop.ini
.project
.buildpath
)

verecho "> cleaning files in '$_TARGET' ..."
for FNAME in "${unwanted_files[@]}"; do
    if $VERBOSE; then
        iexec "find $_TARGET -type f -name $FNAME -exec rm -v {} \;"
    else
        iexec "find $_TARGET -type f -name $FNAME -exec rm {} \;"
    fi
done
verecho "_ ok"

# Endfile
