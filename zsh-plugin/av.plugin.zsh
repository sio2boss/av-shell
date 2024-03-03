# AV Plugin from:
export __AV_PROMPT_DIR=$ZSH/plugins/av
AV_COMMAND=`which av`
if [ -z "$AV_COMMAND" ]; then
    return
fi

# Allow for functions in the prompt.
setopt PROMPT_SUBST

## Enable auto-execution of functions.
typeset -ga chpwd_functions

# Append functions needed for mounting and unmounting av projects.
chpwd_functions+='chpwd_update_av_vars'


# when we change working directory mount or unmount av
function chpwd_update_av_vars() {
    update_current_av_vars
}

# Check if current directory is in or below an av project that we have mounted
function update_current_av_vars() {
    unset __CURRENT_AV_STATUS

    _AV_STATUS=`$AV_COMMAND status`
    if [ ! -z ${_AV_STATUS} ]; then

        # We are in an av project directory
        __CURRENT_AV_STATUS="av"


        # TODO: check if we have mounted this project and isn't already activated
        if [[ "$AV_ROOT" != ${_AV_STATUS} ]]; then

            # Unmount existing
            if [[ -z "$AV_ROOT" ]]; then
                source <($AV_COMMAND deactivate)
            fi
            
            # Mount the project
            export AV_OLD_SYSTEM_PATH=/usr/local/bin:$PATH
            source <($AV_COMMAND activate)
        fi

    elif [ ! -z "$AV_ROOT" ]; then
        # We are NOT in an av project directory
        source <($AV_COMMAND deactivate)
    fi
}

# Wrap prompt mods for zsh
function av_prompt_info() {
    if [ ! -z "$__CURRENT_AV_STATUS" ]; then
        echo -e -n "%{$fg_bold[blue]%}av:(%{$fg_bold[green]%}$(av_project_prompt_inputs)%{$fg_bold[blue]%})%{$reset_color%} "
    fi
}

# Over ride av command with this plugin
function av() {

    # If no args, launch interactive
    if [[ $# -eq 0 ]]; then
        source <($AV_COMMAND deactivate)
        $AV_COMMAND
        return $?
    fi

    # Support av-shell global commands without a mounted av project
    if [[ "$1" == "init" || "$1" == "upgrade" || "$1" == "update" || "$1" == "get" || "$1" == "status" ]]; then
        $AV_COMMAND "$@"
        return $?
    fi

    # When we have mounted and activated av, pass through
    if [[ ! -z "$__CURRENT_AV_STATUS" && -z "$AV_ROOT" ]]; then
        shift
        $AV_COMMAND "$@"
        return $?
    fi

    # Display error when not in av project
    if [[ "$1" == "activate" || "$1" == "deactivate" ]]; then
        echo "$fg_bold[yellow]You must be in an av-shell enabled project to run this command$reset_color"
        return 1
    fi
}
