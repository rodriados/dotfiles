#!/usr/bin/env bash
# Dotfiles and environment variables repository.
# @file The dotfiles git utility tool.
# @author Rodrigo Siqueira <me@rodriados.com>
# @copyright 2026-present Rodrigo Siqueira
set -e

declare -rx DOTFILES_GIT_COMMAND_ARGUMENT="$1"

# Runs a git command in the dotfile repository root.
# @param $@ The git command and arguments to run in the dotfile repository.
rungit() {
  exec git -C "$SOURCEROOT" "$@"
}

# Show a help message to the user and terminate script execution.
# @param $@ The optional command to get help message for.
runhelp() {
  echo "Usage: dotfiles git [command] [args ...]"
  echo
  echo "Executes git in the dotfile repository."
  echo
  echo "Commands:"
  echo "  [git-command]     All commands are passed directly to git."
  echo "  --                Bypass dotfile git command line evaluation."
  echo
  echo "Options:"
  echo "  -h, --help        Display this help message and exit."
}

# Execute the selected function from the remaining command line arguments. If the
# selected function is unknown, it is passed directly, as-is, to git.
case "$DOTFILES_GIT_COMMAND_ARGUMENT" in
  -h | --help | help ) runhelp "$@"; exit 2 ;;
  --                 ) rungit "${@:2}"      ;;
  *                  ) rungit "$@"          ;;
esac
