#!/bin/bash  # not for execution, but vim syntax hinting
#

declare -a PROMPT_PRE  # Paranoid precaution

# Register this callback to prepend to the prompt
__prompt_register '__prompt_exit_status'

__prompt_exit_status () {
    local CHECK XMARK SKULL SLEEP ABORT

    #                 ✔               ✘               ☠               😴              🛑
    _hasUTF8 && CHECK=$'\u2714' XMARK=$'\u2718' SKULL=$'\u2620' SLEEP=$'\U1F634' ABORT=$'\U1f6d1' \
             || CHECK=' OK '    XMARK='FAIL'    SKULL='DEAD'    SLEEP='SUSPEND'  ABORT='ABRT'

    local CHECKMARK="$(color -p bold green )${CHECK}"
    local FAILMARK="$( color -p bold red   )${XMARK}"
    local SLEEPMARK="$(color -p bold yellow)${SLEEP}"
    local ABORTMARK="$(color -p bold red   )${ABORT}"

    local STATUS

    # PROMPT_EXIT is set in 01.000_prompt.sh, so not need to scope it
    case $PROMPT_EXIT in
        "0")
           STATUS=$CHECKMARK
           ;;
        "130")
           STATUS=$ABORTMARK
           ;;
        "148")
           STATUS=$SLEEPMARK
           ;;
        *)
           STATUS=$FAILMARK
           ;;
    esac
    STATUS+="$(color -p reset)($PROMPT_EXIT) "

    __prompt_eol "${STATUS}"
}
