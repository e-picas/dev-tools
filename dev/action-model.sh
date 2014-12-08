#!/usr/bin/env bash
#
# this script is a model to build a custom new action script for Dev-Tools
# see <http://github.com/piwi/dev-tools>
#

# information definitions
ACTION_NAME="The action name"
ACTION_VERSION="0.0.0"
ACTION_DESCRIPTION="A short presentation of the action ...";
ACTION_ALLOWED_OPTIONS=""
ACTION_ALLOWED_LONG_OPTIONS="option1:"
ACTION_OPTIONS="a long string to inform user about the action's options and configuration variables";
ACTION_SYNOPSIS="the list of options for a quick look"
ACTION_CFGVARS=( ACTION_CONFIG_VARS )

# this line is required for manual and list of actions
if [ "$SCRIPTMAN" = 'true' ]; then return; fi

## demo of a usage of the ACTION_CONFIG_VARS configuration variable
if [ ! -z "$DEFAULT_CONFIG_VARS" ]; then
    ACTION_CONFIG_VARS="$DEFAULT_CONFIG_VARS"
else
    DEFAULT_CONFIG_VARS="default"
    ACTION_CONFIG_VARS="$DEFAULT_CONFIG_VARS"
fi

# treatment of scripts' options
OPTIND=1
while getopts ":${OPTIONS_ALLOWED}" OPTION; do
    OPTARG="${OPTARG#=}"
    case "$OPTION" in
        -) LONGOPTARG="$(get_long_option_arg "$OPTARG")"
            case "$OPTARG" in
                # you need to keep this line as these are the default global options
                path*|help|man|usage|vers*|interactive|verbose|force|debug|dry-run|quiet|libvers) ;;
                # the action options
                option1*) VAR="$LONGOPTARG";;
                # error in case of unknown option (optional)
                *) simple_error "Unkown option '${OPTARG#=*}'";;
            esac ;;
        \?) ;;
    esac
done

# the action's logic comes here ...



# nothing is required at the end of an action script (no return or exit)
# Endfile
