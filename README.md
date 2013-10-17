Dev Tools
=========

This package is a set of shell scripts to help in package development life-cycle, such as cleaning
up some un-wanted files to prepare a deployment, actually deploy the package loading some
environment specific files and helping create some GIT version TAGs.

The tools embedded in this package are based on our work about the best practices in project
development and deployment: <http://github.com/atelierspierrot/atelierspierrot/blob/master/Package-Deployment.md>.


## Presentation

The `dev-tools` package is one single shell script that handles a set of available actions
(defined themselves as shell scripts) to execute something upon a package in development. The usage is
quite simple as it just requires to understand the command line call of one single script.
The global script always follows the same rules and acts like a dispatcher that distributes the
options to an action. More, creating a new action (such as your own actions) is as simple
as writing a new shell script in the `dev-tools-actions/` directory and call it with the global
script.

A simple set of rules are to be followed to construct a new action with a specific help string,
some specific command line options and configuration variables.


## Installation

The following files are required for the DevTools to work:

-   the original script `dev-tools.sh`;
-   the actions directory (and its contents) `dev-tools-actions/`;
-   the [Bash Library](https://github.com/atelierspierrot/bash-library) directory
    (and its contents) `bash-library/`.

### Classic install

To install and use the package, you need to run something like:

    ~$ wget --no-check-certificate https://github.com/atelierspierrot/dev-tools/archive/master.tar.gz
    ~$ tar -xvf master.tar.gz
    ~$ cp dev-tools-master/dev-tools.sh path/to/your/project/bin/ \
        && cp -R dev-tools-master/dev-tools-actions path/to/your/project/bin \
        && cp -R dev-tools-master/bash-library path/to/your/project/bin \
        && cp dev-tools-master/dev-tools.conf path/to/your/project/
    // do not forget here to change "path/to/your/project" to fit your project ...
    ~$ chmod a+x path/to/your/project/bin/dev-tools.sh

If you already use the [Bash Library](https://github.com/atelierspierrot/bash-library) in your
project, you can avoid duplicate following the configuration procedure described in next chapter.

### Global install

If you plan to often use this package, you can install it globally in your `$HOME/bin/` directory.
You can run something like the followings, assuming you are at the package root directory:

    ~$ cp dev-tools.sh ~/bin/ \
        && cp -R dev-tools-actions ~/bin/ \
        && cp -R bash-library ~/bin/ \
        && cp dev-tools.conf ~/bin/
    ~$ chmod a+x ~/bin/dev-tools.sh

For facility, you can event rename `dev-tools.sh` to just `dev-tools`:

    ~$ mv dev-tools.sh dev-tools

### Using Composer

If you are a [Composer](http://getcomposer.org) user, you can simply add the package to your
requirements and ensure to define a `bin` directory:

    "require": {
        ...
        "atelierspierrot/dev-tools": "dev-master"
    },
    "config": {
        ...
        "bin-dir": "bin"
    },


## Usage

In a terminal, run:

    sh ./dev-tools.sh

To see a full help info with the list of available actions, run:

    sh ./dev-tools.sh -h

To see a specific help info for an action, run:

    sh ./dev-tools.sh -h action

To run an action, run:

    sh ./dev-tools.sh [global options] [action options] action_name


## Configuration & Dependencies

The package is distributed with a configuration file named `dev-tools.conf` with default settings.
You can define or re-define some settings in this file to fit your environment needs globally.
You can also over-write all configuration values in a specific `.devtools` file at the root
directory of each project. The configuration files used are INI like:

    # comment begins with a sharp
    CONFIG_VAR=my value

Any available configuration variable is shown in the usage string.

Configuration variables are named following some simple rules:

-   a global configuration variable is named like `DEFAULT_VARIABLE`
-   an action specific configuration variable is named like `DEFAULT_ACTION-NAME_VARIABLE`

This package is based on the [Bash Library](https://github.com/atelierspierrot/bash-library)
which is embedded by default in `bin/`. You can over-write the library loaded (and skip the
embedded version) re-defining the `DEFAULT_BASHLIBRARY_PATH` of the configuration file.


## Events

For each action of the `dev-tools.sh` script, an event will be triggered BEFORE and AFTER the
action is called. This allows user to define a special behavior for each action using the
configuration values constructed like:

    EVENT_PRE_action
    EVENT_POST_action

For instance, to echo `done` after the `cleanup` action, use:

    EVENT_POST_cleanup="echo 'done'"


## Author & License

>    Dev Tools

>    https://github.com/php-carteblanche/dev-tools

>    Copyleft 2013, Pierre Cassat and contributors

>    Licensed under the GPL Version 3 license.

>    http://opensource.org/licenses/GPL-3.0

>    ----

>    Les Ateliers Pierrot - Paris, France

>    <www.ateliers-pierrot.fr> - <contact@ateliers-pierrot.fr>
