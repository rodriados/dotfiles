# Dotfiles and environment variables repository.
# @file The common alias list for any shell.
# @author Rodrigo Siqueira <me@rodriados.com>
# @copyright 2026-present Rodrigo Siqueira

# Navigation aliases.
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ~="cd ~"
alias -- -="cd -"

# Directory aliases.
alias ~documents="cd ~/Documents"
alias ~downloads="cd ~/Downloads"
alias ~projects="cd ~/Projects"

# Auxiliary aliases.
alias sudo="sudo "
alias reload="exec ${SHELL} -l"

# Command color aliases.
alias ls='ls --color=auto'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias grep="grep --color=auto"
alias fgrep="fgrep --color=auto"
alias egrep="egrep --color=auto"
