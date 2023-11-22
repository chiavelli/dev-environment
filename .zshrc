parse_git_branch() {
  # Check if the current directory is part of a Git repository
  git rev-parse --git-dir > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    return
  fi

  local branch=$(git branch --show-current 2> /dev/null)
  local indicators=""
  local staged_changes=$(git diff --cached --name-only)
  local unstaged_changes=$(git diff --name-only)
  local untracked_files=$(git ls-files --others --exclude-standard)
  local submodule_changes=$(git submodule summary)

  if [[ -n $staged_changes ]]; then
    # Green asterisk for staged files
    indicators+="%F{green}*%f"
  fi
  if [[ -n $untracked_files ]]; then
    # Red asterisk for untracked files
    indicators+="%F{red}*%f"
  fi
  if [[ -n $unstaged_changes ]]; then
    # Checking if there are changes that are modified but not staged
    for file in $unstaged_changes; do
      if [[ -z $(echo $staged_changes | grep "$file") ]]; then
        # Yellow asterisk for modified files (not staged)
        indicators+="%F{yellow}*%f"
        break
      fi
    done
  fi
  if [[ -n $submodule_changes ]]; then
    # Red tilde for submodule changes
    indicators+="%F{red}~%f"
  fi

  if [ -n "$branch" ]; then
    echo "($branch)$indicators"
  fi
}
