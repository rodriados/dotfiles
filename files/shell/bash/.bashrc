#!/usr/bin/env bash
# Dotfiles and environment variables repository.
# @file The shell configuration script for bash.
# @author Rodrigo Siqueira <me@rodriados.com>
# @copyright 2026-present Rodrigo Siqueira
[[ -n "$PS1" ]] || return

export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

source-if-exists() {
  if [[ -f "$1" && -r "$1" ]];
    then source "$1"
  fi
}

source-if-exists "/etc/bash_completion"

source-if-exists "$HOME/.config/dotfiles/shell/globals.sh"
source-if-exists "$HOME/.bash_path"
source-if-exists "$HOME/.bash_options"
source-if-exists "$HOME/.bash_exports"
source-if-exists "$HOME/.bash_functions"
source-if-exists "$HOME/.bash_aliases"
source-if-exists "$HOME/.bash_extra"
source-if-exists "$HOME/.bash_completion"
source-if-exists "$HOME/.bash_prompt"
source-if-exists "$HOME/.bashrc.local"
