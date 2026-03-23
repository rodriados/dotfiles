# Get the current branch status.
__prompt_git() {
  git rev-parse --is-inside-work-tree &>/dev/null || return

  # Check of unpushed commits
  if [ ! -z "$(git log @{upstream}..HEAD 2>/dev/null)" ]; then
    echo '^'

  # Check for uncommitted changes in the index.
  elif ! $(git diff --quiet --ignore-submodules --cached); then
    echo '+'

  # Check for unstaged changes.
  elif ! $(git diff-files --quiet --ignore-submodules --); then
    echo '!'

  # Check for untracked files.
  elif [ -n "$(git ls-files --others --exclude-standard)" ]; then
    echo '?'

  # Check for stashed files.
  elif $(git rev-parse --verify refs/stash &>/dev/null); then
    echo '#'
  fi
}

PROMPT='%B%F{64}%n%f %F{33}%~%f%F{166}$(git_prompt_info)%f%F{125}$(__prompt_git)%f%b $ '

ZSH_THEME_GIT_PROMPT_PREFIX=" "
ZSH_THEME_GIT_PROMPT_SUFFIX=""
ZSH_THEME_GIT_PROMPT_DIRTY=""
ZSH_THEME_GIT_PROMPT_CLEAN=""
