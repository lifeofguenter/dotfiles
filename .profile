# https://superuser.com/a/183980/124112
# .profile for envvars
# .bashrc for aliases/functions etc.

export UNAME="$(uname)"
if [[ "${UNAME}" == "Darwin" ]]; then
  export COMPUTER_NAME="$(scutil --get LocalHostName)"
  export OS="MacOS"
elif [[ -n "${WSL_DISTRO_NAME}" ]]; then
  export OS="WSL2"
else
  export OS="Linux"
fi

export EDITOR="vim"

###############################################################
# Locale
###############################################################

if [[ "${UNAME}" == "Linux" ]]; then
  # https://wiki.debian.org/Locale
  #export LC_ALL="en_US.UTF-8"
  export LC_ADDRESS="sv_SE.UTF-8"
  export LC_COLLATE="sv_SE.UTF-8"
  export LC_CTYPE="sv_SE.UTF-8"
  export LC_MONETARY="sv_SE.UTF-8"
  export LC_MEASUREMENT="sv_SE.UTF-8"
  export LC_PAPER="sv_SE.UTF-8"
  export LC_NUMERIC="sv_SE.UTF-8"
  export LC_TELEPHONE="sv_SE.UTF-8"
  export LC_TIME="sv_SE.UTF-8"

  export LANG="en_US.UTF-8"
  export LANGUAGE="en_US.UTF-8"
  export LC_RESPONSE="en_US.UTF-8"
  export LC_MESSAGES="en_US.UTF-8"
else
  # https://coderwall.com/p/-k_93g/mac-os-x-valueerror-unknown-locale-utf-8-in-python
  export LC_ALL=en_US.UTF-8
  export LANG=en_US.UTF-8
fi

###############################################################
# Paths
###############################################################

## Local
PATH="/usr/local/sbin:${PATH}"

## Cargo
PATH="${HOME}/.cargo/bin:${PATH}"

## Composer
PATH="${HOME}/.composer/vendor/bin:${PATH}"

## Python
PATH="$(python3 -m site --user-base)/bin:${PATH}"

## Maven
PATH="/opt/apache-maven-3.8.4/bin:${PATH}"

## Android-SDK
PATH="/opt/android-sdk/tools/bin:${PATH}"

## Misc
PATH="${PATH}:${HOME}/.local/bin"

# Final PATH export
export PATH="${PATH}"

###############################################################
# Homes
###############################################################

## Android
export ANDROID_HOME=/opt/android-sdk

## Java
if [[ -f /usr/libexec/java_home ]]; then
  export JAVA_HOME="$(/usr/libexec/java_home)"
elif [[ -f /etc/alternatives/java ]]; then
  export JAVA_HOME="$(dirname "$(dirname "$(realpath /etc/alternatives/java)")")"
fi

## Rust
if [[ -f "${HOME}/.cargo/env" ]]; then
  source "${HOME}/.cargo/env"
fi

###############################################################
# Configs
###############################################################

## PHP
export COMPOSER_PROCESS_TIMEOUT=900

###############################################################
# Secrets
###############################################################
