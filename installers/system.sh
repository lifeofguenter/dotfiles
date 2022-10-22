system_installer::locale() {
  sudo -H sed -i 's/# sv_SE.UTF-8 UTF-8/sv_SE.UTF-8 UTF-8/' /etc/locale.gen
  sudo -H locale-gen
}
