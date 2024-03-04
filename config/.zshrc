#! /bin/zsh

export AV_OLD_SYSTEM_PATH=/usr/local/bin:$PATH
export AV_PROJECT_CONFIG_DIR=$AV_ROOT/config
export AV_INSTALLED_BIN=$AV_INSTALLED_PATH/bin
export AV_INSTALLED_PLUGINS=$AV_INSTALLED_PATH/plugins
export AV_CONFIG_DIR=$AV_INSTALLED_PATH/config
export AV_BIN_DIR=$AV_ROOT/bin
export AV_PROJ_TOP=$AV_ROOT/..

# Figure out OS
THIS_OS=`uname`

# Setup path
av_path="$AV_INSTALLED_BIN"
for plugin in `ls -1 $AV_INSTALLED_PLUGINS`; do
  av_path=${av_path}:$AV_INSTALLED_PLUGINS/${plugin}/bin
done

# Bring in color
source $AV_CONFIG_DIR/color

if [[ "$AV_INTERACTIVE_MODE" == "interactive" ]]; then

    # set a fancy prompt (non-color, unless we know we "want" color)
    TERM=xterm-256color
    LANG=en_US.UTF-8
    LC_CTYPE=en_US.UTF-8
    case "$TERM" in
        xterm-color) color_prompt=yes;;
    esac
    
    # Zsh style history search
    HISTFILE=$AV_INSTALLED_PATH/.zsh_history
    HISTSIZE=100000000
    SAVEHIST=100000000
    setopt HIST_IGNORE_SPACE
    setopt appendhistory autocd beep extendedglob nomatch notify
    autoload -Uz compinit && compinit
    zmodload -i zsh/complist
    zstyle ':completion:*' menu select
    unsetopt banghist
    bindkey '^[[Z' reverse-menu-complete
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=teal'
    bindkey "^A" vi-beginning-of-line
    bindkey "^E" vi-end-of-line
    bindkey "^[[A" up-line-or-beginning-search # Up
    bindkey "^[[B" down-line-or-beginning-search # Down
    # start typing + [Up-Arrow] - fuzzy find history forward
    if [[ "${terminfo[kcuu1]}" != "" ]]; then
        autoload -U up-line-or-beginning-search
        zle -N up-line-or-beginning-search
        bindkey "${terminfo[kcuu1]}" up-line-or-beginning-search
    fi
    # start typing + [Down-Arrow] - fuzzy find history backward
    if [[ "${terminfo[kcud1]}" != "" ]]; then
        autoload -U down-line-or-beginning-search
        zle -N down-line-or-beginning-search
        bindkey "${terminfo[kcud1]}" down-line-or-beginning-search
    fi

    
    # leave some commands out of history log
    export HISTIGNORE="&:bg:fg:ll:h:??:[ ]*:clear:exit:logout"
    export TIMEFORMAT=$'\nreal %3R\tuser %3U\tsys %3S\tpcpu %P\n'
    export HISTTIMEFORMAT="%H:%M > "

    # Make an alias so that help can run
    alias help='$AV_INSTALLED_PATH/plugins/av-shell/bin/help'
    alias team='$AV_INSTALLED_PATH/plugins/av-shell/bin/squad'
    alias update='$AV_INSTALLED_PATH/plugins/av-shell/bin/upgrade'
    alias get_tag_from_commit='$AV_INSTALLED_PATH/plugins/av-shell/bin/codehash'
    alias ls=`which ls 2> /dev/null`
    alias rm=`which rm 2> /dev/null`
    alias bash=`which bash 2> /dev/null`
    alias java=`which java 2> /dev/null`
    alias ln=`which ln 2> /dev/null`
    alias cat=`which cat 2> /dev/null`

    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

    # Set prompt to something short and different
    export PATH=$AV_BIN_DIR:${av_path}:/usr/local/bin:/usr/bin:/opt/homebrew/bin/:~/.local/bin:~/go/bin
else
    export PATH=$AV_BIN_DIR:${av_path}:$PATH
fi

function av_project_prompt_inputs() {
    echo -e -n `/bin/cat $AV_PROJECT_CONFIG_DIR/prompt`
}

function av_container_prompt_inputs() {
    cur_container=`getpv container`
    if [ ! -z ${cur_container} ]; then
        echo -e -n "%F{blue}${cur_container}%f"
    fi
}

function av_cluster_prompt_inputs() {
    cur_environment=`getpv environment`
    cur_cluster=`getpv cluster`
    if [ ! -z ${cur_cluster} ]; then
        echo -e -n "%F{olive}${cur_environment}>${cur_cluster}%f"
    fi
}

