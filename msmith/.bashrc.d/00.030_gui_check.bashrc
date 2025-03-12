unset -f isGUI
isGUI () {
    [[ -n "${XDG_CURRENT_DESKTOP}" ]] || return 1
    return 0
}
