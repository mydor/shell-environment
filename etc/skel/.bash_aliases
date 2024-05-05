if [ -f ~/.bash_header ]; then
    source ~/.bash_header || return $?
fi

if [ -d "${BASH_SOURCE[0]}.d" ]; then
    ls -A "${BASH_SOURCE[0]}.d/"*.sh | while read i; do
        echo -n "Loading alias $(color brt_yellow)${i}: "
        source "$i" > /tmp/$$.out 2> /tmp/$$.err
        if [ $? -gt 0 ]; then
            echo -e "$(color red)ERROR$(color reset)"
            for x in out err; do
		[ $x == out ] && logcolor="yellow" || logcolor="red"
                [ -s /tmp/$$.$x ] || continue
		echo "------------- $(color $logcolor)std$x$(color reset) -------------"
                cat /tmp/$$.$x
            done
        else
            echo "$(color bgt_green)OK$(color reset)"
        fi
        rm -f /tmp/$$.{out,err}
    done
    echo
fi

if [ -f ~/.bash_footer ]; then
    source ~/.bash_footer
fi
