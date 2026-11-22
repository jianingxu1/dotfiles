# Load zgenom from the checkout, including before home symlinks are installed.
source "$DOTFILES/link/.zgenom/zgenom.zsh" || return 1

# Rebuild the saved plugin setup when this file changes.
ZGEN_RESET_ON_CHANGE=("$DOTFILES/source/20_plugins.sh")

# Existing shells keep their loaded plugins until the next fresh shell.
[[ -z "$ZGENOM_PLUGINS" ]] || return 0

# Migrate older saved setups that do not watch configuration changes.
if [[ -f "$ZGEN_INIT" ]] && ! command grep -q ZGEN_RESET_ON_CHANGE "$ZGEN_INIT"; then
  zgenom reset || return 1
fi

# Zgenom owns the framework and theme; Oh My Zsh initializes completions once.
unset ZSH
ZSH_THEME=""
plugins=(git)
zstyle ':omz:update' mode disabled
ZGEN_AUTOLOAD_COMPINIT=0

# If the init script doesn't exist, build it in dependency order.
if ! zgenom saved; then
  zgenom load zsh-users/zsh-completions || return 1  # Extra completions for docker, npm, and more
  zgenom ohmyzsh || return 1

  # Install fzf widgets before fzf-tab wraps them, and before highlighting.
  zgenom load "$DOTFILES/conf/zsh/fzf.zsh" || return 1
  zgenom load aloxaf/fzf-tab || return 1  # Tab completion via fzf instead of the default menu
  zgenom load djui/alias-tips || return 1  # Hints when an alias exists for the command you just ran
  zgenom load ajeetdsouza/zoxide || return 1  # Smarter cd (z <partial path> jumps to freq-used dirs)
  zgenom load toku-sa-n/zsh-dot-up || return 1  # dot-up command to update dotfiles from repo
  zgenom load romkatv/powerlevel10k powerlevel10k || return 1  # Configurable prompt theme (path, git, time)
  zgenom load unixorn/autoupdate-zgenom || return 1

  zgenom load zsh-users/zsh-autosuggestions || return 1  # Suggests commands from history as you type; accept with right-arrow
  zgenom load zsh-users/zsh-syntax-highlighting || return 1  # Colors commands green (valid) or red (error) as you type (load last)
  zgenom save
fi
