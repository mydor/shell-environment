# .bash_aliases

# User specific aliases and functions
if [ -d ~/steam-keys ] && [ -d ~/steam-keys/v2 ]
then
    alias steamkeys="cd ~/steam-keys/v2"
    alias steam_keys="cd ~/steam-keys/v2"
    alias steam-keys="cd ~/steam-keys/v2"
else
    unalias steamkeys steam_keys steam-keys &>/dev/null
fi

return 0
return $?

