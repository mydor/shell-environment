# .bash_aliases

# User specific aliases and functions
unalias master &>/dev/null
alias master="screen -e^Tt -x -R -S master"

return $?

