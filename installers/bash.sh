bash_installer::_bash_completion_install() {
  mkdir -p ~/.bash_completion.d/

  if [[ "${uname}" == "Linux" ]]; then
    sudo apt -yqq install bash-completion
    return 0
  fi

  if [[ -f /usr/local/share/bash-completion/bash_completion ]]; then
    return 0
  fi

  brew install autoconf automake

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

bash_installer::_bash_completion_setup() {
  if [[ ! -f ~/.bash_completion.d/ssh ]]; then
    ln -sf "${__DIR__}"/.bash_completion.d/ssh ~/.bash_completion.d/ssh
  fi

  if [[ ! -f ~/.bash_completion.d/oc ]] && command -v oc > /dev/null; then
    oc completion bash > ~/.bash_completion.d/oc
  fi

  if [[ ! -f ~/.bash_completion.d/minishift ]] && command -v minishift > /dev/null; then
    minishift completion bash > ~/.bash_completion.d/minishift
  fi

  if [[ ! -f ~/.bash_completion.d/hal ]] && command -v hal > /dev/null; then
    hal --print-bash-completion > ~/.bash_completion.d/hal
  fi

  if [[ ! -f ~/.bash_completion.d/kubectl ]] && command -v kubectl > /dev/null; then
    kubectl completion bash > ~/.bash_completion.d/kubectl
  fi

  if [[ ! -f ~/.bash_completion.d/minikube ]] && command -v minikube > /dev/null; then
    minikube completion bash > ~/.bash_completion.d/minikube
  fi
}

bash_installer::powerline() {
  if [[ -f ~/.bash-powerline.sh ]]; then
    return 0
  fi
  curl -#Lo ~/".bash-powerline.sh" "https://raw.githubusercontent.com/riobard/bash-powerline/master/bash-powerline.sh"
}

bash_installer::bash_completion() {
  bash_installer::_bash_completion_install
  bash_installer::_bash_completion_setup
}

bash_installer::bash() {
  if [[ "${uname}" != "Darwin" ]]; then
    return 0
  fi

  if [[ -f "/usr/local/bin/bash" ]]; then
    return 0
  fi

  brew install bash
  sudo bash -c 'echo /usr/local/bin/bash >> /etc/shells'
  chsh -s /usr/local/bin/bash
}
