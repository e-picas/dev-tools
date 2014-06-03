Man:        devtools.sh Manual
Name:       Dev Tools
Author:     Les Ateliers Pierrot
Date: 2014-05-18
Version: 1.3.1


## NAME

devtools - Packages development & deployment facilities

## SYNOPSIS

**devtools.sh action [common options] [script options [=value]] --**

**devtools.sh**  [**-V**]  [**-f**|**-i**|**-q**|**-v**]  [**-x**|**--dry-run**]  [**-p** | **--path** *=path*]  ...
    ... help  <action>  [**--less**]  [**--more**]
    ... usage
    ... list-actions
    ... install  [<path> = ~/bin/]
    ... uninstall  [<path> = ~/bin/]
    ... self-check  [<path> = ~/bin/]
    ... self-update  [<path> = ~/bin/]
    -- 

**devtools.sh**  <action>  [**-h**|**--help**|**-V**]  [**-f**|**-i**|**-q**|**-v**]  [**-x**|**--dry-run**]  [**-p** | **--path** *=path*]  ...
    ... cleanup
    ... flush
    ... config  [**--var** *=name*]  [**--val** *=value*]  [**--filename**]  [**--full**] 
    ... deploy  [**--env** *=env*] 
    ... extract  [**--begin** *=mask*]  [**--end** *=mask*]  [**--output** *=filename*]  [**--filename**] 
    ... fix-rights  [**--files** *=chmod*]  [**--dirs** *=chmod*]  [**--bin** *=path*]  [**--bin-mask** *=mask*] 
    ... md2man  [**--source** *=path*]  [**--filename** *=filename*]  [**--markdown** *=bin path*]
    ... manpage  [**--source** *=path*]  [**--filename** *=filename*]  [**--type** *=type*]  [**--dir** *=dir path*]  [**--markdown** *=bin path*]  [**--whatis** *=bin path*]  [**--makewhatis** *=bin path*] 
    ... sync  [**--method** *=method*]  [**--env** *=env*]  [**--target** *=server*]  [**--options** *="rsync/ftp options"*]  [**--env-options** *="rsync options"*]  [**--no-env**] 
    ... version-tag  [**--name** *=version*]  [**--branch** *=name*]  [**--hook** *=path*]  [**--no-hook**] 
    -- 

## DESCRIPTION_MANPAGE

**DevTools** is a shell script that handles a set of actions (defined themselves as shell scripts)
to execute something upon a package in development. The usage is quite simple as it just
requires to understand the command line call of one single script. Examples and usage shown
in this manual all use `devtools.sh` to designate this global script, which is its initial filename
in a just downloaded package. If you installed the DevTools in your system (in your own `$HOME/bin/`
directory or any global `/usr/*/bin/` directory), you may replace "devtools.sh" by "devtools"
in each command line example. In this case, each action is a script installed in the same 
directory as the global script and named something like `devtools-action_name`.

The global script always follows the same rules and acts like a dispatcher that distributes
the options to an action. More, creating a new action (such as your own actions) is as simple
as writing a new shell script in the `devtools-actions/` directory (or naming it
`devtools-myaction` for a global install) and call it with the global script.

The synopsis usage of the script is something like: **devtools.sh action-name
[common options] [script options [=value]] --**. You can group short options like `-xc`,
set an option argument like `-d(=)value` or `--long=value` and use `--` to explicitly specify
the end of the script options. Any short option(s) with no argument can be used first and any
short or long option with argument too as long as you use the equal sign:

    devtools.sh action -vi -p ../my/path action

is the same as:

    devtools.sh -vi -p=../my/path action

Basically, the first string which does not begin by a dash `-` in your command will be
considered as an action name.

For a first start or a quick usage reminder, use option `-h` for a global script help,
`help action` to see the help about a specific action and use option `--dry-run` to make dry runs.

