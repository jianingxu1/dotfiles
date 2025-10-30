# Install Oh My Zsh if not already installed
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  e_header "Installing Oh My Zsh"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  e_success "Oh My Zsh already installed"
fi

# Install Powerlevel10k theme if not already installed
P10K_THEME_DIR="$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
if [[ ! -d "$P10K_THEME_DIR" ]]; then
  e_header "Installing Powerlevel10k theme"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_THEME_DIR"
else
  e_success "Powerlevel10k already installed"
  # Update existing installation
  e_header "Updating Powerlevel10k theme"
  cd "$P10K_THEME_DIR" && git pull
fi

# Ensure zsh is the default shell
if [[ "$SHELL" != "$(which zsh)" ]]; then
  e_header "Setting zsh as default shell"
  chsh -s "$(which zsh)"
  e_success "Zsh set as default shell (restart terminal to take effect)"
fi

# Install useful zsh plugins
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

# zsh-autosuggestions
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
  e_header "Installing zsh-autosuggestions plugin"
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
else
  e_success "zsh-autosuggestions already installed"
fi

# zsh-syntax-highlighting
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
  e_header "Installing zsh-syntax-highlighting plugin"
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
else
  e_success "zsh-syntax-highlighting already installed"
fi

# Install iTerm2 if not already installed (via Homebrew)
if [[ ! -d "/Applications/iTerm.app" ]]; then
  if [[ "$(type -P brew)" ]]; then
    e_header "Installing iTerm2"
    brew install --cask iterm2
  else
    e_error "Homebrew not found. Please install iTerm2 manually or install Homebrew first."
  fi
else
  e_success "iTerm2 already installed"
fi
