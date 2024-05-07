#!/bin/bash

### COLOR_RESET=$'\033[0m'
### COLOR_NOBOLD=$'\033[21m'
### COLOR_NODIM=$'\033[22m'
### COLOR_NOUNDERLINE=$'\033[24m'
### COLOR_NOBLINK=$'\033[25m'
### COLOR_NOINVERSE=$'\033[27m'
### COLOR_NOHIDDEN=$'\033[28m'
### 
### COLOR_FBLACK=$'\033[30m'
### COLOR_FRED=$'\033[31m'
### COLOR_FGREEN=$'\033[32m'
### COLOR_FYELLOW=$'\033[33m'
### COLOR_FBLUE=$'\033[34m'
### COLOR_FPURPLE=$'\033[35m'
### COLOR_FCYAN=$'\033[36m'
### COLOR_FGRAY=$'\033[37m'
### COLOR_FNORMAL=$'\033[39m'
### 
### COLOR_BBLACK=$'\033[0;40m'
### COLOR_BRED=$'\033[0;41m'
### COLOR_BGREEN=$'\033[0;42m'
### COLOR_BYELLOW=$'\033[0;43m'
### COLOR_BBLUE=$'\033[0;44m'
### COLOR_BPURPLE=$'\033[0;45m'
### COLOR_BCYAN=$'\033[0;46m'
### COLOR_BGRAY=$'\033[0;47m'
### COLOR_BNORMAL=$'\033[49m'
### 
### COLOR_BOLD=$'\033[1m'
### COLOR_DIM=$'\033[2m'
### COLOR_UNDERLINE=$'\033[4m'
### COLOR_BLINK=$'\033[5m'
### COLOR_INVERSE=$'\033[7m'
### COLOR_HIDDEN=$'\033[8m'

__color_help () {
    echo "color [-p] [[fg_ | bg_] [bgt_][ <color> ] ...] [[-]<decorator> ...] [reset]"
    echo
    echo "    -p Enable non-printable escaping for prompt use;   \[ ... \]"
    echo
    echo "    Color can be prepended with"
    echo "        fg_ for a foreground <color>    * default"
    echo "        bg_ for a background <color>"
    echo "        bgt_ for a bright <color>"
    echo 
    echo "    Decorators can be prepended with a "-" to disable the effect*"
    echo "       * NOTE!!!: -bold and -dunderline DO NOT work right.  The only way"
    echo "                  to disable is to <reset> which clears all colors and decorators"
    echo "        Note: The code for -bold causes the dunderline"
    echo "        Note: There is no code for -dundereline"
    echo

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
    declare _prefix

    for _decorator in bold dim underline dunderline blink inverse hidden strike; do
        [ "$_decorator" == "bold" ] \
            && _prefix="<decorator> -" \
            || _prefix="            -"

        printf "%s\n" "    $_prefix $(color $_decorator)$_decorator$(color -$_decorator) -$_decorator"
    done
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
            -p)
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

    [ "$non_print" == true ] && echo -en $"\["
    echo -en $'\033'"[${code}m"
    [ "$non_print" == true ] && echo -en $"\]"
}

__color_join () {
    local IFS=$1 ; shift

    printf "$*"
}

