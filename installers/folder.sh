folder_installer::folders() {
  mkdir -p \
    ~/.docker \
    ~/.terraform.d/plugin-cache
}

folder_installer::dropbox() {
  if [[ -d ~/Dropbox/dotfiles/ ]]; then
    for f in ~/Dropbox/dotfiles/.*; do
      if [[ "${f: -1}" == "." ]]; then
        continue
      fi
      ln -sf "${f}" ~
    done
    chmod 600 ~/.ssh/id_*
    chmod 644 ~/.ssh/*.pub
  fi
}
