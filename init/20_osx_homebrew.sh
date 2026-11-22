# OSX-only stuff. Abort if not OSX.
is_osx || return 0

# Install Homebrew.
if [[ ! "$(type -P brew)" ]]; then
  e_header "Installing Homebrew"
  local_installer="$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || return 1
  /bin/bash -c "$local_installer" || return 1
  unset local_installer
  echo >> "$HOME/.zprofile" || return 1
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile" || return 1
  brew_environment="$(/opt/homebrew/bin/brew shellenv)" || return 1
  eval "$brew_environment" || return 1
  unset brew_environment
fi

# Exit if, for some reason, Homebrew is not installed.
[[ ! "$(type -P brew)" ]] && e_error "Homebrew failed to install." && return 1

e_header "Updating Homebrew"
# Doctor warnings are diagnostic and should not block package installation.
if ! brew doctor; then
  e_arrow "Homebrew doctor reported issues; continuing with package installation."
fi
brew update || return 1

# Functions used in subsequent init scripts.

# Tap Homebrew kegs.
function brew_tap_kegs() {
  kegs=($(setdiff "${kegs[*]}" "$(brew tap)"))
  if (( ${#kegs[@]} > 0 )); then
    e_header "Tapping Homebrew kegs: ${kegs[*]}"
    for keg in "${kegs[@]}"; do
      brew tap "$keg" || return 1
    done
  fi
}

# Install Homebrew recipes.
function brew_install_recipes() {
  recipes=($(setdiff "${recipes[*]}" "$(brew list)"))
  if (( ${#recipes[@]} > 0 )); then
    e_header "Installing Homebrew recipes: ${recipes[*]}"
    for recipe in "${recipes[@]}"; do
      brew install "$recipe" || return 1
    done
  fi
}
