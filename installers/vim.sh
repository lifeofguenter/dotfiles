vim_installer::vim() {
  if [[ -d ~/".vim/pack/${USER}/opt/dracula" ]]; then
    return 0
  fi

  mkdir -p ~/".vim/pack/${USER}/opt/dracula"
  curl -L#O https://github.com/dracula/vim/archive/master.zip
  unzip master.zip
  mv vim-master ~/".vim/pack/${USER}/opt/dracula"
  rm master.zip
}
