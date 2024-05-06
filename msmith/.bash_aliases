if [ -f ~/.bash_header ]; then
    source ~/.bash_header || return $?
fi

# Do this here since this is what actually loads the color function
COLOR_RED=$'\e[1;31m'
COLOR_GREEN=$'\e[1;32m'
COLOR_YELLOW=$'\e[1;33m'
COLOR_RESET=$'\e[0m'

if [ -d "${BASH_SOURCE[0]}.d" ]; then
    OLDIFS="${IFS}" IFS=''
    for i in "${BASH_SOURCE[0]}.d/"*.sh; do
        echo -n "Loading alias ${COLOR_YELLOW}${i}${COLOR_RESET}: "
        source "$i" > /tmp/$$.out 2> /tmp/$$.err && false
        if [ $? -gt 0 ]; then
            echo "${COLOR_RED}ERROR${COLOR_RESET}"
            for x in out err; do
                [ $x == out ] && logcolor="${COLOR_YELLOW}" || logcolor="${COLOR_RED}"
                echo "------------- ${logcolor}std${x}${COLOR_RESET} -------------"
                cat /tmp/$$.$x
                rm -f /tmp/$$.$x
            done
            unset logcolor
        else
            echo "${COLOR_GREEN}OK${COLOR_RESET}"
        fi
    done
    echo
    IFS="${OLDIFS}"
fi

unset COLOR_RED COLOR_GREEN COLOR_YELLOW COLOR_RESET OLDIFS

if [ -f ~/.bash_footer ]; then
    source ~/.bash_footer
fi
