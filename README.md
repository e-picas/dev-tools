Dev Tools
=========

This package is a set of shell scripts to help in projects development life-cycle, such as cleaning
up some un-wanted files to prepare a deployment, actually deploy the package loading some
environment specific files and helping create some GIT version TAGs.

The tools embedded in this package are based on our work about the best practices in project
development and deployment: <http://spip.ateliers-pierrot.fr/nos-activites/notre-philosophie/deployment-rules?lang=en>.

The binaries of this package are all coded in [Bash](http://en.wikipedia.org/wiki/Bash_%28Unix_shell%29).


## Presentation

The `devtools` package is one single shell script that handles a set of available actions
(also defined as shell scripts) to execute something upon a project under development. The usage is
quite simple as it just requires to understand the command line call of one single script.
The global script always follows the same rules and acts like a dispatcher that distributes the
options to an action. More, creating a new action (such as your own actions) is as simple
as writing a new shell script in the `devtools-actions/` directory and call it with the global
script.

A simple set of rules are to be followed to construct a new action with a specific help string,
some specific command line options and configuration variables.


## Installation

The following files are required for the Dev-Tools to work:

-   the original script `libexec/devtools.sh`;
-   the global configuration file `libexec/devtools.conf`;
-   the actions directory (and its contents) `libexec/devtools-actions/`;
-   the [Piwi Bash Library](https://github.com/piwi/bash-library) directory
    (and its contents) `piwi-bash-library/`.

Additionally, a UNIX-like manual is available in file `man/devtools.man`. It is not required for the
script to work but it seems a good advise to include it in your copy.

### Classic install

To download, install and use the package, you need to run something like:

    wget --no-check-certificate https://github.com/piwi/dev-tools/archive/master.tar.gz
    tar -xvf master.tar.gz
    # do not forget here to change "path/to/your/project" to fit your project ...
    cp -R dev-tools-master/libexec/devtools* path/to/your/project/bin/ \
        && cp -R dev-tools-master/piwi-bash-library path/to/your/project/bin
    chmod a+x path/to/your/project/bin/devtools.sh path/to/your/project/bin/devtools-actions/*.sh

If you already use the [Piwi Bash Library](https://github.com/piwi/bash-library)
in your project, you can avoid to duplicate it by following the configuration procedure described
in next chapter.

### Global install

If you plan to often use this package, you can install it globally in your `$HOME/bin/` directory.
You can run something like the followings, assuming you are at the package's root directory:

    cp -R devtools* ~/bin/ \
        && cp -R piwi-bash-library ~/bin/
    chmod a+x ~/bin/devtools.sh ~/bin/devtools-actions/*.sh

For facility, you can even rename `devtools.sh` to just `devtools`:

    mv devtools.sh devtools

... or symlink the original:

    ln -s devtools.sh devtools

## Usage

For a first meet, run in a terminal:

    ./devtools.sh

To see a full help info with the list of available actions, run:

    ./devtools.sh -h

To see the complete list of available actions, run:

    ./devtools.sh list-actions

To see a specific help info for an action, run:

    ./devtools.sh help action

To actually run an action, use:

    ./devtools.sh [global options] [action options] action_name

For any command line call, you can add the `--dry-run` option to debug what would be done
by the script but not run it actually:

    ./devtools.sh [global options] --dry-run [action options] action_name

A manual is available for your current version of the Dev-Tools. To read it, run:

    man ./devtools.man


## Configuration & Dependencies

The package is distributed with a configuration file named `devtools.conf` with default settings.
You can define or re-define some settings in this file to fit your environment needs.
If you use this package as a "standalone" tool to manage different projects, you can also
over-write all configuration values in a specific `.devtools` file at the root directory
of each project.

The configuration files have to be written as shell scripts:

    # comment begins with a sharp
    CONFIG_VAR=value
    OTHER_CONFIG_VAR="my value with space"

Any available configuration variable is shown in the usage string of each action.

Configuration variables are named following some simple rules:

-   a global configuration variable is named like `DEFAULT_VARIABLE`
-   an action-specific configuration variable is named like `DEFAULT_ACTIONNAME_VARIABLE`

This package is based on the [Piwi Bash Library](https://github.com/piwi/bash-library)
which is embedded by default in the `piwi-bash-library/` directory. You can over-write the library loaded
(and skip the embedded version) re-defining the `DEFAULT_BASHLIBRARY_PATH` of the
configuration file.


## Events triggering

For each action of the `devtools.sh` script, an event will be triggered BEFORE and AFTER the
action has been called. This allows user to define a special behavior for each action using the
configuration values constructed like:

    EVENT_PRE_action
    EVENT_POST_action

For instance, to print `done` after the `cleanup` action, we would write:

    EVENT_POST_cleanup="echo 'done'"


## Create a new action

To create a new action handled by `devtools.sh`, just create a new shell script in the
`devtools-actions/` directory.

The best way to begin creating your own action is to make a copy of the `dev/action-model.sh` 
script of the `wip` branch of this package and update the code ...
For more info, see <http://github.com/piwi/dev-tools/blob/wip/dev/action-model.sh>.

### Action info

The first part of an action script will mostly be the information strings about this action.
The `devtools.sh` accepts that any action defines the following variables:

-   `ACTION_NAME`: the name of the action
-   `ACTION_VERSION`: the current version number of the action
-   `ACTION_DESCRIPTION`: the description string of the action, shown when you see the global
    usage page of Dev-Tools and for the action's specific help;
-   `ACTION_OPTIONS`: an information about action's command line options and configuration
    variables;
-   `ACTION_SYNOPSIS`: a quick synopsis of action's options;
-   `ACTION_CFGVARS=()`: a table of configuration variables used by the action;
-   `ACTION_ADDITIONAL_INFO`: an additional information shown with "help action"

### Action work

The second part of an action script is its work on the project. You can here use any kind of
[Bash](http://en.wikipedia.org/wiki/Bash_%28Unix_shell%29) and UNIX commands and use the 
`devtools.sh` environment variables. As this package is based on the [Piwi Bash Library](https://github.com/piwi/bash-library),
you can also use any of its features. To know the version actually in use with your version
of Dev-Tools, run:

    ./devtools.sh --libvers

### Note for development

During development, you can call any file path as an action running:

    ./devtools.sh [global options] [action options] ./action/path/from/package/root.sh


## Sources & bugs report

The "Dev Tools" package is open source and its source code is hosted on a [GitHub.com](http://github.com)
repository at <http://github.com/piwi/dev-tools>. Feel free to make a fork of it and participate.

The last stable version is the last available release at <http://github.com/piwi/dev-tools/releases>.

To report a bug, please create a ticket at <http://github.com/piwi/dev-tools/issues>.


## Author & License

    Dev-Tools - Packages development & deployment facilities
    Copyleft (C) 2013-2014, Pierre Cassat & contributors
    <http://github.com/piwi/dev-tools>
    
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.
    
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.
    
    You should have received a copy of the GNU General Public License
    along with this program. If not, see <http://www.gnu.org/licenses/>.
