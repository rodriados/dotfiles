#!/bin/bash
# Dotfiles and environment variables repository.
# @file The script for bootstraping the download and installation of dotfiles.
# @author Rodrigo Siqueira <me@rodriados.com>
# @copyright 2026-present Rodrigo Siqueira
set -e

declare DOTFILES_DIRECTORY="${1:-"$HOME/.dotfiles"}"
declare GITHUB_REPOSITORY="${2:-"$(whoami)/dotfiles"}"

# Auxiliary function to bail out with a message.
# @param $1 The informative message to bail out of the script with.
# @return Never returns and kills execution.
die () {
  echo "$1" >&2
  exit 1
}

# Checks the OS that we are running on and bails out if unknown.
# Running on an unknown OS might cause potentially dangerous unexpected behavior.
if ! printf "$(uname -s)" | grep -E -q "^(Darwin|Linux)$"; then
  die "Current OS is not supported."
fi

# Checks whether the script is running as root and bails out if so.
# Whenever root privileges are needed, it will be asked during installation. Doing
# so for the whole process is dangerous and may cause issues.
if [ "$(id -u)" -eq 0 ]; then
  die "Please, do not start installation as root."
fi

# Prompts the user with a question and a default value.
# @param $1 The variable with the default value and returning result.
# @param $2 The question message to prompt the user with.
prompt() {
  if [ -t 0 ]; then
    local result
    declare -n reference="$1"
    read -p "$2 [${!1}]: " result
    if [ ! -z "$result" ]; then
      reference="$result"
    fi
  fi
}

# Validates whether a command exists.
# @param $1 The command to check existance of.
command_exists() {
  command -v "$1" &> /dev/null
  return $?
}

# Downloads a file from the internet.
# @param $1 The URL of the file to download.
# @param $2 The target path to save the file to.
download() {
  local url="$1"
  local output="$2"
  if command_exists "curl"; then
    curl --location --silent --show-error --output "$output" "$url" &> /dev/null
    return $?
  elif command_exists "wget"; then
    wget --quiet --output-document="$output" "$url" &> /dev/null
    return $?
  else
    die "Unable to download repository."
  fi
}

# Extracts an archive file into the given directory.
# @param $1 The archive to be extracted.
# @param $2 The target directory for extraction.
extract() {
  local archive="$1"
  local output_directory="$2"
  if command_exists "tar"; then
    mkdir -p "$output_directory"
    tar --extract --file "$archive" --strip-components 1 --directory "$output_directory"
    return $?
  else
    die "Unable to extract repository tarball."
  fi
}

# Prompt the user about the destination of the dotfiles repository in the local disk.
# A reasonable - and recommended - destination is provided as default.
prompt DOTFILES_DIRECTORY "Where should the dotfiles repository be installed?"

if [ ! -d "$DOTFILES_DIRECTORY" ]; then
  # Prompt the user about the name of the GitHub repository to be used as source
  # for the dotfiles to be installed in this system.
  prompt GITHUB_REPOSITORY "What's the name of your dotfiles repository?"

  declare -r DOTFILES_TARBALL_URL="https://api.github.com/repos/$GITHUB_REPOSITORY/tarball"
  declare -r DOTFILES_REPOSITORY_UPSTREAM="https://github.com/$GITHUB_REPOSITORY.git"

  # Download the GitHub repository from the tarball and extract its contents into
  # the provided destination directory.
  tmpfile="$(mktemp /tmp/dotfiles-repository-XXXXX)"

  download "$DOTFILES_TARBALL_URL" "$tmpfile"
  extract "$tmpfile" "$DOTFILES_DIRECTORY"

  rm "$tmpfile"

else
  # Bail out if the dotfiles directory already exists. In this scenario, we cannot
  # assure that we will not damage pre-existing system configuration if we delete
  # it. Therefore, the user must manually delete the directory to continue.
  die "The dotfiles directory already exists!"
fi

# Change into the dotfiles directory and execute the setup script to configure the
# system as requested by the user.
cd "$DOTFILES_DIRECTORY"
script/setup.sh $DOTFILES_REPOSITORY_UPSTREAM
