# https://superuser.com/a/183980/124112
# .profile for envvars
# .bashrc for aliases/functions etc.

export CXX="clang -std=c++11 -stdlib=libc++"

# https://coderwall.com/p/-k_93g/mac-os-x-valueerror-unknown-locale-utf-8-in-python
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

## Android
export ANDROID_HOME=/opt/android-sdk
export JAVA_HOME="$(/usr/libexec/java_home)"

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
PATH="$(python -m site --user-base)/bin:${PATH}"

## Maven
PATH="/opt/apache-maven-3.5.2/bin:${PATH}"

## Android-SDK
PATH="/opt/android-sdk/tools/bin:${PATH}"

# Setting PATH for Python 3.7
PATH="/Library/Frameworks/Python.framework/Versions/3.7/bin:${PATH}"

# brew coreutils
#PATH="/usr/local/opt/coreutils/libexec/gnubin:${PATH}"

# Final PATH export
export PATH="${PATH}"

# Rust
if [[ -f ~/.cargo/env ]]; then
  source ~/.cargo/env
fi

# PHP
## Composer
export COMPOSER_PROCESS_TIMEOUT=900
