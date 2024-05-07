#!/bin/bash  # not for execution, but vim syntax hinting
#

unset -f _hashUTF8
_hasUTF8() {
    if [ $'\u2714' == '\u2714' ]; then
        return 1
    fi

    return 0
}

