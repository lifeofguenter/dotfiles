source ~/.bash-powerline.sh

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
## hack for pip install (global) to work under osx
alias pip-install='sudo -H pip3 install --ignore-installed --upgrade'

## hack for gem install (global) to work under osx
alias gem-install='sudo -H gem install --bindir /usr/local/bin'

## remove fingerprint from known_hosts
alias ssh-delhost='ssh-keygen -f ~/.ssh/known_hosts -R'

## list ssh fingerprints
alias ssh-fingerprints='find ~/.ssh/ -name '*.pub' -exec ssh-keygen -E md5 -lf {} \;'


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

ssh-tunnel() {
  local ip="${2}"

  if [[ ! "${ip}" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    ip="$(dig +short "${ip}" | tail -n1)"
  fi

  ssh \
    -f \
    -o "ExitOnForwardFailure=yes" \
    -o "ControlMaster=no" \
    -L "127.0.0.1:13306:${2}:3306" \
    "${1}" \
    sleep 60
}

## docker stuff
docker-update-time() {
  docker run --rm --privileged alpine hwclock -s
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

ssl-finger() {
  echo | openssl s_client -showcerts -servername "${1}" -connect "${1}:443" 2>/dev/null | openssl x509 -inform pem -noout -text
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

docker-parent() {
  local tmp="$(docker inspect --format='{{.Id}} {{.Parent}}' $(docker images --filter since=${1} -q) | head -n1 | cut -d':' -f2)"
  echo "${tmp:0:12}"
}

ecr-login() {
  local account_id="$(aws --profile "${1}" --output json sts get-caller-identity | jq -r '.Account')"
  local region="$(aws --profile "${1}" configure get region)"
  local private_registries=( "${account_id}.dkr.ecr.${region}.amazonaws.com" "840364872350.dkr.ecr.eu-west-1.amazonaws.com" )

  for private_registry in "${private_registries[@]}"; do
    if ! timeout --preserve-status --signal=KILL 3 docker login "${private_registry}" &> /dev/null; then
      echo "logging into ${private_registry}..."
      aws --profile "${1}" ecr get-login-password --region "${region}" | \
      docker login \
        --username AWS \
        --password-stdin "${private_registry}"
    fi
  done
  local stat_file=~/.docker/aws_${account_id}_${region}

  if ! timeout --preserve-status --signal=KILL 3 docker login "public.ecr.aws" &> /dev/null; then
    echo "logging into public.ecr.aws..."
    aws --profile "${1}" ecr-public get-login-password --region us-east-1 | \
    docker login \
      --username AWS \
      --password-stdin "public.ecr.aws"
  fi
}
#ecr-login

export NVM_DIR="$HOME/.nvm"
[ ! -s "$NVM_DIR/nvm.sh" ] || \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ ! -s "$NVM_DIR/bash_completion" ] || \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# added by travis gem
[ ! -s ~/.travis/travis.sh ] || source ~/.travis/travis.sh

PROMPT_COMMAND="${PROMPT_COMMAND}; dotenv"
