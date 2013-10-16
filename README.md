Dev Tools
=========

This package is a set of shell scripts to help managing a package life-cycle, such as cleaning
up some un-wanted files to prepare a deployment, actually deploy the package loading some
environment specific files and helping create some GIT version TAGs.

The tools embedded in this package are based on our work about the best practices in project
deployment: <http://github.com/atelierspierrot/atelierspierrot/blob/master/Package-Deployment.md>.


## Installation

To install and use the package, you need to run something like:

    ~$ wget --no-check-certificate https://github.com/atelierspierrot/dev-tools/archive/master.tar.gz
    ~$ tar -xvf master.tar.gz
    ~$ cp dev-tools-master/deploy.sh path/to/your/project/bin/ \
        && cp -R dev-tools-master/deploy-actions path/to/your/project/bin \
        && cp -R dev-tools-master/bash-library path/to/your/project/bin \
        && cp dev-tools-master/deploy.conf path/to/your/project/
    ~$ chmod +x path/to/your/project/bin/deploy.sh

If you already use the [Bash Library](https://github.com/atelierspierrot/bash-library) in your
project, just re-define the `BASHLIBRARY_PATH` configuration setting as described below.

If you are a [Composer](http://getcomposer.org) user, you can simply add to your requirements:

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

    sh ./deploy.sh

To see a full help info with the list of available actions, run:

    sh ./deploy.sh -h

To run an action, run:

    sh ./deploy.sh [options] action_name


## Configuration & Dependencies

The package is distributed with a configuration file named `deploy.conf` with default settings.
You can define or re-define some settings in this file to fit your environment needs globally.
You can also over-write all configuration values in a specific `.devtools` file at the root
directory of each project. The configuration files used are INI like:

    # comment begins with a sharp
    CONFIG_VAR=my value

Any available configuration variable is shown in the usage string.

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


## Author & License

>    Dev Tools

>    https://github.com/php-carteblanche/dev-tools

>    Copyleft 2013, Pierre Cassat and contributors

>    Licensed under the GPL Version 3 license.

>    http://opensource.org/licenses/GPL-3.0

>    ----

>    Les Ateliers Pierrot - Paris, France

>    <www.ateliers-pierrot.fr> - <contact@ateliers-pierrot.fr>
