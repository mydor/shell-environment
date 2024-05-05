if [ -f ~/.bash_header ]; then
    . ~/.bash_header || return $?
fi

unset -f isGUI
isGUI () {
    local desktop
    desktop=$(printenv XDG_CURRENT_DESKTOP)
    [ -z "$desktop" ] && return 1 || return 0
}

unset -f rackspace
rackspace () {
    deactivate &>/dev/null 
    cd ~/python/rackspace-email-management
    . env/bin/activate
    get_rs_editor
}

unset -f get_rs_editor
get_rs_editor () {
    RSEDITOR=$(grep -v '^#' .editor | head -1)
    isGUI || RSEDITOR=vim
}

unset -f rs_edit
rs_edit () {
    "${1:-$RSEDITOR}" "$2"
}

unset -f archmage
archmage () {
    rackspace
    #vim conf.d/arch-mage.com.yml
    "${1:-$RSEDITOR}" conf.d/arch-mage.com.yml
}

unset -f moonlight
moonlight () {
    rackspace
    #vim conf.d/moonlightimagery.com.yml
    "${1:-$RSEDITOR}" conf.d/moonlightimagery.com.yml
}

unset -f vscode
vscode () {
    code $1
}

if [ -f ~/.bash_footer ]; then
    . ~/.bash_footer
fi
