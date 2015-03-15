# CHANGELOG for remote repository  https://github.com/piwi/dev-tools.git

* v0.1.0 (2014-12-21 - 5aca374)

    * c594337 - moving the 'piwi-bash-library' in 'libexec/' (piwi)
    * 3505c00 - update master to be compliant with wip (piwi)
    * 01a6972 - fix a bad var name in release builder (piwi)
    * 767e637 - upgrade to version 0.1.0 (piwi)
    * 27e262a - new manpage generation with no copyleft (piwi)
    * 023bd4f - cleaning master after merge (piwi)
    * 779ffc5 - updating the composer's version to 1.4 (piwi)
    * 031dbe1 - no more 'devtools-action.sh' script info for global install (not yet in place) (piwi)
    * b6b191a - fix a typo in USAGE of 'sync' action (piwi)
    * d2a8f44 - fixing typos in the MANPAGE (piwi)
    * 3100bc9 - fixing typos in README (piwi)
    * 3050e25 - add the manpage in composer binaries to install + review of the README (piwi)

--
!! - moving ownership of the repository to: <http://github.com/piwi/dev-tools>
NOTE - The "old-" tags referred to <http://github.com/atelierspierrot/dev-tools>.
--

* old-v1.3.5 (2014-11-22 - 9e2aac7)

    *   the 'sync' action now use a copy of files to synchronize for the 'FTP' method
    *   the 'devtools.sh' now uses a global shebang (for compatibility)
    *   all action scripts now use the global shebang (for compatibility)
        (to open the FTP connection only once)
    *   the 'sync' action is upgraded to version 1.0.0
    *   update of the PiwiBashLibrary to version 2.0.4
    * 0d2bc3a - upgrading the 'sync' action to version 1.0.0 + info in ChangeLog (piwi)
    * 24266b7 - review & update of the FTP 'sync' method (piwi)
    * 7719bd3 - deletion of a false 'help' comment (piwi)
    * 1633520 - add of #46f2326 in ChangeLog (piwi)
    * 9188af3 - all scripts now use the compatible shebang (piwi)
    * f2580ce - updating PiwiBashLib to version 2.0.4 (piwi)

* old-v1.3.4 (2014-11-20 - 186c066)

    *   update of the PiwiBashLibrary to version 2.0.3
    * 8a824db - adding the 'help action' info in global lib help (piwi)
    * dddcc47 - updating lib shebang for compatibility (piwi)
    * 277faff - Upgrading the 'sync' action to '1.0.0-beta' (piwi)
    * 611065d - update of the PiwiBashLibrary to version 2.0.3 (piwi)
    * 36886ca - new MDE repo url (piwi)

* old-v1.3.3 (2014-06-11 - 173fad3)
* old-v1.3.2 (2014-06-03 - 1a76a8e)

    *   renaming old 'atelierspierrot/markdown-extended' to 'piwi/markdown-extended'
    *   update of the PiwiBashLibrary to version 2.0.2
    * b711566 - renaming '.devtools_globals' to '.devtools_global' (no trailing 's') (Piero Wbmstr)
    * 1aae15a - manual merge of 'wip' state (Piero Wbmstr)

* old-v1.3.1 (2014-05-18 - 77df2f6)

    *   PiwiBashLibrary updated to version 2.0.1
    *   pre-tag-hook ameliorated
    *   new FTP method for the 'sync' action
    * 6f1275f - reviewing the 'sync' method doc (Piero Wbmstr)
    * 40453e8 - new FTP method for synchronization (Piero Wbmstr)
    * 46864bc - Updating the PiwiBashLibrary to version 2.0.1 (Piero Wbmstr)

* old-v1.3.0 (2014-04-16 - 06c0f1a)

    * 12ed885 - Fix: pre-tag-hook version/date/vcs_version insertion (Piero Wbmstr)
    * 282f83d - Fix: missing quotes in 'version-tag' action (Piero Wbmstr)
    * 786cca1 - WIP: adaptation to PiwiBashLib 2.0 (Piero Wbmstr)
    * 960b71a - New 'list-actions' internal option (Piero Wbmstr)
    * a0582d7 - Installation methods (Piero Wbmstr)

* old-v1.2.4 (2014-04-01 - fc63a29)

    * d3bd7d0 - License infos in scripts (Piero Wbmstr)
    * d69fcfd - New "flush" action (Piero Wbmstr)
    * 4a6168d - Update branch alias to fit releases number (Piero Wbmstr)
    * fcb49ba - Correcting the "pre-tag-hook" internal hook (Piero Wbmstr)

