#!/usr/bin/env bash
# Dotfiles and environment variables repository.
# @file The shell profile configuration script for bash.
# @author Rodrigo Siqueira <me@rodriados.com>
# @copyright 2026-present Rodrigo Siqueira

if [ -n "$BASH_VERSION" ]; then
  if [ -f "$HOME/.bashrc" ]; then
    source "$HOME/.bashrc"
  fi
fi

source-if-exists "$HOME/.bash_profile.local"
