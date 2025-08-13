# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install all the applications, casks, taps, and dependencies listed within Brewfile
brew bundle

# Create symlinks of your .dotfiles into ~ directory
stow .
