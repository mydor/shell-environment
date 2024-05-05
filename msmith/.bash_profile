# This is ONLY necessary if bash specific profile data is
# needed.
#
# If .bash_profile does NOT exist, bash will load .profile instead

echo ".bash_profile"

if [ -f ~/.bash_header ]; then
    . ~/.bash_header || return $?
fi

# .profile with handle .bashrc for us
[ -f ~/.profile ] && . ~/.profile

if [ -f ~/.bash_footer ]; then
    . ~/.bash_footer
fi
