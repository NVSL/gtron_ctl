Gtron Commands
==============

Gtron provides commands for many common operations.  The commands are described below.

Gtron itself takes several command line options. The most important are:

* :code:`-n`:  Perform a dry run (Just print what would happen, don't do anything)
* :code:`--force`:  Continue running even if the virtual environment isn't set up right.
* :code:`--dump-after`: Print out the global and local configuration files after any changes.
* :code:`-v`: Be verbose.

The commands that operate on all the repos (e.g., :code:`build` and
:code:`update`) also take a list of repo directories as positional parameters. For instance:
      
.. code-block: shell
   
   gtron update Gadgets/Tools/Swoop

Will just update :code:`Gadgets/Tools/Swoop`.

Commands that alter the configuration file (e.g., :code:`config_set` and
:code:`add_repo`) operate on the local configuration file by default.  To
modify the global configuration file, use :code:`--global`.


For a complete list of all the gtron commands do:

.. code-block:: shell

   gtron --help

For help with a particular command do

.. code-block:: shell

   gtron <cmd> --help

The appear below as class definitions because gtron commands are defined as
classes internally.

.. currentmodule:: gtron

   
update
------

.. autoclass:: update

build
-----

.. autoclass:: build

test
----

.. autoclass:: test

ubt
---

.. autoclass:: ubt

	       
diff
----

.. autoclass:: diff

status
------

.. autoclass:: status


make
----

.. autoclass:: make

update_system
-------------

.. autoclass:: update_system

setup_devel
-----------

.. autoclass:: setup_devel

new_design
----------

.. autoclass:: new_design

cleanup
-------

.. autoclass:: cleanup

list_repos
----------

.. autoclass:: list_repos

config_set
----------

.. autoclass:: config_set

add_repo
--------

.. autoclass:: add_repo

remove_repo
-----------

.. autoclass:: remove_repo

config_unset
------------

.. autoclass:: config_unset

config_dump
-----------

.. autoclass:: config_dump

