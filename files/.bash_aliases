#!/usr/bin/env bash

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ~="cd ~"
alias -- -="cd -"

alias ~documents="cd ~/Documents"
alias ~downloads="cd ~/Downloads"
alias ~desktop="cd ~/Desktop"
alias ~projects="cd /projects"

alias ls='ls --color=auto'
#alias dir='dir --color=auto'
#alias vdir='vdir --color=auto'

alias grep="grep --color=auto"
alias fgrep="fgrep --color=auto"
alias egrep="egrep --color=auto"

alias sudo="sudo "
alias reload="exec ${SHELL} -l"

if [ -f ~/.bash_aliases.local ]; then
  source ~/.bash_aliases.local
fi
