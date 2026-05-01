#!/usr/bin/env bash
# Dotfiles and environment variables repository.
# @file The common alias list for any shell.
# @author Rodrigo Siqueira <me@rodriados.com>
# @copyright 2026-present Rodrigo Siqueira

alias sudo="sudo "
alias reload="exec ${SHELL} -l"

# Navigation aliases.
alias ~="cd ~"
alias ..="cd .."
alias -- -="cd -"

alias ls="ls --color=auto --group-directories-first -F"
alias la="ls -lAh"
alias l="ls -C"

for ALIASCMD in dir vdir grep egrep fgrep rgrep xzgrep zgrep; do
  alias $ALIASCMD="$ALIASCMD --color=auto"
done

if xdg-open --version &> /dev/null; then
  alias open='xdg-open'
fi

unset ALIASCMD
