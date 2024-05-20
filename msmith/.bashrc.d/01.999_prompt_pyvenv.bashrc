#!/bin/bash

# Register this callback to prepend to the prompt
__prompt_register '__prompt_pyvenv'

__prompt_pyvenv () {
    declare -p VIRTUAL_ENV &>/dev/null || return

    sed '/^prompt/!d;'"s/^.* '/(PyVenv: /; s/'.*$/) /;" "${VIRTUAL_ENV}/pyvenv.cfg"
}
