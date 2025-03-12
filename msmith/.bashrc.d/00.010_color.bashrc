#!/bin/bash

__color_help () {
    printf "color [-p] [[fg_ | bg_] [bgt_][ <color> ] ...] [[-]<decorator> ...] [reset]\n\n"
    printf "    -p Enable non-printable escaping for prompt use;   \[ ... \]\n\n"

    printf "    Color can be prepended with\n"
    printf "        fg_ for a foreground <color>    * default\n"
    printf "        bg_ for a background <color>\n"
    printf "        bgt_ for a bright <color>\n\n"

    printf "    Decorators can be prepended with a '-' to disable the effect*\n"
    printf "       * NOTE!!!: -bold and -dunderline DO NOT work right.  The only way\n"
    printf "                  to disable is to <reset> which clears all colors and decorators\n"
    printf "        Note: The code for -bold causes the dunderline\n"
    printf "        Note: There is no code for -dundereline\n\n"

    declare _bright
    declare _color
    declare _fgbg

    for _color in black red green yellow blue purple cyan gray; do
        for _fgbg in fg_ bg_; do
            for _bright in "" bgt_; do
                printf "%s%s%s " \
                    "$(color ${_fgbg}${_bright}${_color})" \
                    "${_fgbg}${_bright}${_color}" \
                    "$(color reset)"
            done
        done
        printf "\n"
    done | column -t | sed 's/^/            - /; s/       \( - [^[:space:]]*fg_black\)/<color>\1/'
    # NOTE: [^[:space:]]*  is to catch all the color escape codes
    #
    #fg_black fg_bgt_black bg_black bg_bgt_black                             # nested loop output
    #fg_black   fg_bgt_black   bg_black   bg_bgt_black                       # column -t output
    #                    - fg_black   fg_bgt_black   bg_black   bg_bgt_black # first sed pattern
    #            <color> - fg_black   fg_bgt_black   bg_black   bg_bgt_black # second sed pattern

    printf "\n"

    declare _decorator

    for _decorator in bold dim underline dunderline blink inverse hidden strike; do

        printf "%s\n" "$(color $_decorator)$_decorator$(color -$_decorator) -$_decorator"
    done | column -t | sed 's/^/                - /; s/           \( - [^[:space:]]*bold\)/<decorator>\1/'
    printf "\n"

    return 1
}

color () {
    if [[ $@ =~ (^|[[:space:]])(-h|--help)($|[[:space:]]) ]]; then
        __color_help
        return $?
    fi

    declare -a seq
    declare arg
    declare code
    declare fgbg
    declare fmt
    declare non_print

    for arg in "$@"
    do
        [[ $arg == "-"* ]] \
            && fmt="2" \
            || fmt=""
        
        [[ $arg =~ (^|_)"bg"($|_) ]] \
            && fgbg="4" \
            || fgbg="3"

        [[ $arg =~ (^|_)"bgt"($|_) ]] \
            && fgbg=$((fgbg + 6))

        case $arg in
            -p|--prompt)
                non_print=true ;;
            reset)
                code="0" ;;

            *bold)
                [[ $fmt -eq 2 ]] \
                    && code="0" \
                    || code="1" ;;
            *dim)
                code="${fmt}2" ;;
            *italic)
                code="${fmt}3" ;;
            *dunderline)
                [[ $fmt -eq 2 ]] \
                    && code="0" \
                    || code="21" ;;
            *underline)
                code="${fmt}4" ;;
            *blink)
                code="${fmt}5" ;;
            *inverse)
                code="${fmt}7" ;;
            *hidden)
                code="${fmt}8" ;;
            *strike)
                code="${fmt}9" ;;
            *black)
                code="${fgbg}0" ;;

            *red)
                code="${fgbg}1" ;;
            *green)
                code="${fgbg}2" ;;
            *yellow)
                code="${fgbg}3" ;;
            *blue)
                code="${fgbg}4" ;;
            *magenta|*purple)
                code="${fgbg}5" ;;
            *cyan)
                code="${fgbg}6" ;;
            *gray)
                code="${fgbg}7" ;;
            *default)
                code="${fgbg}0" ;;
        esac
        seq+=($code)
    done
    code=$(__color_join ';' ${seq[*]})

    [ -z "${code}" ] && return 0

    [ "$non_print" == true ] && printf $"\["
    printf $'\033'"[${code}m"
    [ "$non_print" == true ] && printf $"\]"
}

__color_join () {
    local IFS=$1 ; shift

    printf "$*"
}

