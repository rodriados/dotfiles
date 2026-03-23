#!/usr/bin/env zsh
# Dotfiles and environment variables repository.
# @file The shell profile configuration script for zsh.
# @author Rodrigo Siqueira <me@rodriados.com>
# @copyright 2026-present Rodrigo Siqueira

# Load the zsh dotfiles, and then some:
# * ~/.zsh_path can be used to extend `$PATH`.
# * ~/.zsh_extra can be used for other settings you don’t want to commit.
for file in ~/.zsh_{path,options,prompt,exports,functions,aliases,extra}; do
  [ -r "$file" ] && [ -f "$file" ] && source "$file"
done
unset file

# Include local profile configuration.
if [ -f ~/.zprofile.local ]; then
  source ~/.zprofile.local
fi
