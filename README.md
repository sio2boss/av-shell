# av-shell

Make your own domain specific shell (DSS) with `av-shell`, the power of a customized cli environment for your project cannot be understated.

This is a really handy tool to organize your scripts and repetitive tasks into one place.  When you run 'av', it looks at $PWD and the recursively upward for a '.av' directory.  So, in a way, this operates like git and other awesome cli tools but you can insert new commands at your leasure.

Contracts:
 * Every script should handle a '-h' argument and output a single line of documentation.  This makes the 'help' look nice
 * Don't overwrite the builtins
 
## Installing

You will need the latest golang.  Not using npm anymore. Using oh-my-zsh style of putting it in your home directory under a dot-folder.
   
    git clone https://github.com/sio2boss/av-shell ~/.av && bash ~/.av/install

## Using av with your project

In your project folder run this and answer the wizard question(s):

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

# Oh-My-Zsh Plugin

https://gist.github.com/sio2boss/f480b310b233bd639d69


# Docker Support

This is a plugin for [av-shell](https://github.com/sio2boss/av-shell) that integrates docker with your project.

## Dependencies

Need [docker or Docker.app](https://www.docker.com/)

## Setup

Setup the folder you want to have your docker containers located in, e.x. "containers":

    av> setpv containerdir containers

Now setup the repo you will push containers to.  Could be dockerhub:

    av> setpv repo somehostname:port

## Operation

Under the "containers" directory, create a folder for each container you want to use where you can put your Dockerfile and a Runfile (more about the latter later).  I've include an example directory in this repo for you to copy and use as you like.  Av-docker adds the 'choose' command:

    av> choose
    ? Which do you want? nginx
    Using nginx as container for docker commands
    av [nginx]> 

You will notice how your av-shell prompt has changed to include the selected container.

Now you can use normal docker commands but without typing docker and the container name each time.

We are going to use a special av feature to show one way domain specific shells kick ass...

    holdhash on

Lets build the nginx container

    build

For a custom container, you will certainly want to setup the Runfile with docker arguments like this:

    -d -p 80:80 -v $(pwd)/../../log:/var/log/nginx

Now start the container with the 'run' command:

    run

The command should output some huge hash value.  The first 12 chars can always be found with a ps

    ps

    CONTAINER ID    IMAGE   COMMAND              CREATED           STATUS          PORTS                NAMES
    e1526432ae2f    nginx   /usr/local/bin/run   31 seconds ago    Up 31 seconds   0.0.0.0:80->80/tcp   stupefied_morse

But lets stop it with that 'holdhash' feature

    stop

And start it back up again

    start

Handy right?  Well what if we what to shell into that container?  av will help you here (need docker 1.3+)

    shell

Lets shut it down

    stop

And perminantly remove it

    rmc

How many times did you not have to type docker?  Make your life easy with av-docker!

example flow to push container:

    tag latest
    push latest


