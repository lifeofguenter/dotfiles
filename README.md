# dotfiles

## Prerequesites

* [xcode](https://stackoverflow.com/a/10335943/567193)
* [brew](https://brew.sh/)
* [gpg](https://formulae.brew.sh/cask/gpg-suite-no-mail)
* git

## Installation

```bash
$ cd ~ && git clone https://github.com/lifeofguenter/dotfiles.git
$ echo "DOTFILES_INSTALL_OC=1" > ~/dotfiles/config
$ ~/dotfiles/setup.sh
```

## Configuration

```bash
DOTFILES_INSTALL_OC=1 # installs openshift-cli
DOTFILES_INSTALL_MINISHIFT=1 # installs minishift
```

## Extras

* [draculatheme](https://draculatheme.com/)
* [iterm2 profile/config](extras/com.googlecode.iterm2.plist)
