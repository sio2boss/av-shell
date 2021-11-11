#! /bin/zsh

export AV_OLD_SYSTEM_PATH=$PATH
export AV_PROJECT_CONFIG_DIR=$AV_ROOT/config
export AV_INSTALLED_BIN=$AV_INSTALLED_PATH/bin
export AV_INSTALLED_PLUGINS=$AV_INSTALLED_PATH/plugins
export AV_CONFIG_DIR=$AV_INSTALLED_PATH/config
export AV_BIN_DIR=$AV_ROOT/bin
export AV_PROJ_TOP=$AV_ROOT/..

# Figure out OS
THIS_OS=`uname`

# Bring in color
source $AV_CONFIG_DIR/color

# Setup path
av_path="$AV_INSTALLED_BIN"
for plugin in `ls -1 $AV_INSTALLED_PLUGINS`; do
  av_path=${av_path}:$AV_INSTALLED_PLUGINS/${plugin}/bin
done

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
# HISTCONTROL=ignoredups:ignorespace
TERM=xterm-256color
LANG=en_US.UTF-8
LC_CTYPE=en_US.UTF-8

# append to the history file, don't overwrite it
# shopt -s histappend
# shopt -s cdspell
# shopt -s nocaseglob
 
# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
# HISTSIZE=1000
# HISTFILESIZE=2000
 
# Zsh style history search
autoload -Uz compinit && compinit
zmodload -i zsh/complist
zstyle ':completion:*' menu select
bindkey '^[[Z' reverse-menu-complete
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=teal'
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search # Up
bindkey "^[[B" down-line-or-beginning-search # Down

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac
 
# leave some commands out of history log
export HISTIGNORE="&:bg:fg:ll:h:??:[ ]*:clear:exit:logout"
export TIMEFORMAT=$'\nreal %3R\tuser %3U\tsys %3S\tpcpu %P\n'
export HISTTIMEFORMAT="%H:%M > "

# Make an alias so that help can run
alias help='$AV_INSTALLED_PATH/plugins/av-shell/bin/help'
alias team='$AV_INSTALLED_PATH/plugins/av-shell/bin/squad'
alias update='$AV_INSTALLED_PATH/plugins/av-shell/bin/upgrade'
alias get_tag_from_commit='$AV_INSTALLED_PATH/plugins/av-shell/bin/codehash'
alias ls=`whereis ls 2> /dev/null`
alias rm=`whereis rm 2> /dev/null`
alias bash=`which bash 2> /dev/null`
alias java=`which java 2> /dev/null`
alias ln=`whereis ln 2> /dev/null`

# Set prompt to something short and different
export PATH=$AV_BIN_DIR:${av_path}:/usr/local/bin:/usr/bin

function container_prompt() {
    cur_container=`getpv container`
    if [ ! -z ${cur_container} ]; then
        echo -e -n "%F{blue}${cur_container}%f"
    fi
}

function cluster_prompt() {
    cur_cluster=`getpv cluster`
    if [ ! -z ${cur_cluster} ]; then
        echo -e -n "%F{olive}${cur_cluster}%f"
    fi
}

function role_prompt() {
    cur_role=`getpv role`
    if [ ! -z ${cur_role} ]; then
        echo -e -n "%F{aqua}[${cur_role}"
    fi
}

function topic_prompt() {
    cur_role=`getpv kafka-topic`
    if [ ! -z ${cur_role} ]; then
        echo -e -n "%F{magenta}${cur_role}%f"
    fi
}

function context_prompts() {
    cluster=$(cluster_prompt)
    container=$(container_prompt)
    role=$(role_prompt)
    topic=$(topic_prompt)

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

function venv_prompt() {
    name=`basename "$VIRTUAL_ENV"`
    if [[ ! -z name ]]; then
        echo "${name}"
    fi
}

function aws_profile() {
    echo $AWS_PROFILE
}

function aws_profile() {
    echo $AWS_PROFILE
}

function docker_context() {
    if [[ -z $DOCKER_HOST ]]; then
        echo "localhost"
    else
        echo $DOCKER_HOST | sed -e 's/.*\/\///'
    fi
}

# Welcome
if [[ "$AV_NON_INTERACTIVE" != "true" ]]; then

  # Search for python env
  if [[ -e $AV_PROJ_TOP/venv/bin/activate ]]; then
    source $AV_PROJ_TOP/venv/bin/activate
    export PATH=$AV_BIN_DIR:$VIRTUAL_ENV/bin:${av_path}:/usr/local/bin:/usr/bin
  fi

  # Set tab title for iTerm2
  p=`/bin/cat $AV_PROJECT_CONFIG_DIR/prompt`
  echo -ne "\033]0;$p\007"

  # Prompt
  setopt PROMPT_SUBST
  PROMPT="%(?:%F{green}$p%f:%F{red}$p%f)"
  PROMPT+=' $(context_prompts) '
  PROMPT+="➜ "
  export PROMPT

  export RPROMPT="$(aws_profile):$(venv_prompt):$(docker_context)"

  $AV_CONFIG_DIR/welcome
fi
