#!/usr/bin/env bash
# Dotfiles and environment variables repository.
# @file The dotfiles apply utility tool.
# @author Rodrigo Siqueira <me@rodriados.com>
# @copyright 2026-present Rodrigo Siqueira
set -e

readonly DESTROOT="$HOME"
readonly FILEROOT="$SOURCEROOT/files"
readonly DEFAULTLIST="$SOURCEROOT/.dotfileslist"

source "$SCRIPTPATH/command/detail/functions.sh"

# Sequentially apply commands described in the given list of files. If any of the
# files do not exist or is unreadable, then no changes are performed to the system.
# @param $@ The list of command files to be applied to the system.
apply() {
  if verify "$@";
    then runfile "$@"
    else exit $?
  fi
}

# Verify whether all given files exist and are readable. Verification is short-circuted
# and an error message is printed when the first failing file is found.
# @param $@ The list of files to verify readability.
# @return Are all files in the list readable?
verify() {
  for file in "$@"; do
    if [ ! -f "$file" ] || [ ! -r "$file" ]; then
      echo "File '$file' does not exist or is not readable."
      echo "No changes were made to your system."
      return 1
    fi
  done
}

# Sequentially execute the commands in the given list of files. If a command fails
# to parse correctly, it is ignored and execute continues as normal.
# @param $@ The list of command files to be applied to the system.
runfile() {
  for file in "$@"; do
    while read -r command; do
      if [ ! -z "$command" ]; then
        if ! runcommand "$command" 2> /dev/null; then
          echo "Ignored invalid command: '$command'"
        fi
      fi
    done < "$file"
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
# @param $1 The command line to execute and apply to the system.
runcommand() {
  set -o pipefail
  echo "$1" | xargs -n 1 | {
    # Each parameter of the command will be read as a line from stdin. We must read
    # each line and validate there's no remaining input to be read in the end. In
    # case any of the required parameters fail to be read, or there is outstanding
    # input at the end, then bail out.
    read -r command   || return 1
    read -r condition || return 1
    read -r from      || return 1
    read -r dest      || return 1
    read -r keeplocal || true
    [ -z "$(cat)" ]   || return 1

    # Run command according to the parsed parameters. The source and destination
    # files are treated by their respective absolute paths, according to the path
    # where this repository is installed and the user's home directory.
    if runcondition "$condition"; then
      local from="$FILEROOT/$from"
      local dest="$DESTROOT/$dest"
      case "$command" in
        link ) linkfile "$from" "$dest" "$keeplocal"        ;;
        copy ) copyfile "$from" "$dest" "$keeplocal"        ;;
        *    ) return 1                                     ;;
      esac
    fi
  }
}

# Interpret the command line arguments. We assume that every positional argument
# is the name of a file that must be applied to the system.
while [ $# -gt 0 ]; do
  case "$1" in
    -d | --dry-run ) DOTFILES_DRYRUN_ARGUMENT="$1";   shift ;;
    *              ) DOTFILES_APPLY_FILELIST+=("$1"); shift ;;
  esac
done

# Inform the user whether the script is currently running in dry-mode. If the dry-mode
# is activated, then no changes will be performed to the system. Otherwise, inform
# the current installation id, so the user can keep track of it in the report.
if [ ! -z "$DOTFILES_DRYRUN_ARGUMENT" ];
  then echo "Running in dry-run mode."
  else echo "Installation id: $DATE"
fi

# Apply the list of files from command line into the system. If no files are given
# by the user in the command line, then the file present in the repository is used.
if [ ${#DOTFILES_APPLY_FILELIST[@]} -ne 0 ];
  then apply "${DOTFILES_APPLY_FILELIST[@]}"
  else apply "$DEFAULTLIST"
fi
