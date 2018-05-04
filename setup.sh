#!/usr/bin/env bash

readlink_bin="${READLINK_PATH:-readlink}"
if ! "${readlink_bin}" -f test &> /dev/null; then
  __DIR__="$(dirname "$("${readlink_bin}" "${0}")")"
else
  __DIR__="$(dirname "$("${readlink_bin}" -f "${0}")")"
fi

source "${__DIR__}/shlibs/functions.shlib"

set -E
trap 'throw_exception' ERR

#
# versions
#
bash_completion_version=2.8
minishift_version=1.16.1

install_bash_powerline() {
  curl -#Lo "~/.bash-powerline.sh" "https://raw.githubusercontent.com/riobard/bash-powerline/master/bash-powerline.sh"
}

install_bash_completion() {
  cd /tmp
  curl -#LO "https://github.com/scop/bash-completion/releases/download/${bash_completion_version}/bash-completion-${bash_completion_version}.tar.xz"
  tar xf "bash-completion-${bash_completion_version}.tar.xz"
  cd "bash-completion-${bash_completion_version}/"
  ./configure > /dev/null
  make
  sudo make install
}

install_oc() {
  cd /tmp
  curl -#LO "https://github.com/openshift/origin/releases/download/v3.9.0/openshift-origin-client-tools-v3.9.0-191fece-mac.zip"
  unzip -q openshift-origin-client-tools-v3.9.0-191fece-mac.zip

}

install_minishift() {
  cd /tmp
  curl -#LO "https://github.com/minishift/minishift/releases/download/v${minishift_version}/minishift-${minishift_version}-darwin-amd64.tgz"
  tar xf "minishift-${minishift_version}-darwin-amd64.tgz"

}

################################################################################
# install various tools
################################################################################
consolelog "installing tools..."

if [[ ! -f ~/.bash-powerline.sh ]]; then
  install_bash_powerline
fi

if [[ ! -z "${DOTFILES_INSTALL_OC}" ]]; then
  install_oc
fi

if [[ ! -z "${DOTFILES_INSTALL_MINISHIFT}" ]]; then
  install_minishift
fi

################################################################################
# setup ssh
################################################################################
consolelog "setting up ssh..."

mkdir -p \
  ~/.ssh/config.d/

if [[ ! -f ~/.ssh/id_ed25519 ]]; then
  ssh-keygen -o -a 100 -t ed25519 -f ~/.ssh/id_ed25519
fi

cat <<'EOF' > ~/.ssh/config
UseKeychain yes
IdentityFile ~/.ssh/id_ed25519

Include ~/.ssh/config.d/*

Host bitbucket.org
  ControlMaster no

Host *
  ControlPath /private/tmp/ssh-%r@%h-%p
  ControlMaster auto
  ControlPersist 600
  ServerAliveInterval 60
EOF

################################################################################
# setup bash_completion
################################################################################
consolelog "setting up bash_completion..."

if [[ ! -f /usr/local/share/bash-completion/bash_completion ]]; then
  consolelog "bash-completion not found. installing..."
  install_bash_completion
fi

mkdir -p \
  ~/.bash_completion.d

ln -sf "${__DIR__}"/.bash_completion.d/ssh ~/.bash_completion.d/ssh

if command -v oc > /dev/null; then
  oc completion bash > ~/.bash_completion.d/oc
fi

if command -v minishift > /dev/null; then
  minishift completion bash > ~/.bash_completion.d/minishift
fi

################################################################################
# dotfiles overwrite
################################################################################
dotfiles=(
  .bash_profile
  .bashrc
  .profile
)
  
for dotfile in "${dotfiles[@]}"; do
  consolelog "overwriting dotfile ${dotfile}..."
  cp -f "${__DIR__}/${dotfile}" ~/"${dotfile}"
done

################################################################################
