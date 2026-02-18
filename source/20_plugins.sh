# load zgenom
source "${HOME}/.zgenom/zgenom.zsh"

# if the init script doesn't exist
if ! zgenom saved; then
  zgenom load p10k-instant-prompt # Speeds up startup time by a lot

  zgenom load zsh-users/zsh-completions            # Extra completions for docker, npm, and more
  zgenom load zsh-users/zsh-autosuggestions        # Suggests commands from history as you type; accept with right-arrow
  zgenom load zsh-users/zsh-syntax-highlighting   # Colors commands green (valid) or red (error) as you type (load last)
  zgenom load chitoku-k/fzf-zsh-completions  # Fuzzy-find and pick from the completion list
  zgenom load unixorn/fzf-zsh-plugin          # fzf keybindings and shell integration (**<Tab>, etc.)
  zgenom load aloxaf/fzf-tab                  # Tab completion via fzf instead of the default menu
  zgenom load djui/alias-tips                      # Hints when an alias exists for the command you just ran

  zgenom load ajeetdsouza/zoxide  # Smarter cd (z <partial path> jumps to freq-used dirs)
  zgenom load toku-sa-n/zsh-dot-up  # dot-up command to update dotfiles from repo

  zgenom load romkatv/powerlevel10k powerlevel10k  # Configurable prompt theme (path, git, time)

  zgenom load unixorn/autoupdate-zgenom

  zgenom save
fi
