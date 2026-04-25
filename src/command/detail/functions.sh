#!/usr/bin/env bash
# Dotfiles and environment variables repository.
# @file The functions for setting up dotfiles into the system.
# @author Rodrigo Siqueira <me@rodriados.com>
# @copyright 2026-present Rodrigo Siqueira
DATE="$(date +%Y%m%d%H%M%S)"

readonly DATE
readonly CACHEPATH="$SOURCEROOT/.cache"
readonly BACKUPPATH="$CACHEPATH/$DATE"
readonly REPORTFILE="$CACHEPATH/report.txt"

# Public variable to be set when functions must be executed in dry-run mode. When
# set, functions that cause changes in the system will only report but not run.
declare -x DOTFILES_DRYRUN_ARGUMENT

# Prepare execution by creating the required directories for an action.
# @param $1 The name of the file that will be created.
prepare() {
  mkdir -p "$(dirname "$1")"
}

# Log an action by appending the action description in the report file.
# @param $1 The action type to report.
# @param $2 The action source file path.
# @param $3 The action destination file path.
report() {
  local format
  format=$(printf '"%s" ' "${@:2:2}")
  if [ ! -z "$DOTFILES_DRYRUN_ARGUMENT" ];
    then echo "$1 $format"
    else
      prepare "$REPORTFILE"
      echo "$DATE $1 $format" >> "$REPORTFILE"
  fi
}

# Check for file conflict and decide to backup it or create a local copy instead.
# @param $2 The action destination file path.
# @param $3 The keep-local configuration flag.
keeplocal() {
  if [ -L "$2" ] || [ -e "$2" ]; then
    if [ "$3" == "keeplocal" ];
      then movefile "$2" "$2.local"
      else backupfile "$2"
    fi
  fi
}

# Copy a file when it is not yet present at the destination.
# @param $1 The source file to be copied.
# @param $2 The destination path to copy the file to.
# @param $3 The keep-local configuration flag.
copyfile() {
  if ! diff -rq "$1" "$2" >/dev/null 2>&1; then
    keeplocal "$@"
    report copy "$@"
    if [ -z "$DOTFILES_DRYRUN_ARGUMENT" ]; then
      prepare "$2"
      cp "$1" "$2"
    fi
  fi
}

# Create a symbolic link for a file when it is not linked at the destination.
# @param $1 The source file to be linked.
# @param $2 The destination path to link the file to.
# @param $3 The keep-local configuration flag.
linkfile() {
  if [ ! "$1" -ef "$2" ]; then
    keeplocal "$@"
    report link "$@"
    if [ -z "$DOTFILES_DRYRUN_ARGUMENT" ]; then
      prepare "$2"
      ln -s "$1" "$2"
    fi
  fi
}

# Move a file when it is not yet present at the destination.
# @param $1 The source file to be moved.
# @param $2 The destination path to move the file to.
# @param $3 The keep-local configuration flag.
movefile() {
  if [ ! "$1" -ef "$2" ]; then
    keeplocal "$@"
    report move "$@"
    if [ -z "$DOTFILES_DRYRUN_ARGUMENT" ]; then
      prepare "$2"
      mv "$1" "$2"
    fi
  fi
}

# Back-up a file to the installation cache directory.
# @param $1 The source file to be backed-up.
backupfile() {
  report backup "$@"
  if [ -z "$DOTFILES_DRYRUN_ARGUMENT" ]; then
    mkdir -p "$BACKUPPATH"
    mv "$1" "$BACKUPPATH/"
  fi
}
