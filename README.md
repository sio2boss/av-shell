# av-shell

Make your own project specific shell with `av-shell`, the power of _all-your-scripts_ at your finger tips / a customized CLI environment for your project cannot be understated...

This is a really handy tool to organize your scripts and repetitive tasks into one place.  When you run 'av', it looks at $PWD and the recursively upward for a '.av' directory.  So, in a way, this operates like git and other awesome cli tools but you can insert new commands at your leasure.

Contracts:
 * Every script should handle a '-h' argument and output a single line of documentation.  This makes the 'help' look nice
 * Don't overwrite the builtins commands

## Getting Started 

### Installing

You will need the latest golang.  Not using npm anymore. Using oh-my-zsh style of putting it in your home directory under a dot-folder.
   
    git clone --depth=1 https://github.com/sio2boss/av-shell ~/.av && zsh ~/.av/install --yes

Upgrading is as simple as running (run outside av-shell session aka regular zsh/bash):

    av upgrade


### Oh-My-Zsh Plugin Setup (optional)

The install script now detects oh-my-zsh and enables the av-shell plugin but you can manually add by updating your `~/.zshrc` file to include 'av' in the 'plugins' directive:

    plugins=(git docker av)

Additionally, if you want to update your prompt to display when av-shell is mounted, you can do something like this to your `~/.oh-my-zsh/themes/robbyrussell.zsh-theme`

    PROMPT="%(?:%{$fg_bold[green]%}%1{➜%} :%{$fg_bold[red]%}%1{➜%} ) %{$fg[cyan]%}%c%{$reset_color%} "
    PROMPT+='$(av_prompt_info)'
    PROMPT+='$(git_prompt_info)'
    
    ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}git:(%{$fg[red]%}"
    ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
    ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}%1{✗%}"
    ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"

This plugin and prompt will allou you to simply `cd` into a project directory and it will automount.

### Augmenting your project

In your project folder run this (**only needed once**) and answer the wizard question(s):

    av init

Now your project will have a `./.av` folder where the commands you write will be in the `./.av/bin` and accessable on your $PATH when in interactive session or automounted with the oh-my-zsh plugin.


## Usage

### Accessing av-shell in your project

Your project now has a project specific shell, just run `av` for interactive session:

    av

Looks like this:

![Starting up with av](https://raw.githubusercontent.com/sio2boss/av/master/doc/docker.gif)

Or for non-interactive, where help can be replaced with any command:

    help

You will notice there are some docker things in there...make sure you have setup docker like in the Docker section below.

Try creating a new command from the builtin template with:

    new my_new_command

A default editor will be opened if your $EDITOR variable isn't set.  Run the following to edit your scripts after they are created:

    edit my_new_command

Have fun!

### Docker Support


Setup the folder you want to have your docker containers located somewhere other than `./containers` by setting up :

    setpv containerdir containers

Now setup the repo you will push containers to.  Could be dockerhub:

    setpv repo somehostname:port


Under the "containers" directory, create a folder for each container you want to use where you can put your Dockerfile and a Runfile (more about the latter later).  I've include an example directory in this repo for you to copy and use as you like.  Av-docker adds the 'choose' command:

    choose
    ? Which do you want? nginx
    Using nginx as container for docker commands


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

And permanently remove it

    rmc

How many times did you not have to type docker?  Make your life easy with av-docker!

example flow to push container:

    tag latest
    push latest


## Development

### Local Development setup

Switch to your own fork or create a branch in `~/.av` which is at the root of your homedirectory and is not a project specific shell.  You can symlink this directory from a different directory.

### Releasing

Update `config/version` and run the package script like this:

    bash package `cat config/version`

Go here https://github.com/sio2boss/av-shell/releases/new and make release
