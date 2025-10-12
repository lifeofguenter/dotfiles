# bash completion scripts
if [[ -f /usr/local/share/bash-completion/bash_completion ]]; then
  source /usr/local/share/bash-completion/bash_completion
elif [[ -f /usr/share/bash-completion/bash_completion ]]; then
  source /usr/share/bash-completion/bash_completion
fi

for file in ~/.bash_completion.d/*; do
  if [[ ! -f "${file}" ]]; then
    continue
  fi
  source "${file}"
done

# ALIASES
## remove fingerprint from known_hosts
alias ssh-delhost='ssh-keygen -f ~/.ssh/known_hosts -R'


if command -v dircolors > /dev/null; then
  eval "$(dircolors ~/.dir_colors/dircolors)"
  alias ls="ls --color=auto"
  alias ll="ls -lh"
  alias grep="grep --color=auto"
fi

## ssh stuff
ssh-kill() {
  if ssh -O check "${1}" &> /dev/null; then
    ssh -O exit "${1}"
  fi
}

## git stuff
git-pwb() {
  echo "$(git symbolic-ref --short HEAD 2> /dev/null)"
}

git-pwr() {
  echo "$(git config "branch.$(git-pwb).remote")"
}

git-pwdb() {
  local head_branch="$(git remote show origin | grep "HEAD branch")"
  echo "${head_branch##*: }"
}

git-tag() {
  local remote="upstream"

  if ! git remote show upstream &> /dev/null; then
    remote="origin"
  fi

  git fetch -q "${remote}"
  git checkout -q "${remote}/$(git-pwdb)"
  git tag "${1}"
  git push "${remote}" "${1}"
}

git-tag-force() {
  local remote="upstream"

  if ! git remote show upstream &> /dev/null; then
    remote="origin"
  fi

  git fetch -q "${remote}"
  git checkout -q "${remote}/$(git-pwdb)"
  git tag -f "${1}"
  git push -f "${remote}" "${1}"
}

git-tag-delete() {
  git tag --delete "${1}"
  git push upstream ":${1}"
}

git-branches-all() {
  for branch in $(git branch -a | grep remotes | grep -v HEAD | grep -v master | grep -v main); do
    git branch --track "${branch#remotes/origin/}" "${branch}"
  done
}

git-branch-delete() {
  git push -d origin "${1}"
  git branch -D "${1}"
}

git-pr() {
  local upstream_branch="$(git-pwdb)"
  local remote="upstream"
  local branch_name

  if [[ ! -z "${2}" ]]; then
    upstream_branch="${2}"
  fi

  if ! git remote show upstream &> /dev/null; then
    remote="origin"
  fi

  # https://ORG.atlassian.net/browse/TICKET-ID
  if [[ "${1}" =~ ^https://[^.]+.atlassian.net/browse/(.*)$ ]]; then
    branch_name="${BASH_REMATCH[1]}"
  elif [[ "${1}" =~ ^https://jira.[^.]+.[^.]+/browse/(.*)$ ]]; then
    branch_name="${BASH_REMATCH[1]}"
  else
    branch_name="${1}"
  fi

  git fetch --quiet "${remote}"
  git checkout --quiet -b "feature/${branch_name}" "${remote}/${upstream_branch}"
}

git-push-all() {
  if [[ -z "${1}" ]]; then
    echo 'commit subject missing...'
    return 1
  fi

  local remote="origin"
  if [[ ! -z "${2}" ]]; then
    remote="${2}"
  fi

  branch="$(git-pwb)"
  if [[ -z "${branch}" ]]; then
    echo 'unable to get current branch...'
    return 1
  fi

  # display status
  git status --short --branch --untracked-files=all
  echo ''
  if [[ -z "${GIT_PUSH_ALL_FORCE}" ]]; then
    echo -n 'continue (y/n)? '
    read answer
    if echo "${answer}" | grep -viq "^y" ;then
      return 1
    fi
    echo ''
  fi

  # add & commit
  git add --all
  git commit \
    --gpg-sign \
    --message "${1}"

  # push
  git push --quiet --set-upstream "${remote}" "${branch}"
}

venv() {
  if [[ ! -d .venv ]]; then
    virtualenv .venv
  fi

  source .venv/bin/activate
}

dotenv() {
  if [[ -f .env ]]; then
    set -o allexport
    source .env
    set +o allexport
  fi
}

_update_ps1() {
  PS1="$(powerline-go \
           -shell bash \
           -theme gruvbox \
           -cwd-max-depth 1 \
           -modules venv,host,ssh,cwd,perms,git,jobs,exit,kube,root \
           -hostname-only-if-ssh \
           -shorten-eks-names \
           -shorten-gke-names \
           -error ${?} \
           -jobs $(jobs -p | wc -l))"

  # Uncomment the following line to automatically clear errors after showing
  # them once. This not only clears the error for powerline-go, but also for
  # everything else you run in that shell. Don't enable this if you're not
  # sure this is what you want.

  #set "?"
}

#PROMPT_COMMAND="${PROMPT_COMMAND}; dotenv"
if [[ -n "${PROMPT_COMMAND}" ]]; then
  PROMPT_COMMAND="_update_ps1; ${PROMPT_COMMAND}; dotenv"
else
  PROMPT_COMMAND="_update_ps1; dotenv"
fi