* old-v1.2.3 (2013-11-09 - 70beab1)
* old-v1.2.2 (2013-11-09 - 3967fd5)

    * 398e9cc - Typo in the "pre-tag-hook" management (Piero Wbmstr)

* old-v1.2.1 (2013-11-05 - b7414e9)

    * e806ca8 - Using the "dryrun" env var (Piero Wbmstr)
    * 63ca0c2 - Update of PiwiBashLibrary (version 1.0.0) (Piero Wbmstr)
    * 1a37a3b - Internal actions are not ready yet (Piero Wbmstr)

* old-v1.2.0 (2013-11-04 - 4792d91)

    *   new 'less' and 'more' options for the help
    *   switching the old BashLibrary package to PiwiBashLibrary 1.0.0
    *   new 'env' option for the 'synch' action
    *   new 'list-actions' internal action
    * e6d3dbb - Switching the old "bash-library" package to the new "piwi-bash-library" (Piero Wbmstr)
    * 41e46c7 - Adding the 'less' and 'more' options for 'help' (Piero Wbmstr)
    * 6221f3d - Work on the manpage and help string (Piero Wbmstr)
    * f3e043c - Cleaning the "manpage" action (new library version) (Piero Wbmstr)

* old-v1.1.0 (2013-10-24 - 2466fa9)

    *   renaming original 'deploy.sh' in 'dev-tools.sh', it's real name
    *   'dev-tools' becomes 'devtools'
    *   BashLibrary updated to version 1.0.4
    *   new dependence to the 'atelierspierrot/markdown-extended' package
    *   usage of the default BashLibrary "usage" strings
    *   internal configuration is now handled in 'devtools.conf'
    *   actions:
        - new 'pre-tag-hook' feature for the 'version-tag' action
        - changing action 'filename' to 'show-filename' for the 'extract' action
        - new 'manpage' action

    * bb9f706 - Adding the 'mandb' command for Linux + taking first any installed markdown-extended (Piero Wbmstr)
    * 2a82dea - Detail about help rendering (Piero Wbmstr)
    * 82e8189 - New MarkdownExtended bin name (Piero Wbmstr)

* old-v1.0.7 (2013-10-20 - aab74e0)
* old-v1.0.6 (2013-10-20 - e20c174)

    * d839000 - Adding a DevTools config for DevTools (Piero Wbmstr)
    * bd7de25 - Adding the MarkdownExtended package in dev requirements (for manpage) (Piero Wbmstr)
    * 0d732f2 - Dispatching name & presentation (Piero Wbmstr)
    * fec1fca - New "manpage" feature (Piero Wbmstr)
    * 6a01f7f - Changing option "filename" in "show-filename" (Piero Wbmstr)

* old-v1.0.5 (2013-10-18 - 1b90302)
* old-v1.0.4 (2013-10-17 - 84fdbc6)
* old-v1.0.3 (2013-10-17 - 9919bd6)
* old-v1.0.2 (2013-10-16 - f43780b)

    * 0136be6 - New "version-tag" presentation (Piero Wbmstr)

* old-v1.0.1 (2013-10-14 - 63c41f3)

    *   full redesign:
        - specific help string for each action
        - new files rights
        - allow usage of a personal action filename
        - new naming for conig vars
        - new 'dry-run' option (same as '-x')
    *   new 'extract' action
    *   'version-tag' action review: correction in informations

    * 6c51165 - New version 1.0.1 (Piero Wbmstr)
    * 845755d - New gitignore settings to prepare WIP branch (Piero Wbmstr)

* old-v1.0.0 (2013-10-14 - 602c56b)

    *   BashLibrary version 0.0.1
    *   initial actions
    * 445d7f0 - New bash library version (Piero Wbmstr)
    * 5a44702 - New version of the Bash Library (Piero Wbmstr)
    * 10d1f92 - New deploy actions (Piero Wbmstr)
    * f71208f - New installation instructions (Piero Wbmstr)
    * ae2c850 - New loading management (Piero Wbmstr)
    * c38264d - Moving the bash library (Piero Wbmstr)
    * 42cc657 - New events triggering (Piero Wbmstr)
    * a6e6762 - New configuration file (Piero Wbmstr)
    * 9a2dc3c - First version of "deploy.sh" with actions (Piero Wbmstr)
    * ea31d4f - The required bash-library (Piero Wbmstr)
    * 698369a - Information & config files (Piero Wbmstr)
    * 3d094c4 - Initial commit (Piero Wbmstr)

