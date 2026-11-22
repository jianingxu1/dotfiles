# OSX-only stuff. Abort if not OSX.
is_osx || return 0

# Exit if Homebrew is not installed.
[[ ! "$(type -P brew)" ]] && e_error "Brew recipes need Homebrew to install." && return 1

brew upgrade || return 1
brew install mas || return 1
brew bundle install --file="$DOTFILES/conf/packages/Brewfile" || return 1
brew cleanup || return 1
