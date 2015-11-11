.. gtron documentation master file, created by
   sphinx-quickstart on Thu Nov  5 17:05:27 2015.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Welcome to gtron's documentation!
=================================

Gtron is a utility for managing complex software projects that rely on the
contents of multiple SVN or git source repositories.  Gtron knows which repos
the project needs and where they should be stored, and it provides commands
that make it easy make sure everything is up-to-date and working properly.

Gtron manages a "workspace" for your project.  A workspace is a directory that
contains information that gtron needs to function correctly as well as the
directory structure that holds the contents of the source repositories that
your project relies on.  The basic directory structure looks like this:

  * :code:`gtron_devel/` -- the root of the workspace
  * :code:`gtron_devel/repo/` -- gtron configuration files, executables, etc.
  * :code:`gtron_devel/gtron_env.sh` -- Shell script to setup the workspace environment variables.
  * :code:`gtron_devel/<other directories>` -- Where the source repositories live.

The gtron executable provides access to all of gtron's functionality.  For
instance, :code:`gtron build` will build (i.e., run :code:`make`) in all
repositories in the workspace and :code:`gtron update` will get the latest
version of all the repositories.  You can get a complete list of all the gtron
command available with :code:`gtron -h`.


Contents:

.. toctree::
   :maxdepth: 2
	      
   GettingStarted
   Tour
   Commands
   Bugs
   

Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`

