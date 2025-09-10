# AV Plugin from:
export __AV_PROMPT_DIR="${ZSH}/plugins/av"
if [ -f "${HOME}/.local/bin/av" ]; then
    AV_COMMAND="${HOME}/.local/bin/av"
elif [ -f "/usr/local/bin/av" ]; then
    AV_COMMAND="/usr/local/bin/av"
else
    return
fi

# Allow for functions in the prompt.
setopt PROMPT_SUBST

# Load the add-zsh-hook function
autoload -Uz add-zsh-hook

# Add hooks for mounting and unmounting av projects
add-zsh-hook chpwd chpwd_update_av_vars
add-zsh-hook precmd precmd_update_av_vars
add-zsh-hook preexec preexec_update_av_vars

function precmd_update_av_vars() {
    # Always run in tmux panes to handle environment inheritance
    if [[ -n "${TMUX}" ]]; then
        update_current_av_vars
        export __AV_INITIALIZED=1
    elif [[ -z "${__AV_INITIALIZED}" ]]; then
        update_current_av_vars
        export __AV_INITIALIZED=1
    fi
}

# when we change working directory mount or unmount av
function chpwd_update_av_vars() {
    update_current_av_vars
}

# when a command is about to be executed, check if we need to initialize av
function preexec_update_av_vars() {
    # Only run if not initialized yet (first command in new shell)
    if [[ -z "${__AV_INITIALIZED}" ]]; then
        update_current_av_vars
        export __AV_INITIALIZED=1
    fi
}

# Check if current directory is in or below an av project that we have mounted
function update_current_av_vars() {
    unset __CURRENT_AV_STATUS

    _AV_STATUS="$("${AV_COMMAND}" status 2>/dev/null)"
    if [ ! -z "${_AV_STATUS}" ]; then

        # We are in an av project directory
        __CURRENT_AV_STATUS="av"

        # Check if we have mounted this project and isn't already activated
        if [[ "${AV_ROOT}" != "${_AV_STATUS}" ]]; then

            # Unmount existing
            if [[ ! -z "${AV_ROOT}" ]]; then
                source <("${AV_COMMAND}" deactivate 2>/dev/null)
            fi
            
            # Mount the project
            export AV_OLD_SYSTEM_PATH="${PATH}"
            source <("${AV_COMMAND}" activate 2>/dev/null)
        fi

    elif [ ! -z "${AV_ROOT}" ]; then
        # We are NOT in an av project directory
        source <("${AV_COMMAND}" deactivate 2>/dev/null)
    fi
}

# Wrap prompt mods for zsh
function av_prompt_info() {
    if [ ! -z "${__CURRENT_AV_STATUS}" ] && command -v av_project_prompt_inputs >/dev/null 2>&1; then
        echo -e -n "%{$fg_bold[blue]%}av:(%{$fg_bold[green]%}$(av_project_prompt_inputs)%{$fg_bold[blue]%})%{$reset_color%} "
    fi
}

# Override av command with this plugin
function av() {

    # If no args, launch interactive
    if [[ $# -eq 0 ]]; then
        source <("${AV_COMMAND}" deactivate)
        "${AV_COMMAND}"
        if [[ ! -z "$(which refresh | grep -v "not found")" ]]; then
            refresh
        fi
        return $?
    fi

    # Support av-shell global commands without a mounted av project
    if [[ "$1" == "init" || "$1" == "upgrade" || "$1" == "get" || "$1" == "status" ]]; then
        "${AV_COMMAND}" "$@"
        return $?
    fi

    # When we have mounted and activated av, pass through
    if [[ ! -z "${__CURRENT_AV_STATUS}" && -z "${AV_ROOT}" ]]; then
        shift
        "${AV_COMMAND}" "$@"
        if [[ ! -z "$(which refresh | grep -v "not found")" ]]; then
            refresh
        fi
        return $?
    fi

    # Display error when not in av project
    if [[ "$1" == "activate" || "$1" == "deactivate" ]]; then
        echo "$fg_bold[yellow]You must be in an av-shell enabled project to run this command$reset_color"
        return 1
    fi
}
