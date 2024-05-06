#!/bin/bash  # not for execution, but vim syntax hinting
#

declare -a PROMPT_PRE

PROMPT_COMMAND=__prompt_command

__prompt_command() {
    local PROMPT_EXIT="$?"

    ### ### # Colors, USE Non-print escaping!  \[ ... \]
    ### ### local  GREEN=$"\["'\033[1;32m'"\]"
    ### ### local    RED=$"\["'\033[1;31m'"\]"
    ### ### local YELLOW=$"\["'\033[1;33m'"\]"
    ### ### local  RESET=$"\["'\033[0m'"\]"

    ### # Symbols
    ### local CHECK XMARK SKULL SLEEP ABORT
    ### ### local CHECK=$'\u2714'    # ✔
    ### ### local XMARK=$'\u2718'    # ✘
    ### ### local SKULL=$'\u2620'    # ☠
    ### ### local SLEEP=$'\U1f634'   # 😴    $'\xF0\x9F\x98\xB4'  # 😴
    ### ### local ABORT=$'\U1f6d1'   # 🛑

    ### # Use words if can't show symbols
    ### _hasUTF8 && CHECK=$'\u2714' XMARK=$'\u2718' SKULL=$'\u2620' SLEEP=$'\U1F634' ABORT=$'\U1f6d1' \
    ###         || CHECK=' OK '    XMARK='FAIL'    SKULL='DEAD'    SLEEP='SUSPEND'  ABORT='ABRT'
    ### ### _hasUTF8 || CHECK=" OK " \
    ### ###            XMARK="FAIL" \
    ### ###            SLEEP="SUSPEND" \
    ### ###            ABORT="ABRT"

    ### ### local CHECKMARK="${GREEN}${CHECK}"
    ### ### local FAILMARK="${RED}${XMARK}"
    ### ### local SLEEPMARK="${YELLOW}${SLEEP}"
    ### ### local ABORTMARK="${RED}${ABORT}"

    ### local CHECKMARK="$(color -p bold green)${CHECK}"
    ### local FAILMARK="$( color -p bold red)${XMARK}"
    ### local SLEEPMARK="$(color -p bold yellow)${SLEEP}"
    ### local ABORTMARK="$(color -p bold red)${ABORT}"

    ### local STATUS
    ### STATUS+=$(__prompt_exit_status $EXIT)
    ### case $EXIT in
    ###     "0")
    ###        STATUS=$CHECKMARK
    ###        ;;
    ###     "130")
    ###        STATUS=$ABORTMARK
    ###        ;;
    ###     "148")
    ###        STATUS=$SLEEPMARK
    ###        ;;
    ###     *)
    ###        STATUS=$FAILMARK
    ###        ;;
    ### esac
    ### ### STATUS+="${RESET}($EXIT) "
    ### STATUS+="$(color -p reset)($EXIT) "

    local STATUS
    #STATUS+=$(__prompt_exit_status $EXIT)

    for i in ${!PROMPT_PRE[@]}; do
        STATUS+=$(${PROMPT_PRE[$i]})
    done

    ### PS1=${STATUS}'[\u@\h \W]\$ ' # CentOS
    PS1="${STATUS}\\[\\e]0;\u@\h: \w\a\\]\${debian_chroot:+(\$debian_chroot)}\\[\\033[01;32m\\]\u@\h\\[\\033[00m\\]:\\[\\033[01;34m\\]\w\\[\\033[00m\\]\$ "
}

