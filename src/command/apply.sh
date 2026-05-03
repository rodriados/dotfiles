#!/usr/bin/env bash
# Dotfiles and environment variables repository.
# @file The dotfiles apply utility tool.
# @author Rodrigo Siqueira <me@rodriados.com>
# @copyright 2026-present Rodrigo Siqueira
set -e

DATE="$(date +%Y%m%d%H%M%S)"

readonly DATE
readonly DESTROOT="$HOME"
readonly FILEROOT="$SOURCEROOT/files"
readonly FILENAME="dotfilelist"

readonly CACHEPATH="$HOME/.local/share/dotfiles/cache"
readonly BACKUPPATH="$CACHEPATH/$DATE"
readonly REPORTFILE="$CACHEPATH/report.txt"

# Sequentially apply the requested list of file groups. If any of the given groups
# is unknown, then no changes are performed to the system.
# @param $@ The list of file groups to be applied to the system.
apply() {
  if verify "$@";
    then runfile "$@"
    else exit $?
  fi
}

# Verify whether all given file groups are known in the repository.
# @param $@ The list of file groups to verify if known.
# @return Are all file groups in the list known?
verify() {
  for group in "$@"; do
    if [[ ! -f "$FILEROOT/$group/$FILENAME" ]]; then
      echo "Unknown group cannot be applied: '$group'." >&2
      return 1
    fi
  done
}

# Sequentially execute the commands in the given file groups. If a command fails
# to parse correctly, it is ignored and execution continues normally.
# @param $@ The list of file groups to be applied to the system.
runfile() {
  for group in "$@"; do
    while read -r command; do
      if [[ -n "$command" ]]; then
        if ! runcommand "$group" "$command" 2> /dev/null; then
          echo "Ignored invalid command: '$command'" >&2
        fi
      fi
    done < "$FILEROOT/$group/$FILENAME"
  done
}

# Execute the condition validation required by a command. If an unknown condition
# is found, then the validation silently fails and presents no errors.
# @param $1 The condition to be validated.
runcondition() {
  case "$1" in
    linux  ) uname -s | grep -q "Linux"                     ;;
    darwin ) uname -s | grep -q "Darwin"                    ;;
    bash   ) echo "$SHELL" | grep -q "bash"                 ;;
    zsh    ) echo "$SHELL" | grep -q "zsh"                  ;;
    always ) return 0                                       ;;
    *      ) return 1                                       ;;
  esac
}

# Install a file into the user's home directory according to the given command.
# @param $1 The group of the target file to be applied by the command.
# @param $2 The command line to execute and apply to the system.
runcommand() {
  set -o pipefail
  echo "$2" | xargs -n 1 | {
    # Each parameter of the command will be read as a line from stdin. We must read
    # each line and validate there's no remaining input to be read in the end. In
    # case any of the required parameters fail to be read, or there is outstanding
    # input at the end, then bail out.
    read -r command   || return 1
    read -r condition || return 1
    read -r from      || return 1
    read -r dest      || return 1
    read -r keeplocal || true
    [[ -z "$(cat)" ]] || return 1

    # Run command according to the parsed parameters. The source and destination
    # files are treated by their respective absolute paths, according to the path
    # where this repository is installed and the user's home directory.
    if runcondition "$condition"; then
      local from="$FILEROOT/$1/$from"
      local dest="$DESTROOT/$dest"

      [[ -f "$from" ]] || return 1

      case "$command" in
        link ) linkfile "$from" "$dest" "$keeplocal"        ;;
        copy ) copyfile "$from" "$dest" "$keeplocal"        ;;
        *    ) return 1                                     ;;
      esac
    fi
  }
}

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
  if [[ -n "$DOTFILES_DRYRUN_ARGUMENT" ]];
    then echo "$1 $format"
    else
      prepare "$REPORTFILE"
      echo "$DATE $1 $format" | tee -a "$REPORTFILE"
  fi
}

# Check for file conflict and decide to backup it or create a local copy instead.
# @param $2 The action destination file path.
# @param $3 The keep-local configuration flag.
keeplocal() {
  if [[ -L "$2" || -e "$2" ]]; then
    if [[ "$3" == "keeplocal" ]];
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
    if [[ -z "$DOTFILES_DRYRUN_ARGUMENT" ]]; then
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
  if [[ ! "$1" -ef "$2" ]]; then
    keeplocal "$@"
    report link "$@"
    if [[ -z "$DOTFILES_DRYRUN_ARGUMENT" ]]; then
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
  if [[ ! "$1" -ef "$2" ]]; then
    keeplocal "$@"
    report move "$@"
    if [[ -z "$DOTFILES_DRYRUN_ARGUMENT" ]]; then
      prepare "$2"
      mv "$1" "$2"
    fi
  fi
}

# Back-up a file to the installation cache directory.
# @param $1 The source file to be backed-up.
backupfile() {
  report backup "$@"
  if [[ -z "$DOTFILES_DRYRUN_ARGUMENT" ]]; then
    mkdir -p "$BACKUPPATH"
    mv "$1" "$BACKUPPATH/"
  fi
}

# Show a help message to the user and terminate script execution.
# @param $@ The optional command to get help message for.
runhelp() {
  echo "Usage: dotfiles apply [options] [group ...]"
  echo
  echo "Install dotfiles from the repository."
  echo
  echo "Arguments:"
  echo "  group             Group of files to install."
  echo "                    By default, all known groups are installed."
  echo
  echo "Options:"
  echo "  -d, --dry-run     Run in dry-run mode and makes no changes."
  echo "  -h, --help        Display this help message and exit."
}

# Interpret the command line arguments. We assume that every positional argument
# is the name of a file that must be applied to the system.
while [ $# -gt 0 ]; do
  case "$1" in
    -h | --help | help ) runhelp "$@"; exit 2                   ;;
    -d | --dry-run     ) DOTFILES_DRYRUN_ARGUMENT="$1";   shift ;;
    *                  ) DOTFILES_APPLY_FILELIST+=("$1"); shift ;;
  esac
done

# Inform the user whether the script is currently running in dry-mode. If the dry-mode
# is activated, then no changes will be performed to the system. Otherwise, inform
# the current installation id, so the user can keep track of it in the report.
if [[ -n "$DOTFILES_DRYRUN_ARGUMENT" ]];
  then echo "Running in dry-run mode."
  else echo "Installation id: $DATE"
fi

# Apply the list of file groups from command line into the system. If no group is
# given by the user through the command line, then all file groups present in the
# repository will be installed into the system.
if [[ ${#DOTFILES_APPLY_FILELIST[@]} -eq 0 ]]; then
  while read -r group; do
    DOTFILES_APPLY_FILELIST+=("${group##*/}")
  done < <(find "$FILEROOT" -maxdepth 1 -mindepth 1 -type d)
fi

apply "${DOTFILES_APPLY_FILELIST[@]}"
