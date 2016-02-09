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

## Upgrading

When a new version is released, you will need to 'git pull' and re-install.  Then your DSS needs to be updated, which can be done with:

    av update

I will caution that you should backup your DSS.  Only the core scripts are updated but you are free to change the prompt and make any modifications to the .av directory...the update doesn't check at the moment so overwrites are possible.

## Docker

After installing docker.io, make sure your user has permissions to run the docker command:

    sudo gpasswd -a ${USER} docker

Make sure to restart the service

    sudo service docker.io restart

Restart your shell or do:

    newgrp docker

If you can run 'docker ps' and get results, then you are good to use the 'av' commands which are basically all the docker commands but you don't need to type docker every time.  One exception 'docker rm' is aliased to 'rmc' (for remove container) which is much like the 'docker rmi' which within the shell is aliased to 'rmi (remove image).

## Docker example with av awesomeness

Lets setup elastic search, name your prompt 'es'...

    mkdir demo && cd demo  && av init

Now launch your shell

    av

So easy.  Lets pull down the ElasticSearch docker container

    pull orchardup/elasticsearch

We are going to use a special av feature to show one way domain specific shells kick ass...

    holdhash on

This will hold the container hash produced by run so we don't have to copy and paste it all the time.  Now run the container

    run -d -p 9200:9200 -t orchardup/elasticsearch

For a custom container, create a Runfile next to your Dockerfile with your docker run arguments, like this:

    -p 9200:9200

The command should output some huge hash value.  The first 12 chars can always be found with a ps

    ps

    CONTAINER ID        IMAGE                            COMMAND              CREATED             STATUS              PORTS                              NAMES
    e1526432ae2f        orchardup/elasticsearch:latest   /usr/local/bin/run   31 seconds ago      Up 31 seconds       9300/tcp, 0.0.0.0:9200->9200/tcp   stupefied_morse

But lets stop it with that 'holdhash' feature

    stop

And start it back up again

    start

Handy right?  Well what if we what to shell into that container?  av will help you here (need docker 1.3+)

    shell

Lets shut it down and remove it

    stop
    rmc

How many times did you not have to type docker?  Eight!  Make your life easy with av!

## Oh-My-Zsh Plugin

https://gist.github.com/sio2boss/f480b310b233bd639d69



