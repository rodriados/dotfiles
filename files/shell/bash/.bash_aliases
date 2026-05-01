#!/usr/bin/env bash
# Dotfiles and environment variables repository.
# @file The aliases file for bash.
# @author Rodrigo Siqueira <me@rodriados.com>
# @copyright 2026-present Rodrigo Siqueira

source-if-exists "$HOME/.config/dotfiles/shell/aliases.sh"
source-if-exists "$HOME/.bash_aliases.local"
