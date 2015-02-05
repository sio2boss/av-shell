# av

[![Build Status](https://travis-ci.org/sio2boss/av.svg)](https://travis-ci.org/sio2boss/av)

Make your own domain specific shell (DSS).  The power of bash customized for your project.

## Using

Pull down the code:

    git clone https://github.com/sio2boss/av.git

Install to your system:

    npm install -g

In your project run and answer the wizard question(s):

    av init

Your project now has a domain specific shell, just run for interactive:

	av

Or for non-interactive, where help can be replaced with any command:

	av help

Try creating a new command from the builtin template with:

	av new my_new_command

If you have sublime installed, run the following to update the scripts:

	av edit

Have fun!

## Upgrading

When a new version is released, you will need to 'git pull' and re-install.  Then your DSS needs to be updated, which can be done with:

    av update

I will caution that you should backup your DSS.  Only the core scripts are updated but you are free to change the prompt and make any modifications to the .av directory...the update doesn't check at the moment so overwrites are possible.

## Suggestions / Vision

This is a really handy tool to organize your scripts and repetitive tasks into one place.  When you run 'av', it looks at $PWD and the recursively upward for a '.av' directory.  So, in a way, this operates like git and other awesome cli tools but you can insert new commands at your leasure.

Contracts:
 * Every script should handle a '-h' argument and output a single line of documentation.  This makes the 'help' look nice
 * Don't over write the builtins
 
