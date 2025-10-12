bash_installer::_bash_completion_install() {
  mkdir -p ~/.bash_completion.d/

  if [[ "${uname}" == "Linux" ]]; then
    sudo apt -yqq install bash-completion
    return 0
  fi

  if [[ -f /usr/local/share/bash-completion/bash_completion ]]; then
    return 0
  fi

  brew install bash-completion@2
}

bash_installer::_bash_completion_setup() {
  if [[ ! -f ~/.bash_completion.d/ssh ]]; then
    ln -sf "${__DIR__}"/.bash_completion.d/ssh ~/.bash_completion.d/ssh
  fi

  if [[ ! -f ~/.bash_completion.d/kubectl ]] && command -v kubectl > /dev/null; then
    kubectl completion bash > ~/.bash_completion.d/kubectl
  fi

  if [[ ! -f ~/.bash_completion.d/minikube ]] && command -v minikube > /dev/null; then
    minikube completion bash > ~/.bash_completion.d/minikube
  fi
}

bash_installer::powerline() {
  brew install powerline-go font-hack-nerd-font
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
  sudo bash -c 'echo /opt/homebrew/bin/bash >> /etc/shells'
  chsh -s /opt/homebrew/bin/bash
}
