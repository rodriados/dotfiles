#!/usr/bin/env bash
# Dotfiles and environment variables repository.
# @file The dotfiles utility tools help manager.
# @author Rodrigo Siqueira <me@rodriados.com>
# @copyright 2026-present Rodrigo Siqueira
set -e

readonly DOTFILES_HELP_DIRECTORY="$SCRIPTPATH/command/help"
readonly DOTFILES_HELP_FILE="$DOTFILES_HELP_DIRECTORY/$DOTFILES_COMMAND_ARGUMENT.txt"
readonly DOTFILES_HELP_DEFAULT="$DOTFILES_HELP_DIRECTORY/default.txt"

# Show the help message for the provided command into the console. If no command
# is given, or it is unknown, the default help message is shown instead.
if [ -f "$DOTFILES_HELP_FILE" ];
  then cat "$DOTFILES_HELP_FILE"
  else cat "$DOTFILES_HELP_DEFAULT"
fi
