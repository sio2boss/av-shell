# av

[![NPM version](http://img.shields.io/npm/v/av-shell.svg)](https://www.npmjs.com/package/av-shell) [![Build Status](https://travis-ci.org/sio2boss/av.svg)](https://travis-ci.org/sio2boss/av)

Make your own domain specific shell (DSS).  The power of bash customized for your project.

This is a really handy tool to organize your scripts and repetitive tasks into one place.  When you run 'av', it looks at $PWD and the recursively upward for a '.av' directory.  So, in a way, this operates like git and other awesome cli tools but you can insert new commands at your leasure.

Contracts:
 * Every script should handle a '-h' argument and output a single line of documentation.  This makes the 'help' look nice
 * Don't over write the builtins
 
## Installing

Its now a package!
   
    npm install -g av-shell
    # Depending on your npm or node installation, you may need to use `sudo` when performing an installation through npm
    sudo npm install -g av-shell


## Using this repo

Pull down the code:

    git clone https://github.com/sio2boss/av.git

Install to your system:

    npm install -g
    # Depending on your npm or node installation, you may need to use `sudo` when performing an installation through npm
    sudo npm install -g


## Using av with your project

In your project run and answer the wizard question(s):

    av init

Your project now has a domain specific shell, just run for interactive:

    av

Looks like this:

![Starting up with av](https://raw.githubusercontent.com/sio2boss/av/master/doc/start.png)

Or for non-interactive, where help can be replaced with any command:

    av help

You will notice there are some docker things in there...make sure you have setup docker like in the Docker section below.

Try creating a new command from the builtin template with:

    av new my_new_command

A default editor will be opened if your $EDITOR variable isn't set.  Run the following to edit your scripts after they are created:

    av edit

Have fun!

## av-docker

Also be sure to checkout [av-docker](https://github.com/sio2boss/av-docker)

## Oh-My-Zsh Plugin

https://gist.github.com/sio2boss/f480b310b233bd639d69