function av_role_prompt_inputs() {
    cur_role=`getpv role`
    if [ ! -z ${cur_role} ]; then
        echo -e -n "%F{aqua}[${cur_role}"
    fi
}

function av_topic_prompt_inputs() {
    cur_role=`getpv kafka-topic`
    if [ ! -z ${cur_role} ]; then
        echo -e -n "%F{magenta}${cur_role}%f"
    fi
}

function context_prompts() {
    cluster=$(av_cluster_prompt_inputs)
    container=$(av_container_prompt_inputs)
    role=$(av_role_prompt_inputs)
    topic=$(av_topic_prompt_inputs)

    echo -e -n "["
    echo -e -n "$cluster"

    if [[ ! -z $container && ! -z $cluster ]]; then
        echo -e -n "|"
    fi
    echo -e -n "$container"


    if [[ ! -z $role && (! -z $cluster || ! -z $container) ]]; then
        echo -e -n "|"
    fi
    echo -e -n "$role"

    if [[ ! -z $topic && (! -z $cluster || ! -z $container || ! -z $role) ]]; then
        echo -e -n "|"
    fi
    echo -e -n "$topic"


    echo -e -n "]"
}

function av_venv_prompt_inputs() {
    name=`basename "$VIRTUAL_ENV"`
    if [[ ! -z name ]]; then
        echo "${name}"
    fi
}

function av_docker_context_prompt_inputs() {
    if [[ -z $DOCKER_HOST ]]; then
        echo "localhost"
    else
        echo $DOCKER_HOST | sed -e 's/.*\/\///'
    fi
}

# Support .env.*
function refresh () {
    if [[ -f .env ]]; then
        unamestr=$(uname)
        if [ "$unamestr" = 'Linux' ]; then
            if [[ "$AV_INTERACTIVE_MODE" == "interactive" && -z "$1" ]]; then
                echo -e " - Reloading .env file..."
            fi
            export $(grep -v '^#' .env | xargs -d '\n')
        elif [[ "$unamestr" = 'FreeBSD' || "$unamestr" = 'Darwin' ]]; then
            if [[ "$AV_INTERACTIVE_MODE" == "interactive" && -z "$1" ]]; then
                echo -e " - Reloading .env file..."
            fi
            export $(grep -v '^#' .env | xargs -0)
        fi
    fi
}

# Wrap commands that change .env files so reload always happens
function switch() {   
    $AV_INSTALLED_PLUGINS/av-clusters/bin/switch "$@"
    if [[ $? -eq 0 ]]; then
        refresh
    fi
}


function inventory_state() {
    $AV_INSTALLED_PLUGINS/av-pagos/bin/inventory_state "$@"
    if [[ $? -eq 0 && "$1" == "restore" ]]; then
        sleep 1
        refresh
    fi
}


# This loads nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Search for python env
if [[ -e $AV_PROJ_TOP/.venv/bin/activate ]]; then
    source $AV_PROJ_TOP/.venv/bin/activate
    export PATH=$AV_BIN_DIR:$VIRTUAL_ENV/bin:$PATH
elif [[ -e $AV_PROJ_TOP/venv/bin/activate ]]; then
    source $AV_PROJ_TOP/venv/bin/activate
    export PATH=$AV_BIN_DIR:$VIRTUAL_ENV/bin:$PATH
fi
if [[ -e $AV_PROJ_TOP/venv/conda-meta ]]; then
    # >>> conda initialize >>>
    # !! Contents within this block are managed by 'conda init' !!
    __conda_setup="$('/opt/homebrew/Caskroom/miniconda/base/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    else
        if [ -f "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh" ]; then
            . "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh"
        else
            export PATH="/opt/homebrew/Caskroom/miniconda/base/bin:$PATH"
        fi
    fi
    unset __conda_setup
    # <<< conda initialize <<<
    export VIRTUAL_ENV="venv(conda)"
    conda activate $AV_PROJ_TOP/venv
fi

# Set tab title for iTerm2
echo -ne "\033]0;$p\007"

# Welcome
if [[ "$AV_INTERACTIVE_MODE" == "interactive" ]]; then

  # Prompt
  refresh start
  setopt PROMPT_SUBST
  p=$(av_project_prompt_inputs)
  PROMPT="%(?:%F{green}$p%f:%F{red}$p%f)"
  PROMPT+=' $(context_prompts) '
  PROMPT+="➜ "
  export PROMPT
  export AV_OLD_RPROMPT=$RPROMPT
  export RPROMPT="\$AWS_PROFILE:$(av_venv_prompt_inputs):$(av_docker_context_prompt_inputs)"

  $AV_CONFIG_DIR/welcome
fi
