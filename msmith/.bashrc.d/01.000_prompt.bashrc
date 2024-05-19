#!/bin/bash  # not for execution, but vim syntax hinting
#

declare -a PROMPT_PRE

PROMPT_COMMAND=__prompt_command

__ORIGPS1="${__ORIGPS1:=${PS1}}"
__PROMPT_EOL="<EOL>"

__prompt_register () {
    # Check if we're already processing prompt module
    [[ ${PROMPT_PRE[@]} =~ (^|[[:space:]])"$1"($|[[:space:]]) ]] && return 0

    PROMPT_PRE+=($1)
}

__prompt_eol () {
    # common interface to add defined end-of-line to string
    printf "${1}${__PROMPT_EOL}"
}

prompt_on () {
    unset __DYN_PROMPT_OFF
}

prompt_off () {
    PS1="${__ORIGPS1}"
    __DYN_PROMPT_OFF=""
}

__prompt_command () {
    local PROMPT_EXIT="$?"

    [ -v __DYN_PROMPT_OFF ] && return

    trap "" SIGTSTP

    local STATUS
    local i

    for i in ${!PROMPT_PRE[@]}; do
        STATUS+="$(${PROMPT_PRE[$i]})"

        # Since command substitution STRIPS ALL trailing newlines, have to append something after the newlines,
        # that then is stripped of the end; "<EOL>" works and is semi-logical
        STATUS="${STATUS%${__PROMPT_EOL}}"
    done

    PS1="${STATUS}\\[\\e]0;\u@\h: \w\a\\]\${debian_chroot:+(\$debian_chroot)}\\[\\033[01;32m\\]\u@\h\\[\\033[00m\\]:\\[\\033[01;34m\\]\w\\[\\033[00m\\]\$ "

    trap - SIGTSTP
}

