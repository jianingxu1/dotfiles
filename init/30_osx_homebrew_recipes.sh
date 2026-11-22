# OSX-only stuff. Abort if not OSX.
is_osx || return 0

# Exit if Homebrew is not installed.
[[ ! "$(type -P brew)" ]] && e_error "Brew recipes need Homebrew to install." && return 1

# Install declared packages without upgrading all existing software or pruning old versions.
brew bundle install --no-upgrade --file="$DOTFILES/conf/packages/Brewfile" || return 1
