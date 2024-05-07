#!/bin/bash

declare -i __LAST_GIT_FETCH
declare -a PROMPT_PRE  # Paranoid precaution

# Register this callback to prepend to the prompt
__prompt_register '__prompt_git'


__git_fetch () {
    # echo "DEBUG: __git_fetch" >&2
    local NOW=$(date +%s)

    if [ "$1" == "-f" ] || [ ! -n "${__LAST_GIT_FETCH}" ] || [ $((NOW - __LAST_GIT_FETCH)) -gt 300 ]; then

      # GitHub has a bad habbit of returning from multiple IPs, pissing off ssh
      # So, we turn of HostKey checking on fetch
      GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no" git fetch |& grep -v -e 'Warning.*host key' -e 'known_hosts' >&2
      __LAST_GIT_FETCH=$NOW
    fi
}

__git_path () {
    # echo "DEBUG: __git_path" >&2
    __GIT_REPO=${__GIT_REPO:=""}
    local __GIT_REPO_PREV=$__GIT_REPO
    git status >/dev/null 2>&1
    local RC=$?
    __GIT_REPO=$(__git_repo)

    if [ ! -z "$__GIT_REPO" ]; then 
        if [ -z $__GIT_REPO_PREV ] || [ "$__GIT_REPO_PREV" != "$__GIT_REPO" ]; then
            __git_fetch -f
        fi
    else
        __LAST_GIT_FETCH=0
    fi

    return $RC
}

__git_up_to_date () {
    # echo "DEBUG: __git_up_to_date" >&2
    git status | grep -qs '^Your branch is up to date with'
    return $?
}

__git_untracked () {
    # echo "DEBUG: __git_untracked" >&2
    git status | grep -qs '^Untracked files:'
    return $?
}

__git_diff () {
    # echo "DEBUG: __git_diff" >&2
    git diff --quiet
    return $?
}

__git_repo () {
    # echo "DEBUG: __git_repo" >&2
    git remote -v 2>/dev/null | sed '/^origin.*fetch/!d; s/^.*[ 	]\(.*:.*\) .*$/\1/;'
}

__prompt_git () {
    __git_path || return 0

    local BRANCHCOLOR
    local REPOCOLOR

    __git_fetch 

    __git_up_to_date && REPOCOLOR="$(color -p bgt_green)" || REPOCOLOR="$(color -p fg_black bg_bgt_red)" #$(color -p bg_bgt_red)"

    __git_diff && BRANCHCOLOR="$(color -p bgt_green)" || BRANCHCOLOR="$(color -p bgt_yellow)"
    __git_untracked && BRANCHCOLOR+="$(color -p bg_bgt_black)"

    local GITREPO="${REPOCOLOR}$(__git_repo)$(color -p reset)"
    local GITBRANCH="${BRANCHCOLOR}$(git rev-parse --abbrev-ref HEAD) ($(git rev-parse --short HEAD))$(color -p reset)"

    # Note command substitution STRIPS ALL trailing newlines
    # Adding "<EOL>" to the end of the string, will get removed by the calling function
    __prompt_eol "\n-----------------------------\nGit Repo: ${GITREPO}\nGit Branch: ${GITBRANCH}\n"
}
