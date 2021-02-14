# dotfiles

## Prerequesites

* [xcode](https://stackoverflow.com/a/10335943/567193)
* [brew](https://brew.sh/)
* [gpg](https://formulae.brew.sh/cask/gpg-suite-no-mail)

## Installation

```
$ cd ~ && git clone git@github.com:lifeofguenter/dotfiles.git
$ echo "DOTFILES_INSTALL_OC=1" > ~/dotfiles/config
$ ~/dotfiles/setup.sh
```

## Configuration

```
# installs openshift-cli
DOTFILES_INSTALL_OC=1

# installs minishift
DOTFILES_INSTALL_MINISHIFT=1
```

## Extras

* [draculatheme](https://draculatheme.com/)
* [iterm2 profile/config](extras/com.googlecode.iterm2.plist)

## Todos

* git (git config --global user.signingkey / git config --global user.name / git config --global user.email)
