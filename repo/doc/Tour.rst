Gtron's Structure
=================

Gtron manages a workspace that contains source repositories (repos) stored in
either SVN or git.  Gtron provides a set of operations you can perform on these
repos (e.g., update, build, diff, status).

The Workspace
-------------

The workspace defines a directory structure that organize the repos.  For instance, the Gadgetron workspace directory structure looks like:

 * :code:`gtron_devel/Gadgets/Tools` -- Where the tools live.
 * :code:`gtron_devel/Gadgets/Libraries` -- Where the libraries (gcom, Eagle, etc.) live.
 * :code:`gtron_devel/Gadgets/Designs` -- Where gadget designs live.

Each repo is checked out into a subdirectory under one of these workspace
directories.  For instance, Swoop ends up in :code:`gtron_devel/Gadgets/Swoop`.

When you checkout :code:`gtron_devel`, you get the gtron tools (in
:code:`gtron_devel/repo/bin` and :code:`gtron_devel/repo/lib`) and you get the
the workspace configuration file for Gadgetron
(:code:`gtron_devel/repo/config/Workspace.json`).  The configuration file
specifies which repos the workspace should include and where they should go in
the workspace directory structure.

Since the workspace configuration file is stored in a git repository, you can
modify the workspace for the project by making changes to the file and
committing them.


:code:`Workspace.json`
----------------------

The configuration file is on json format.  Here's a sample :code:`Workspace.json` that illustrates what it can specify:

.. code-block:: javascript

   {
    "repos": [
        {
            "directory": "Gadgets/Libraries",
            "url": "$NVSL_SVN/Libraries/Parts"
        },
        {
            "directory": "Gadgets/Designs",
            "url": "$NVSL_SVN/Designs/testGadget"
        },
        {
            "directory": "Gadgets/Designs",
            "no_build": "TRUE",
            "order": 1000,
            "url": "$NVSL_GIT/gtron-design-template"
        },
        {
            "directory": "Gadgets/Tools",
            "order": "1000",
            "url": "$NVSL_SVN/Tools/jet_2"
        }
    ],
    "vars": {
        "NVSL_GIT": "git@github.com:NVSL",
        "NVSL_SVN": "svn+ssh://${nvsl_user}@bbfs-01.calit2.net/grw/Gordon/svn/${branch}/Gadgets",
        "design_template": "$NVSL_GIT/gtron-design-template"
    }
   }


The list :code:`repos` contains a list of repo specifications.  A repo can four fields:

* :code:`directory` : This specifies the workspace directory the repo should reside under. (Required)
* :code:`url` : This is the URL of the repo in either SVN or git.  For SVN repos they should be :code:`svn+ssh` URLs.  For git they should be :code:`git@github.com`-style URLs. (Required)
* :code:`no_build` : :code:`True` if gtron should not try to build this repo when you run :code:`gtron build`. Default to :code:`False`
* :code:`order` : Gtron shorts repos in ascending order according to this value before it iterates over them for commands like :code:`gtron build`.  The default is 500.

The :code:`vars` section of the file contains a set of variables stored as a
set of key-value pairs.  The variables can appear in repo definitions and
variable definitions.  To use a variable, prefix its name with :code:`$`.  You
can enclose the variable name in curly braces if needed to separate it from the
surrounding text.

:code:`Workspace.json` is the primary configuration file for gtron and
specifies repos and variables that everyone uses when they work on the project
contained in the workspace.  However, different users require different values
for some variables, and a user may wish to include a repo that others do not.

To facilate this, there is local workspace configuration file called
:code:`gtron_devel/repo/config/Workspace.local.json`.  The format is the same,
and the repos listed in the local configuration are merged into the list of
repos.  Both configuration files can use variables defined in the other.

Here is a typical local config file:

.. code-block:: javascript

   {
    "repos": [],
    "vars": {
        "github_user": "stevenjswanson",
        "nvsl_user": "swanson",
	"branch" : "trunk"
    }
   }


