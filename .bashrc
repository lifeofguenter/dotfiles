source ~/.bash-powerline.sh
source /usr/local/share/bash-completion/bash_completion  

for file in ~/.bash_completion.d/*; do
  if [[ ! -f "${file}" ]]; then
    continue
  fi
  source "${file}"
done

# ALIASES
## hack for pip install (global) to work under osx
alias pip-install='sudo -H pip install --ignore-installed --upgrade'

## hack for gem install (global) to work under osx
alias gem-install='sudo -H gem install --bindir /usr/local/bin'

## remove fingerprint from known_hosts
alias ssh-delhost='ssh-keygen -f ~/.ssh/known_hosts -R'

## list ssh fingerprints
alias ssh-fingerprints='find ~/.ssh/ -name '*.pub' -exec ssh-keygen -E md5 -lf {} \;'

## ssh-keygen -t rsa -b 4096 -o -a 100 -f

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

git-tag() {
  git fetch -q upstream
  git checkout -q upstream/master
  git tag "${1}"
  git push "upstream" "${1}"
}

git-tag-delete() {
  git tag --delete "${1}"
  git push upstream ":${1}"
}

git-branches-all() {
  for branch in $(git branch -a | grep remotes | grep -v HEAD | grep -v master); do
    git branch --track "${branch#remotes/origin/}" "${branch}"
  done
}

git-branch-delete() {
  git push -d origin "${1}"
  git branch -D "${1}"
}

git-pr() {
  git fetch --quiet upstream
  git checkout --quiet -b "${1}" upstream/master
}

git-push-all() {
  if [[ -z "${1}" ]]; then
    echo 'commit subject missing...'
    return 1
  fi

  branch="$(git-pwb)"
  if [[ -z "${branch}" ]]; then
    echo 'unable to get current branch...'
    return 1
  fi

  # display status
  git status --short --branch --untracked-files=all
  echo ''
  echo -n 'continue (y/n)? '
  read answer
  if echo "${answer}" | grep -viq "^y" ;then
    return 1
  fi
  echo ''

  message=()
  message+=( --message "${1}" )
  if [[ ! -z "${2}" ]]; then
    message+=( --message "${2}" )
  fi

  # add & commit
  git add --all
  git commit \
    --gpg-sign \
    "${message[@]}"

  # push
  git push --quiet --set-upstream origin "${branch}"
}

ssl-finger() {
  echo | openssl s_client -showcerts -servername "${1}" -connect "${1}:443" 2>/dev/null | openssl x509 -inform pem -noout -text
}

docker-parent() {
  local tmp="$(docker inspect --format='{{.Id}} {{.Parent}}' $(docker images --filter since=${1} -q) | head -n1 | cut -d':' -f2)"
  echo "${tmp:0:12}"
}

ecr-login() {
  stat_bin="${STAT_PATH:-/usr/bin/stat}"

  if ! grep -q ".dkr.ecr.eu-west-2.amazonaws.com" ~/.docker/config.json; then
    $(aws --profile wi --region eu-west-2 ecr get-login --no-include-email) &> /dev/null
  fi

  if [[ ! -f ~/.docker/aws ]]; then
    touch ~/.docker/aws
  fi

  local filemtime="$("${stat_bin}" -c %Y ~/.docker/aws)"
  local currtime="$(date +%s)"
  local diff="$(( currtime - filemtime ))"

  # https://docs.aws.amazon.com/cli/latest/reference/ecr/get-login.html
  # only valid for 12hrs
  if [[ "${diff}" -gt "39600" ]]; then
    $(aws --profile wi --region eu-west-2 ecr get-login --no-include-email) &> /dev/null
    touch ~/.docker/aws
  fi
}
#ecr-login

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# added by travis gem
[ -f ~/.travis/travis.sh ] && source ~/.travis/travis.sh
