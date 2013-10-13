Dev Tools
=========

This package is a set of shell scripts to help managing a package life-cycle, such as cleaning
up some un-wanted files to prepare a deployment, actually deploy the package loading some
environment specific files and helping create some GIT version TAGs.

## Usage

In a terminal, run:

    sh ./deploy.sh

To list available actions, run:

    sh ./deploy.sh -z

To run an action, run:

    sh ./deploy.sh [options] action_name


## Configuration & Dependencies

The package is distributed with a configuration file named `deploy.conf` with default settings.
You can define or re-define some settings in this file to fit your environment needs.

This package is based on the [Bash Library](https://github.com/atelierspierrot/bash-library)
which is embedded by default in `bin/`. You can over-write the library loaded (and skip the
embedded version) re-defining the `BASHLIBRARY_PATH` of the configuration file.


## Events

For each action of the `deploy.sh` script, an event will be triggered BEFORE and AFTER the
action is called. This allows user to define a special behavior for each action using the
configuration values constructed like:

    EVENT_PRE_action
    EVENT_POST_action

For instance, to echo `done` after the `cleanup` action, use:

    EVENT_POST_cleanup="echo 'done'"
