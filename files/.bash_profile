#!/usr/bin/env bash

export PATH="$PATH:$HOME/bin:$HOME/.local/bin"

# Load the shell dotfiles, and then some:
# * ~/.bash-path can be used to extend `$PATH`.
# * ~/.bash-extra can be used for other settings you don’t want to commit.
for file in ~/.bash_{path,options,prompt,exports,functions,aliases,extra}; do
  [ -r "$file" ] && [ -f "$file" ] && source "$file"
done
unset file

# Enable some Bash 4 features when possible:
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Recursive globbing, e.g. `echo **/*.txt`
for option in autocd globstar; do
  shopt -s "$option" 2> /dev/null;
done

# Add tab completion for many Bash commands
if [ -f /etc/bash_completion ]; then
  source /etc/bash_completion
fi

# Enable tab completion for `g` by marking it as an alias for `git`
if type _git &> /dev/null; then
  complete -o default -o nospace -F _git g
fi

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && \
  complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh

if [ -f ~/.bash_profile.local ]; then
  source ~/.bash_profile.local
fi
