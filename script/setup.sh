#!/bin/bash
# Dotfiles and environment variables repository.
# @file The script for setting up dotfiles into the system.
# @author Rodrigo Siqueira <me@rodriados.com>
# @copyright 2026-present Rodrigo Siqueira
set -e

declare -r SCRIPTPATH=$(cd -- "$(dirname "$0")" >/dev/null 2>&1; pwd -P)
declare -r SOURCEROOT=$(cd -- "$(dirname "$SCRIPTPATH")" >/dev/null 2>&1; pwd -P)
declare -r TARGETPATH="$HOME/.local/bin"

declare -r INSTALLATION_SOURCE="$SOURCEROOT/src/dotfiles"
declare -r INSTALLATION_TARGET="$TARGETPATH/dotfiles"
declare -r REPOSITORY_UPSTREAM="$1"

export PATH="$PATH:$TARGETPATH"

# If the target installation path already exists on the system, we prefer to preserve
# the existing object and bail out with an installation failure message.
if [ -e "$INSTALLATION_TARGET" ]; then
  printf "Dotfiles utility is already installed."
  exit 1
fi

# If everything is alright, we can safely install the utility and immediately use
# it to install the dotfiles already listed in the repository.
ln -s $INSTALLATION_SOURCE $INSTALLATION_TARGET
chmod +x $INSTALLATION_SOURCE $INSTALLATION_TARGET
dotfiles apply $SOURCEROOT/.dotfileslist

# At last, we can configure the git upstream repository. If no repository link is
# given, then the configuration is skipped but can be manually configured later.
if [ -n "$REPOSITORY_UPSTREAM" ]; then
  dotfiles git setup $REPOSITORY_UPSTREAM
fi
