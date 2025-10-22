source "${HOME}/.zgenom/zgenom.zsh"

if ! zgenom saved; then
  zgenom ohmyzsh

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

  # Save all to init script
  zgenom save

  # Compile your zsh files
  zgenom compile "$HOME/.zshrc"

  # You can perform other "time consuming" maintenance tasks here as well.
  # If you use `zgenom autoupdate` you're making sure it gets
  # executed every 7 days.
fi
