#!/usr/bin/env bash
# Dotfiles and environment variables repository.
# @file The shell profile configuration script for bash.
# @author Rodrigo Siqueira <me@rodriados.com>
# @copyright 2026-present Rodrigo Siqueira

export PATH="$PATH:$HOME/bin:$HOME/.local/bin"

# Load the bash dotfiles, and then some:
# * ~/.bash_path can be used to extend `$PATH`.
# * ~/.bash_extra can be used for other settings you don’t want to commit.
for file in ~/.bash_{path,options,prompt,exports,functions,aliases,extra}; do
  [ -r "$file" ] && [ -f "$file" ] && source "$file"
done
unset file

# Add tab completion for many bash commands.
if [ -f /etc/bash_completion ]; then
  source /etc/bash_completion
fi

# Enable tab completion for `g` by marking it as an alias for `git`.
if type _git &> /dev/null; then
  complete -o default -o nospace -F _git g
fi

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards.
if [ -e "$HOME/.ssh/config" ]; then
  complete        \
    -o "default"  \
    -o "nospace"  \
    -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh
fi

# Include local profile configuration.
if [ -f ~/.bash_profile.local ]; then
  source ~/.bash_profile.local
fi
