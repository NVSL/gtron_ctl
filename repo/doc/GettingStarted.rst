Getting Started
===============

The new build/checkout system relies on a git repo that you clone to get started.  The repo contains some tools that build/checkout system uses and a configuration file that specifies what to checkout/build.   To get started you should do:

.. code-block:: shell

   git clone -b develop git@github.com:NVSL/gtron_devel.git
   cd gtron_devel

This clones the gtron_devel repo and moves you to the develop branch, which will get you the latest/development version of the checkout system.

Then do

.. code-block:: shell

   source gtron_env.sh

To set up the environment.

You should now have a program called gtron in your path.  gtron is the utility you use to setup, checkout, and build the Gadgetron tools.  When you clone the gtron_devel repo the first time, you need to run gtron update_system and  gtron setup_devel to setup/update your computer system (e.g., install the latest version of Eagle) and initialize the development environment you are creating:

.. code-block:: shell
   
   gtron --force update_system 
   gtron --force setup_devel --nvsl-user <YOUR NVSL USERNAME> --git-user <YOUR GITHUB USERNAME>

This will install any system-wide tools you are missing and initialize your build environment and ensure that you can connect to the SVN and github repos.  It will take a while, since it needs to build CGAL and install a bunch of local python packages.

Once it's done, you should do

.. code-block:: shell
   
   activate_gadgetron

This will finish setting up your path now that your development environment is good to go.  You can tell that things are working properly because your prompt in the shell will change.  For example: 

.. code-block:: shell
   
   (Gadgetron)Stevens-MacBook-Pro-4:~/research/NVSL/src/gtron_devel

The (Gadgetron) is means that you are operating in Python virtual environment.  That environment provides all the Gadgetron executables, etc. that you will need.  To leave the virtual environment you can do deactivate_gadgetron.

Next, you need to check out, build, and test everything:

.. code-block:: shell
   
   gtron update
   gtron build
   gtron test

You should see a listing of all the directories, and this should pass/succeed.

The directory structure is just the same as was with the old checkout system, but you'll need to do commits in the directories that correspond to repos (Tools/*, Libraries/*).
