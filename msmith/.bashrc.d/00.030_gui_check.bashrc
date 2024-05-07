unset -f isGUI
isGUI () {
    local desktop
    desktop=$(printenv XDG_CURRENT_DESKTOP)
    [ -z "$desktop" ] && return 1 || return 0
}
