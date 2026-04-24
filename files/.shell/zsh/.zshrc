#!/usr/bin/env zsh
# Dotfiles and environment variables repository.
# @file The shell configuration script for zsh.
# @author Rodrigo Siqueira <me@rodriados.com>
# @copyright 2026-present Rodrigo Siqueira

export PATH="$PATH:$HOME/bin:$HOME/.local/bin"

# Load the zsh dotfiles, and then some:
# * ~/.zsh_path can be used to extend `$PATH`.
# * ~/.zsh_extra can be used for other settings you don’t want to commit.
for file in ~/.zsh_{path,options,prompt,exports,functions,aliases,extra}; do
  [ -r "$file" ] && [ -f "$file" ] && source "$file"
done
unset file

# Include local zsh configuration.
if [ -f ~/.zshrc.local ]; then
  source ~/.zshrc.local
fi

# Remap some key behaviors on MacOS to be consistent with Linux.
if uname | grep -q 'Darwin'; then
  bindkey "\e[H" beginning-of-line
  bindkey "\e[F" end-of-line
fi
