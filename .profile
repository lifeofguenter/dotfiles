# https://superuser.com/a/183980/124112
# .profile for envvars
# .bashrc for aliases/functions etc.

export UNAME="$(uname)"
if [[ "${UNAME}" == "Darwin" ]]; then
  export COMPUTER_NAME="$(scutil --get LocalHostName)"
fi

export EDITOR=vim

if [[ "${UNAME}" == "Linux" ]]; then
  # https://wiki.debian.org/Locale
  #export LC_ALL="en_US.UTF-8"
  export LC_ADDRESS="de_DE.UTF-8"
  export LC_COLLATE="de_DE.UTF-8"
  export LC_CTYPE="de_DE.UTF-8"
  export LC_MONETARY="de_DE.UTF-8"
  export LC_MEASUREMENT="de_DE.UTF-8"
  export LC_PAPER="de_DE.UTF-8"
  export LC_NUMERIC="de_DE.UTF-8"
  export LC_TELEPHONE="de_DE.UTF-8"
  export LC_TIME="de_DE.UTF-8"

  export LANG="en_US.UTF-8"
  export LANGUAGE="en_US.UTF-8"
  export LC_RESPONSE="en_US.UTF-8"
  export LC_MESSAGES="en_US.UTF-8"
else
  # https://coderwall.com/p/-k_93g/mac-os-x-valueerror-unknown-locale-utf-8-in-python
  export LC_ALL=en_US.UTF-8
  export LANG=en_US.UTF-8
fi

## Local
PATH="/usr/local/sbin:${PATH}"

## Haskell
PATH="${HOME}/Library/Haskell/bin:${PATH}"

## Cargo
PATH="${HOME}/.cargo/bin:${PATH}"

## Go
export GOPATH="${HOME}/Projects/go"
PATH="${GOPATH}/bin:${PATH}"

## Composer
PATH="${HOME}/.composer/vendor/bin:${PATH}"

## Python
PATH="$(python3 -m site --user-base)/bin:${PATH}"

## Maven
PATH="/opt/apache-maven-3.5.2/bin:${PATH}"

## Android-SDK
PATH="/opt/android-sdk/tools/bin:${PATH}"

# Final PATH export
export PATH="${PATH}"

# Rust
if [[ -f ~/.cargo/env ]]; then
  source ~/.cargo/env
fi

# PHP
## Composer
export COMPOSER_PROCESS_TIMEOUT=900
