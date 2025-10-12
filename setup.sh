#!/usr/bin/env bash

readlink_bin="${READLINK_PATH:-readlink}"
if ! "${readlink_bin}" -f test &> /dev/null; then
  __DIR__="$(dirname "$(python3 -c "import os,sys; print(os.path.realpath(os.path.expanduser(sys.argv[1])))" "${0}")")"
else
  __DIR__="$(dirname "$("${readlink_bin}" -f "${0}")")"
fi

source "${__DIR__}/shlibs/functions.sh"

set -E
trap 'throw_exception' ERR

#
# versions
#

uname="$(uname)"

for installer in "${__DIR__}/installers/"*; do
  if [[ ! -f "${installer}" ]]; then
    continue
  fi
  consolelog "loading ${installer##*/} ..."
  source "${installer}"
done
echo ""

install_screenshots() {
  mkdir -p ~/Screenshots

  if [[ "${uname}" == "Darwin" ]]; then
    defaults write com.apple.screencapture location ~/Screenshots/
  elif [[ "${uname}" == "Linux" ]]; then
    gsettings set org.gnome.gnome-screenshot auto-save-directory "file://$HOME/Screenshots/"
  fi
}

install_showallfiles() {
  if [[ "${uname}" != "Darwin" ]]; then
    return 0
  fi
  defaults write com.apple.finder AppleShowAllFiles YES
}

################################################################################
# bootstrap
################################################################################
if [[ "${uname}" == "Linux" ]]; then
  sudo apt -qq update
  sudo apt-get -qqy install curl
fi

################################################################################
# user input
################################################################################
read -rp 'git-user: ' git_user
read -rp 'git-email: ' git_email
read -rp 'git-gpg: ' git_gpg

###############################################################################
# symlink dropbox / dotfiles
###############################################################################
consolelog "installing folders..."
folder_installer::folders
# folder_installer::dropbox
vim_installer::vim

################################################################################
# install various tools
################################################################################
consolelog "installing tools..."

bash_installer::powerline

################################################################################
# setup ssh
################################################################################
consolelog "setting up ssh..."

mkdir -p \
  ~/.ssh/config.d/

if [[ ! -f ~/.ssh/id_ed25519 ]]; then
  ssh-keygen -o -a 100 -t ed25519 -f ~/.ssh/id_ed25519 -C "${git_email}"
fi

# if [[ ! -f ~/.ssh/id_rsa ]]; then
#   ssh-keygen -m PEM -a 100 -t rsa -b 4096 -f ~/.ssh/id_rsa -C "${git_email}"
# fi

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
# setup system
################################################################################
bash_installer::bash
bash_installer::bash_completion

install_screenshots
install_showallfiles
# system_installer::locale

################################################################################
# dotfiles copy-over
################################################################################
dotfiles=(
  .bash_profile
  .bashrc
  .profile
  .tm_properties
)

for dotfile in "${dotfiles[@]}"; do
  # todo: only check if symlink
  if [[ -f ~/"${dotfile}" ]]; then
    continue
  fi
  consolelog "copying dotfile ${dotfile}..."
  cp "${__DIR__}/${dotfile}" ~/"${dotfile}"
done

################################################################################
# git
################################################################################
if [[ -n "${git_email}" ]]; then
  git config --global user.email "${git_email}"
fi

if [[ -n "${git_user}" ]]; then
  git config --global user.name "${git_user}"
fi

if [[ -n "${git_gpg}" ]]; then
  git config --global commit.gpgsign true
  git config --global user.signingkey "${git_gpg}"
fi

################################################################################
# brew (macos)
################################################################################
if [[ "${uname}" == "Darwin" ]]; then
  brew install \
    git \
    jq \
    tfenv \
    wget \
    gettext \
    make \
    ansible \
    awscli \
    watch

  # ln -sf /usr/local/opt/gettext/bin/envsubst /usr/local/bin/envsubst
  # ln -sf /usr/local/opt/make/libexec/gnubin/make /usr/local/bin/make

  # defaults write -g ApplePressAndHoldEnabled -bool true
elif [[ "${uname}" == "Linux" ]]; then
  mkdir -p ~/.local/bin
  git clone https://github.com/tfutils/tfenv.git ~/.tfenv
  ln -s ~/.tfenv/bin/* ~/.local/bin
fi

################################################################################
# pip
################################################################################
# pip3 install --user ansible awscli boto3

# xsel sshpass