This package is based on the [Piwi Bash Library](http://github.com/atelierspierrot/piwi-bash-library).

## OPTIONS

Use special option `-V` to get script's version.

*The following common options are supported:*

**-p**, **--path** =path
:   define the project directory path (default is `pwd` - the `path` argument must exist)

**-v**, **--verbose**
:   increase script verbosity 

**-q**, **--quiet**
:   decrease script verbosity, nothing will be written unless errors 

**-f**, **--force**
:   force some commands to not prompt confirmation 

**-i**, **--interactive**
:   ask for confirmation before some actions

**-x**, **--debug**
:   see debug infos

**--dry-run**
:   see commands to run but do not run them actually 

*The following internal actions are available:*

**help / usage**
:   See the help information about the script or an action.

:        devtools.sh  help  -[common options ...]  <action>  [--less]  [--more]  --

:   The `--less` option shows the help information using the `less` program. The `--more`
    option shows the help information using the `more` program. If both options are used,
    the 'less' program will be choosed preferabily.

**list-actions**
:   See available actions list.

**install**
:   Install the DevTools in your system.

:        devtools.sh  install  -[common options ...]  --

:   The `-p=... / --path=...` option can be defined to choose the installation path. It
    default to current user's `$HOME/bin/` directory.

**uninstall**
:   uninstall the DevTools from your system

**self-check**
:   check if installed DevTools are up-to-date

**self-update**
:   actually update DevTools

*The following actions are currently available:*

#### cleanup

This will clean (remove) all OS or IDE specific files from the project
(configuration variable: `DEFAULT_CLEANUP_NAMES`).

    devtools.sh  cleanup  -[common options ...]  [--dry-run]  --

#### flush

This will clean (remove) all contents recursively from temporary directories
(configuration variable: `DEFAULT_FLUSH_DIRNAMES`).

    devtools.sh  flush  -[common options ...]  [--dry-run]  --

#### config

Manage the devtools configuration for a package, stored in `.devtools` dotfile ;
with no option, current configuration will be shown.

    devtools.sh  config  -[common options ...]  [--dry-run]
        [--var =name]  [--val =value]  [--filename]  [--full]  --

**--var** =name
:    select a configuration variable to read or define

**--val** =value
:    define a configuration variable value (requires the `--var` option to be defined)

**--filename**
:    see current configuration file path for the project

**--full**
:    see the full configuration entries for the project (defaults and custom)

#### deploy

Will search for files suffixed by `__ENV__` in the project path (recursively) and
over-write the original ones (without suffix).

    devtools.sh  deploy  -[common options ...]  [--dry-run]
        [--env =env]  --

**--env** =name
:    the environment shortcut to deploy (default is `DEFAULT` - configuration variable: `DEFAULT_DEPLOY_ENV`)

#### extract

Will search and extract strings from files contents recursively ; result is written on STDOUT
but can be stored in a file.

    devtools.sh  extract  -[common options ...]  [--dry-run]
        [--begin =mask]  [--end =mask]  [--output =filename]
        [--filename]  --

**--begin** =mask
:   the mask to use to begin the matching (configuration variable: `DEFAULT_EXTRACT_BEGIN_MASK`) 

**--end** =mask
:   the mask to use to end the matching (configuration variable: `DEFAULT_EXTRACT_END_MASK`) 

**--output** =filename
:   a filename to write results in (this will overwrite any existing file)

**--show-filename**
:   write matching filenames before extracted content (configuration variable: `DEFAULT_EXTRACT_SHOW_FILENAME`)

#### fix-rights

This will fix files and directories UNIX rights recursively on the project.

    devtools.sh  fix-rights  -[common options ...]  [--dry-run]
        [--files =chmod]  [--dirs =chmod]  [--bin =path]
        [--bin-mask =mask]  --

**--dirs** =chmod
:   the rights level setted for directories (default is `0755` - configuration variable: `DEFAULT_FIXRIGHTS_DIRS_CHMOD`) 

**--files** =chmod
:   the rights level setted for files (default is `0644` - configuration variable: `DEFAULT_FIXRIGHTS_FILES_CHMOD`) 

**--bin** =path
:   directory name of the binaries, to define their rights on `a+x` (default is `bin/` - configuration variable: `DEFAULT_FIXRIGHTS_BIN_DIR`)

**--bin-mask** =mask
:   mask to match binary files in 'bin' (default is empty - configuration variable: `DEFAULT_FIXRIGHTS_BIN_MASK`)

#### md2man

Build a manpage file based on a markdown content.

    devtools.sh  md2man  -[common options ...]  [--dry-run]
        [--source =path]  [--filename =filename]  [--markdown =bin]  --

**--source** =filename
:   the manpage source file (default is `MANPAGE.md` - configuration variable: `DEFAULT_MANPAGE_SOURCE`) 

**--filename** =filename
:   the filename to use to create the manpage (configuration variable: `DEFAULT_MANPAGE_FILENAME`) 

**--markdown** =bin path
:   the binary to use for the 'markdown' command 
    (default is installed MarkdownExtended package - configuration variable: `DEFAULT_MANPAGE_MARKDOWN_BIN`) 

#### manpage

Build a manpage file based on a markdown content ; the manpage is added in system manpages
and can be referenced if the `whatis` and `makewhatis` binaries are found or defined.

    devtools.sh  manpage  -[common options ...]  [--dry-run]
        [--source =path]  [--filename =filename]  [--type =type]  [--dir =path]
        [--markdown =bin]  [--whatis =bin]  [--makewhatis =bin]  --

**--source** =filename
:   the manpage source file (default is `MANPAGE.md` - configuration variable: `DEFAULT_MANPAGE_SOURCE`) 

**--filename** =filename
:   the filename to use to create the manpage (configuration variable: `DEFAULT_MANPAGE_FILENAME`) 

**--section** =reference
:   the manpage section (default is '3' - configuration variable: `DEFAULT_MANPAGE_SECTION`) 

**--dir** =name
:   the manpage system directory to install manpage in 

**--markdown** =bin path
:   the binary to use for the 'markdown' command 
    (default is installed MarkdownExtended package - configuration variable: `DEFAULT_MANPAGE_MARKDOWN_BIN`) 

**--whatis** =bin path
:   the binary to use for the 'whatis' command (configuration variable: `DEFAULT_MANPAGE_WHATIS_BIN`) 

**--makewhatis** =bin path
:   the binary to use for the 'makewhatis' command (configuration variable: `DEFAULT_MANPAGE_MAKEWHATIS_BIN`)

#### sync

Will synchronize a project directory to a target via `rsync` of `ncftp`. The `rsync` method 
can use SSH protocol if so ; use the `-x` option to process a `--dry-run` rsync.

    devtools.sh  sync  -[common options ...]  [--dry-run]
        [--method =method]  [--env =env]  [--target =server]  [--options ="rsync/ftp options"]  
        [--no-env]  [--env-options ="rsync env options"]  --

**--method** =method
:   the method to use for the synchronization in 'rsync', 'ftp' ; default method is 'rsync'
(configuration variable: `DEFAULT_SYNC_METHOD`) 

**--target** =server
:   the server name to use for synchronization (configuration variable: `DEFAULT_SYNC_SERVER`) 

**--options** ="rsync/ftp opts"
:   an options string used for the 'rsync' or 'ftp' command (configuration variable: `DEFAULT_SYNC_RSYNC_OPTIONS`) 

**--env** =env
:   the environment shortcut to deploy if so (configuration variable: `DEFAULT_SYNC_ENV`)

**--no-env**
:   skip any configured environment deployment

**--env-options** ="rsync opts"
:   an options string used for the 'rsync' command when deploying the environment files
(configuration variable: `DEFAULT_SYNC_RSYNC_ENV_OPTIONS`) 

#### version-tag

This will create a new GIT version TAG according to the semantic versioning (see <http://semver.org/>).

    devtools.sh  version-tag  -[common options ...]  [--dry-run]
        [--name =version]  [--branch =name]  [--hook =path]  [--no-hook]  --

**--name** =version
:   the name of the new tag ; default will be next increased version number 

**--branch** =name
:   which branch to use (default is `master` - configuration variable: `DEFAULT_VERSIONTAG_BRANCH`)

**--hook** =path
:   define a pre-tag hook file (configuration variable: `DEFAULT_VERSIONTAG_HOOK` - see `pre-tag-hook.sample`)

**--no-hook**
:   do not run any pre-tag hook file (disable config setting)

## ENVIRONMENT

The script doesn't really define environment variables but handles a set of configuration
variables that can be overwritten or modified to fit your needs and special environment.
If you want to define a configuration value globally, edit the `devtools.conf` file directly,
which is loaded at any call of the script. You can also define "per project" configuration
settings creating a `.devtools` file at the root of the project. The `config` action of
the script can help you to manage this type of configuration.

*The following configuration variables are available:*

#### global

DEFAULT_BASHLIBRARY_PATH
:   relative path from your project dir to 'piwi-bash-library.sh' ; default is `piwi-bash-library/piwi-bash-library.sh`

DEFAULT_USER_CONFIG_FILE
:   default project config file (DO NOT CHANGE after a first usage) ; default is `.devtools_globals`

DEFAULT_PROJECT_CONFIG_FILE
:   default project config file (DO NOT CHANGE after a first usage) ; default is `.devtools`

#### cleanup

DEFAULT_CLEANUP_NAMES
:   list of file names or masks to remove when cleaning a project ; default is:
    .DS\_Store .AppleDouble .LSOverride .Spotlight-V100 .Trashes Icon .\_\* \*~ \*~lock\* 
    Thumbs.db ehthumbs.db Desktop.ini .project .buildpath

#### deploy

DEFAULT_DEPLOY_ENV
:   default environment name to deploy when using action `deploy` ; default is `default`

#### extract

DEFAULT_EXTRACT_BEGIN_MASK DEFAULT_EXTRACT_END_MASK
:   the default masks to begin and end file contents extraction when using action `extract`

DEFAULT_EXTRACT_SHOW_FILENAME
:   whether to show source filename before contents extracted when using action `extract` ; default is `false`

#### fix-rights

DEFAULT_FIXRIGHTS_BIN_DIR
:   the default binaries path in the project when using action `fix-rights` ; default is `bin/`

DEFAULT_FIXRIGHTS_BIN_MASK
:   the default mask to match binary files when using action `fix-rights`

DEFAULT_FIXRIGHTS_FILES_CHMOD DEFAULT_FIXRIGHTS_DIRS_CHMOD
:   default rights levels to use on files and directories when using action `fix-rights` ;
    default is `0755` dor directories and `0644` for files

#### md2man

DEFAULT_MD2MAN_SOURCE DEFAULT_MD2MAN_FILENAME
:   default source and target file names when using action `manpage` ; default is a source 
    file named `MANPAGE.md`

DEFAULT_MD2MAN_MARKDOWN_BIN
:   path of the binary to use for the `markdown` command ; default is what the script found
    in your system using the `which` command

#### manpage

DEFAULT_MANPAGE_SOURCE DEFAULT_MANPAGE_FILENAME
:   default source and target file names when using action `manpage`

DEFAULT_MANPAGE_SECTION
:   default system manpage type to use when using action `manpage` ; default is `3` which
    is the recommended section for third-party manpages

DEFAULT_MANPAGE_WHATIS_BIN DEFAULT_MANPAGE_MAKEWHATIS_BIN DEFAULT_MANPAGE_MARKDOWN_BIN
:   path of the binaries to use for the `whatis`, `makewhatis` and `markdown` commands
    when using action `manpage` ; default is what the script found in your system using
    the `which` command

#### sync

DEFAULT_SYNC_METHOD
:   default method to use in `rsync` and `ftp` ; default is `rsync`

DEFAULT_SYNC_SERVER
:   default distant server to synchronize when using action `sync`

:   to use an SSH tunnel with method `rsync`, write "-e ssh user@server.name:~/server/path/"

:   to use the `ftp` method, write "-u USER -p PASSWORD -P PORT SERVERNAME REMOTEDIR"

:   to use a host configuration file for the `ftp` method, write "-f FILENAME REMOTEDIR"

DEFAULT_SYNC_RSYNC_OPTIONS DEFAULT_SYNC_FTP_OPTIONS
:   default options to use with the `rysnc` or `ftp` commands when using action `sync` ; 
    default is `avrlzh` which may be used for a default synchronization keeping files permissions

DEFAULT_SYNC_ENV DEFAULT_SYNC_RSYNC_ENV_OPTIONS
:   default environment and options to use with the `rysnc` command when using action `sync` ; default is
    `avrlzh` which may be used for a default synchronization keeping files permissions

DEFAULT_SYNC_FTP_EXCLUDED_FILES DEFAULT_SYNC_FTP_EXCLUDED_DIRS
:   arrays of filenames or dirnames to exclude from synchronization when using the `ftp` method ;
    you can write REGEXP masks

#### version-tag

DEFAULT_VERSIONTAG_BRANCH
:   default branch name to use to create tags when using action `version-tag` ; default is
    `master`

DEFAULT_VERSIONTAG_HOOK
:   path of the hook filename when using action `version-tag`

## FILES

*devtools.sh*, *devtools*
:   The library source file ; this is the script name to call in command line ; it can be
    stored anywhere in the file system ; its relevant place could be `$HOME/bin` for a user
    or, for a global installation, in a place like `/usr/local/bin` (be sure to put it in
    a directory included in the global `$PATH`) ; the script must be executable for its/all
    user(s).

*devtools.conf*
:   The global script configuration file ; this file is required and will be searched in
    the same directory as the script above, then in current user `$HOME`, then in system
    configurations `/etc`.

*devtools-actions/*, *devtools-[action]*
:   This directory contains the actions currently available ; the directory and its contents
    are required to use script's actions ; they will be searched in the same directory as
    the script above, then in current user `$HOME` ; the scripts must be executable for its/all
    user(s).
:   When it is installed globally, each action is stored as a `devtools-action` binary file
    in the same directory as the global script.

*.devtools_globals*
:   This is the specific dotfile to use for "per user" configuration ; you may write your
    configuration following the global `devtools.conf` rules ; this file is searched at the
    root directory of user's `$HOME` and is loaded first.

*.devtools*
:   This is the specific dotfile to use for "per project" configuration ; you may write your
    configuration following the global `devtools.conf` rules ; this file is searched at the
    root directory of each project (defined by the '-p' option) and is loaded last.

*piwi-bash-library/*
:   This directory embeds the required third-party [Piwi Bash Library](https://github.com/atelierspierrot/piwi-bash-library).
    If you already have a version of the library installed in your system, you can over-write
    the library loaded (and skip the embedded version) re-defining the `DEFAULT_BASHLIBRARY_PATH`
    of the global configuration file.

## EXAMPLES

A "classic" usage of the script would be:

    devtools.sh action -p ../relative/path/to/concerned/project

To get an help string, run:

    devtools.sh -h OR devtools.sh action -h OR devtools.sh help action

To make a dry run before really executing the actions, use:

    devtools.sh action --dry-run ...

## LICENSE

Copyleft (C) 2013-2014 Pierre Cassat & contributors

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

<http://www.ateliers-pierrot.fr/> - Some rights reserved. For documentation,
sources & updates, see <http://github.com/atelierspierrot/devtools>. 
To read GPL-3.0 license conditions, see <http://www.gnu.org/licenses/gpl-3.0.html>.

## BUGS

To transmit bugs, see <http://github.com/atelierspierrot/devtools/issues>.

## AUTHOR

**Les Ateliers Pierrot** <http://www.ateliers-pierrot.fr/> - Paris, France.

Created and maintained by **Pierre Cassat** (*piwi* - <http://github.com/pierowbmstr>)
& contributors.

## SEE ALSO

piwi-bash-library(3)
