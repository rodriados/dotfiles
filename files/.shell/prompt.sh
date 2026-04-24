#!/usr/bin/env bash
# Dotfiles and environment variables repository.
# @file The generic shell prompt build functions.
# @author Rodrigo Siqueira <me@rodriados.com>
# @copyright 2026-present Rodrigo Siqueira

export SHELL_PROMPT_CURRENTLY_IN_GIT_REPOSITORY=0

_shell_prompt_git_command() {
  GIT_OPTIONAL_LOCKS=0 command git "$@"
}

_shell_prompt_git_directory_check() {
  if _shell_prompt_git_command rev-parse --is-inside-work-tree &> /dev/null;
    then SHELL_PROMPT_CURRENTLY_IN_GIT_REPOSITORY=1
    else SHELL_PROMPT_CURRENTLY_IN_GIT_REPOSITORY=0
  fi
}

_shell_prompt_git_reference() {
  {
    _shell_prompt_git_command symbolic-ref --short HEAD          || \
    _shell_prompt_git_command describe --tags --exact-match HEAD || \
    _shell_prompt_git_command rev-parse --short HEAD
  } 2> /dev/null
}

_shell_prompt_git_repo_status() {
  local SHELL_PROMPT_GIT_STATUS
  if [ ! -z "$(git log "@{upstream}..HEAD")" ];
    then SHELL_PROMPT_GIT_STATUS='^'  # Commits ahead of remote
  elif ! git diff --quiet --ignore-submodules --cached;
    then SHELL_PROMPT_GIT_STATUS='+'  # Uncommitted staged changes
  elif ! git diff-files --quiet --ignore-submodules --;
    then SHELL_PROMPT_GIT_STATUS='!'  # Unstaged changes
  elif [ -n "$(git ls-files --others --exclude-standard)" ];
    then SHELL_PROMPT_GIT_STATUS='?'  # Untracked files
  elif git rev-parse --verify refs/stash;
    then SHELL_PROMPT_GIT_STATUS='#'  # Stashed files
  fi &> /dev/null
  echo -n "$SHELL_PROMPT_GIT_STATUS"
}
