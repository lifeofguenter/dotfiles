#!/usr/bin/env bash

readlink_bin="${READLINK_PATH:-readlink}"
if ! "${readlink_bin}" -f test &> /dev/null; then
  __DIR__="$(dirname "$(python -c "import os,sys; print(os.path.realpath(os.path.expanduser(sys.argv[1])))" "${0}")")"
else
  __DIR__="$(dirname "$("${readlink_bin}" -f "${0}")")"
fi

source "${__DIR__}/shlibs/functions.shlib"

set -E
trap 'throw_exception' ERR

#
# versions
#
bash_completion_version=2.9
minishift_version=1.16.1

uname="$(uname)"

install_bash() {
  brew install bash

  sudo bash -c 'echo /usr/local/bin/bash >> /etc/shells'
}

install_bash_powerline() {
  curl -#Lo ~/".bash-powerline.sh" "https://raw.githubusercontent.com/riobard/bash-powerline/master/bash-powerline.sh"
}

install_bash_completion() {
  cd /tmp
  curl -#LO "https://github.com/scop/bash-completion/releases/download/${bash_completion_version}/bash-completion-${bash_completion_version}.tar.xz"
  tar xf "bash-completion-${bash_completion_version}.tar.xz"
  cd "bash-completion-${bash_completion_version}/"
  autoreconf -i
  ./configure > /dev/null
  make > /dev/null
  sudo make -s install
  rm -rf "bash-completion-${bash_completion_version}"*
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

install_screenshots() {
  mkdir -p ~/Screenshots
  defaults write com.apple.screencapture location ~/Screenshots
}

install_showallfiles() {
  defaults write com.apple.finder AppleShowAllFiles YES
}

################################################################################
# user input
################################################################################
read -p 'git-user: ' git_user
read -p 'git-email: ' git_email
read -p 'git-gpg: ' git_gpg

###############################################################################
# symlink dropbox / dotfiles
###############################################################################
mkdir -p ~/.docker ~/".vim/pack/${USER}/opt"
curl -L#O https://github.com/dracula/vim/archive/master.zip
unzip master.zip
mv vim-master ~/".vim/pack/${USER}/opt/dracula"
rm master.zip

for f in ~/Dropbox/dotfiles/.*; do
  if [[ "${f: -1}" == "." ]]; then
    continue
  fi
  ln -sf "${f}" ~
done
chmod 600 ~/.ssh/id_*
chmod 644 ~/.ssh/*.pub

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

if [[ ! -f ~/.ssh/config ]]; then
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
fi

################################################################################
# setup bash_completion
################################################################################
if [[ ! -f "/usr/local/bin/bash" ]]; then
  consolelog "installing bash..."
  install_bash
  chsh -s /usr/local/bin/bash
fi

if [[ ! -f /usr/local/share/bash-completion/bash_completion ]]; then
  consolelog "bash-completion not found. installing..."
  install_bash_completion
fi

if [[ ! -d ~/.bash_completion.d ]]; then
  mkdir -p \
    ~/.bash_completion.d

  ln -sf "${__DIR__}"/.bash_completion.d/ssh ~/.bash_completion.d/ssh

  if command -v oc > /dev/null; then
    oc completion bash > ~/.bash_completion.d/oc
  fi

  if command -v minishift > /dev/null; then
    minishift completion bash > ~/.bash_completion.d/minishift
  fi
fi

install_screenshots
install_showallfiles

################################################################################
# textmate (macos)
################################################################################
if [[ "${uname}" == "Darwin" ]]; then
  if [[ ! -d ~/Library/Application\ Support/TextMate/Bundles/Strip-Whitespace-On-Save.tmbundle ]]; then
    git clone git@github.com:bomberstudios/Strip-Whitespace-On-Save.tmbundle.git ~/Library/Application\ Support/TextMate/Bundles/Strip-Whitespace-On-Save.tmbundle
  fi

  if [[ ! -d ~/Library/Application\ Support/TextMate/Bundles/Whitespace.tmbundle ]]; then
    git clone git@github.com:mads-hartmann/Whitespace.tmbundle.git ~/Library/Application\ Support/TextMate/Bundles/Whitespace.tmbundle
  fi

  if [[ ! -d ~/Library/Application\ Support/Textmate/Bundles/Ensure-New-Line-at-the-EOF.tmbundle ]]; then
    git clone git@github.com:hajder/Ensure-New-Line-at-the-EOF.tmbundle.git ~/Library/Application\ Support/Textmate/Bundles/Ensure-New-Line-at-the-EOF.tmbundle
  fi
fi

################################################################################
# dotfiles overwrite
################################################################################
dotfiles=(
  .bash_profile
  .bashrc
  .profile
  .tm_properties
)

for dotfile in "${dotfiles[@]}"; do
  if [[ -f ~/"${dotfile}" ]]; then
    continue
  fi
  consolelog "overwriting dotfile ${dotfile}..."
  cp -f "${__DIR__}/${dotfile}" ~/"${dotfile}"
done

################################################################################
# git
################################################################################
if [[ ! -z "${git_email}" ]]; then
  git config --global user.email "${git_email}"
fi

if [[ ! -z "${git_user}" ]]; then
  git config --global user.name "${git_user}"
fi

if [[ ! -z "${git_gpg}" ]]; then
  git config --global commit.gpgsign true
  git config --global user.signingkey "${git_gpg}"
fi

################################################################################
# brew (macos)
################################################################################
if [[ "${uname}" == "Darwin" ]]; then
  brew install jq
fi

################################################################################
# install global as to not be affected by local dirt
################################################################################
sudo -H pip3 install ansible awscli boto3
