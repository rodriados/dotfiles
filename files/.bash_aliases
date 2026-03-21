#!/usr/bin/env bash

function @cdfolder() {
  cd $1/$2
}

alias ..="@cdfolder .."
alias ...="@cdfolder ../.."
alias ....="@cdfolder ../../.."
alias .....="@cdfolder ../../../.."
alias ~="@cdfolder ~"
alias -- -="cd -"

alias @documents="@cdfolder ~/Documents"
alias @downloads="@cdfolder ~/Downloads"
alias @desktop="@cdfolder ~/Desktop"
alias @projects="@cdfolder /projects"

alias grep="grep --color=auto"
alias fgrep="fgrep --color=auto"
alias egrep="egrep --color=auto"

alias sudo="sudo "
alias reload="exec ${SHELL} -l"
