source "${HOME}/.zgenom/zgenom.zsh"

# Check for plugin and zgenom updates every 7 days
# This does not increase the startup time.
zgenom autoupdate

if ! zgenom saved; then
  zgenom ohmyzsh

  # Check for zgenom AND plugin updates every 7 days
  zgenom load unixorn/autoupdate-zgenom

  # Completions
  zgenom load unixorn/fzf-zsh-plugin
  zgenom ohmyzsh plugins/fzf
  zgenom ohmyzsh plugins/command-not-found  # Provide suggested packages to be installed if a command cannot be found
  zgenom load zsh-users/zsh-autosuggestions
  zgenom load zsh-users/zsh-completions
  zgenom load chitoku-k/fzf-zsh-completions
  zgenom ohmyzsh plugins/bazel

  # Navigation
  zgenom ohmyzsh plugins/zoxide # Smarter cd command
  zgenom load toku-sa-n/zsh-dot-up  # Quickly navigate up directories in the file system
  ## IMPORTANT: zsh-dot-up has to be loaded before zsh-syntax-highlighting

  zgenom load zsh-users/zsh-syntax-highlighting  # Provides CLI syntax highlighting

  # Setup eget to download core apps
  test -d "$HOME/bin" || mkdir -p "$HOME/bin"
  command -v eget > /dev/null 2>&1 || (bash "$DOTFILES/scripts/eget.sh" && mv $HOME/eget $HOME/bin/)

  # Install core apps using eget
  command -v zoxide > /dev/null 2>&1 || eget ajeetdsouza/zoxide
  command -v bat > /dev/null 2>&1 || eget sharkdp/bat

  # Execute commands which are dependent on the binaries being available
  if (( $+commands[zoxide] )); then
    zgenom eval --name zoxide <<(zoxide init zsh --cmd cd)
  fi

  # Save all to init script
  zgenom save

  # Compile your zsh files
  zgenom compile "$HOME/.zshrc"

  # You can perform other "time consuming" maintenance tasks here as well.
  # If you use `zgenom autoupdate` you're making sure it gets
  # executed every 7 days.
fi