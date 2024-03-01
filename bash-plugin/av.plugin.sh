# AV Plugin from:
export AV_COMMAND=~/.local/bin/av

# From: https://gist.github.com/laggardkernel/6cb4e1664574212b125fbfd115fe90a4
# create a PROPMT_COMMAND equivalent to store chpwd functions
typeset -g CHPWD_COMMAND=""

_chpwd_hook() {
  shopt -s nullglob

  local f

  # run commands in CHPWD_COMMAND variable on dir change
  if [[ "$PREVPWD" != "$PWD" ]]; then
    local IFS=$';'
    for f in $CHPWD_COMMAND; do
      "$f"
    done
    unset IFS
  fi
  # refresh last working dir record
  export PREVPWD="$PWD"
}

# add `;` after _chpwd_hook if PROMPT_COMMAND is not empty
export PROMPT_COMMAND="_chpwd_hook${PROMPT_COMMAND:+;$PROMPT_COMMAND}"


# Check if current directory is in or below an av project that we have mounted
_update_current_av_vars() {

    unset __CURRENT_AV_STATUS

    local _AV_STATUS=$($AV_COMMAND status)
    if [[ ! -z "$_AV_STATUS" ]]; then

        # We are in an av project directory
        __CURRENT_AV_STATUS="av"
        # TODO: check if we have mounted this project and isn't already activated
        if [[ "$AV_ROOT" != "$_AV_STATUS" ]]; then

            # Unmount existing
            if [[ -z "$AV_ROOT" ]]; then
                source <($AV_COMMAND deactivate)
            fi
            
            # Mount the project
            export AV_OLD_SYSTEM_PATH=/usr/local/bin:$PATH
            source <($AV_COMMAND activate)
        fi

    elif [[ ! -z "$AV_ROOT" ]]; then
        # We are NOT in an av project directory
        source <($AV_COMMAND deactivate)
    fi
}

# Wrap prompt mods for zsh
av_prompt_info() {
    if [[ ! -z "$__CURRENT_AV_STATUS" ]]; then
        echo -e -n "%{$fg_bold[blue]%}av:(%{$fg_bold[green]%}$(av_project_prompt_inputs)%{$fg_bold[blue]%})%{$reset_color%} "
    fi
}

# Over ride av command with this plugin
av() {

    # If no args, launch interactive
    if [[ $# -eq 0 ]]; then
        source <($AV_COMMAND deactivate)
        $AV_COMMAND
        return $?
    fi

    # When we have mounted and activated av, pass through
    if [[ ! -z "$__CURRENT_AV_STATUS" && -z "$AV_ROOT" ]]; then
        shift
        $AV_COMMAND "$@"
        return $?
    fi
}

export CHPWD_COMMAND="${CHPWD_COMMAND:+$CHPWD_COMMAND;}_update_current_av_vars"