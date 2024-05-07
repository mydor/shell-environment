#!/bin/bash  # not for execution, but vim syntax hinting
#

declare -a PROMPT_PRE  # Paranoid precaution

PROMPT_PRE+=("_prompt_git")

### ### PS1='\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
### [ -v 'ORIGPS1' ] || export ORIGPS1="${PS1}"
### 
### # Ansi color code variables
### reset="\[\e[0m\]"
### fgBlack="\[\e[30m\]"
### fgRed="\[\e[31m\]"
### fgGreen="\[\e[32m\]"
### fgYellow="\[\e[33m\]"
### fgBlue="\[\e[34m\]"
### fgMagenta="\[\e[35m\]"
### fgCyan="\[\e[36m\]"
### fgWhite="\[\e[37m\]"
### fgBrBlack="\[\e[90m\]"
### fgBrRed="\[\e[91m\]"
### fgBrGreen="\[\e[92m\]"
### fgBrYellow="\[\e[93m\]"
### fgBrBlue="\[\e[94m\]"
### fgBrMagenta="\[\e[95m\]"
### fgBrCyan="\[\e[96m\]"
### fgBrWhite="\[\e[97m\]"
### bgBlack="\[\e[40m\]"
### bgRed="\[\e[41m\]"
### bgGreen="\[\e[42m\]"
### bgYellow="\[\e[43m\]"
### bgBlue="\[\e[44m\]"
### bgMagenta="\[\e[45m\]"
### bgCyan="\[\e[46m\]"
### bgWhite="\[\e[47m\]"
### bgBrBlack="\[\e[100m\]"
### bgBrRed="\[\e[101m\]"
### bgBrGreen="\[\e[102m\]"
### bgBrYellow="\[\e[103m\]"
### bgBrBlue="\[\e[104m\]"
### bgBrMagenta="\[\e[105m\]"
### bgBrCyan="\[\e[106m\]"
### bgBrWhite="\[\e[107m\]"

unset -f __get_fetch
__git_fetch () {
    # echo "DEBUG: __git_fetch" >&2
    local NOW=$(date +%s)

    if [ "$1" == "-f" ] || [ ! -v LAST_GIT_FETCH ] || [ $((NOW - LAST_GIT_FETCH)) -gt 300 ]; then
      #echo "DEBUG: get_fetch $@"

      # GitHub has a bad habbit of returning from multiple IPs, pissing off ssh
      # So, we turn of HostKey checking on fetch
      GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no" git fetch
      LAST_GIT_FETCH=$NOW
    fi
}

unset -f __git_path
__git_path () {
    # echo "DEBUG: __git_path" >&2
    local _GIT_REPO_PREV=$_GIT_REPO
    git status >/dev/null 2>&1
    local _RC=$?
    _GIT_REPO=$(__git_repo)

    if [ ! -z "$_GIT_REPO" ]; then 
        if [ -z $_GIT_REPO_PREV ] || [ "$_GIT_REPO_PREV" != "$_GIT_REPO" ]; then
            __git_fetch -f
        fi
    else
        unset LAST_GIT_FETCH
    fi

    return $_RC
}

unset -f __git_up_to_date
__git_up_to_date () {
    # echo "DEBUG: __git_up_to_date" >&2
    git status | grep -qs '^Your branch is up to date with'
    return $?
}

unset -f __git_untracked
__git_untracked () {
    # echo "DEBUG: __git_untracked" >&2
    git status | grep -qs '^Untracked files:'
    return $?
}

unset -f __git_diff
__git_diff () {
    # echo "DEBUG: __git_diff" >&2
    git diff --quiet
    return $?
}

unset -f __git_repo
__git_repo () {
    # echo "DEBUG: __git_repo" >&2
    git remote -v 2>/dev/null | sed '/^origin.*fetch/!d; s/^.*[ 	]\(.*:.*\) .*$/\1/;'
}

_prompt_git () {
    __git_path || return 0

    local BRANCHCOLOR
    local REPOCOLOR

    __git_fetch 

    __git_up_to_date && REPOCOLOR="$(color -p bgt_green)" || REPOCOLOR="$(color -p fg_black bg_bgt_red)"

    __git_diff && BRANCHCOLOR="$(color -p bgt_green)" || BRANCHCOLOR="$(color -p bgt_yellow)"
    __git_untracked && BRANCHCOLOR+="$(color -p bg_bgt_black)"

    local GITREPO="${REPOCOLOR}$(__git_repo)$(color -p reset)"
    local GITBRANCH="${BRANCHCOLOR}$(git rev-parse --abbrev-ref HEAD) ($(git rev-parse --short HEAD))$(color -p reset)"

    # Note command substitution STRIPS ALL trailing newlines
    # Adding "<EOL>" to the end of the string, will get removed by the calling function
    echo -en "\n-----------------------------\nGit Repo: ${GITREPO}\nGit Branch: ${GITBRANCH}\n<EOL>"
}

### unset -f prompt_dyn
### prompt_dyn () {
###     ### [ -v DYN_PROMPT_OFF ] && return
### 
###     ### [ -v E ] && bf_env="[${fgBrYellow}$E${reset}] " || unset bf_env
###     ### vpn_on && VPN="(${fgBrGreen}VPN${reset}) " || VPN="(\e[30;101mVPN${reset}) "
### 
###     ### PS1="\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}${VPN}${bf_env}\u@\h:\w\$ "
### 
###     if git_path; then
###         git_fetch
### 
###         # Set repo color if we are behind upstream
###         git_up_to_date && REPOCOLOR="${fgBrGreen}" || REPOCOLOR="\[\e[30;101m\]"
### 
###         # Set branch color if we have uncommitted changes
###         [ $(git diff 2>/dev/null | wc -l) -eq 0 ] && BRANCHCOLOR="${fgBrGreen}" || BRANCHCOLOR="${fgBrYellow}"
### 
###         git_untracked && BRANCHCOLOR="${BRANCHCOLOR}${bgBrBlack}"
### 
###         #GITREPO="${REPOCOLOR}$(git remote -v | sed '/^origin.*fetch/!d; s/^.*[ 	]\(.*:.*\) .*$/\1/;')${reset}"
###         GITREPO="${REPOCOLOR}$(git_repo)${reset}"
###         ### GITBRANCH="${BRANCHCOLOR}$(git status 2>/dev/null | sed '/^On branch/!d; s/^On branch //;')${reset}"
###         GITBRANCH="${BRANCHCOLOR}$(git rev-parse --abbrev-ref HEAD) ($(git rev-parse --short HEAD))${reset}"
### 
###         PS1="\n-----------------------------\nGit Repo: $GITREPO\nGit Branch: $GITBRANCH\n$PS1"
### 
###         unset -v REPOCOLOR BRANCHCOLOR GITREPO GITBRANCH _VPN_INT
###     fi
### }
### PROMPT_COMMAND="prompt_dyn"
