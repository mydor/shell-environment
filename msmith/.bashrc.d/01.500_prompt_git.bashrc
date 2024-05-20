#!/bin/bash

declare -i __LAST_GIT_FETCH
declare -a PROMPT_PRE  # Paranoid precaution

# Register this callback to prepend to the prompt
__prompt_register '__prompt_git'


__git_fetch () {
    # printf "DEBUG: __git_fetch\n" >&2
    local NOW=$(date +%s)

    if [ "$1" == "-f" ] || [ ! -n "${__LAST_GIT_FETCH}" ] || [ $((NOW - __LAST_GIT_FETCH)) -gt 300 ]; then

      # GitHub has a bad habbit of returning from multiple IPs, pissing off ssh
      # So, we turn of HostKey checking on fetch
      GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no" git fetch |& grep -v -e 'Warning.*host key' -e 'known_hosts' >&2
      __LAST_GIT_FETCH=$NOW
    fi
}

__git_path () {
    # printf "DEBUG: __git_path\n" >&2
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
    # printf "DEBUG: __git_up_to_date\n" >&2
    git status | grep -qs '^Your branch is up to date with'
    return $?
}

__git_untracked () {
    # printf "DEBUG: __git_untracked\n" >&2
    git status | grep -qs '^Untracked files:'
    return $?
}

__git_uncommitted () {
    # printf "DEBUG: __git_uncommitted\n" >&2
    git status | grep -qs '^Changes to be committed:'
    return $?
}

__git_ahead () {
    # printf "DEBUG: __git_ahead\n" >&2
    local status

    # Don't assign on local, as it messes up the exit code check
    status=$(git status | grep -s '^Your branch is ahead') || return 1

    sed 's/^.* by \([[:digit:]]*\) commits.*$/\1/' <<<$status
}

__git_behind () {
    # printf "DEBUG: __git_behind\n" >&2
    local status

    # Don't assign on local, as it messes up the exit code check
    status=$(git status | grep -s '^Your branch is behind') || return 1

    sed 's/^.* by \([[:digit:]]*\) commits.*$/\1/' <<<$status
}

__git_stash () {
    git stash list
}

__git_diff () {
    # printf "DEBUG: __git_diff\n" >&2
    git diff --quiet
    return $?
}

__git_repo () {
    # printf "DEBUG: __git_repo\n" >&2
    git remote -v 2>/dev/null | sed '/^origin.*fetch/!d; s/^.*[ 	]\(.*:.*\) .*$/\1/;'
}

__prompt_git () {
    __git_path || return 0

    local BRANCHCOLOR="$(color -p bgt_green)"
    local REPOCOLOR="$(color -p bgt_green)"
    local gitahead
    local gitbehind
    declare -a GITSTATUS

    __git_fetch 

    __git_up_to_date || REPOCOLOR="$(color -p fg_black bg_bgt_red)" #$(color -p bg_bgt_red)" GITSTATUS+=("$(color -p fg_black bg_bgt_red)ahead/behind$(color -p reset)")

    local GITREPO="${REPOCOLOR}$(__git_repo)$(color -p reset)"

    __git_diff || BRANCHCOLOR="$(color -p bgt_yellow)" GITSTATUS+=("$(color -p bgt_yellow)changes$(color -p reset)")
    __git_uncommitted && BRANCHCOLOR="$(color -p bgt_red)" GITSTATUS+=("$(color -p blink bgt_red)uncommitted$(color -p reset)")
    __git_untracked && BRANCHCOLOR+="$(color -p bg_bgt_black)" GITSTATUS+=("$(color -p bg_bgt_black)untracked$(color -p reset)")

    local GITBRANCH="${BRANCHCOLOR}$(git rev-parse --abbrev-ref HEAD) ($(git rev-parse --short HEAD))$(color -p reset)"

    # Don't assign on top of local, as it messes up the exit code check
    # Exit code becomes that of 'local` not the sub-shell
    gitbehind=$(__git_behind) && GITSTATUS+=("$(color -p bgt_red)behind(${gitbehind})$(color -p reset)")
    gitahead=$(__git_ahead)   && GITSTATUS+=("$(color -p bgt_yellow)ahead(${gitahead})$(color -p reset)")

    # Note command substitution STRIPS ALL trailing newlines
    # Adding "<EOL>" to the end of the string, will get removed by the calling function
    __prompt_eol "\n-----------------------------\nGit Repo: ${GITREPO}\nGit Branch: ${GITBRANCH}\nGit Status: ${GITSTATUS[*]}\n"
}
