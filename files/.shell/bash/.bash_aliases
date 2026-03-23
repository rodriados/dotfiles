#!/usr/bin/env bash
# Dotfiles and environment variables repository.
# @file The aliases file for bash.
# @author Rodrigo Siqueira <me@rodriados.com>
# @copyright 2026-present Rodrigo Siqueira

# Include the common shell aliases.
if [ -f ~/.shell/aliases.sh ]; then
  source ~/.shell/aliases.sh
fi

# Include local bash aliases.
if [ -f ~/.bash_aliases.local ]; then
  source ~/.bash_aliases.local
fi
