if [[ -n "$ZSH_ZGENOM_PLUGINS_LOADED" ]]; then
  return
fi
ZSH_ZGENOM_PLUGINS_LOADED=1

ZGENOM_DIR="${ZGENOM_DIR:-$HOME/.zgenom}"
ZGENOM_PATH="$ZGENOM_DIR/zgenom.zsh"

if [[ ! -r "$ZGENOM_PATH" ]]; then
  return
fi

source "$ZGENOM_PATH"

if ! zgenom saved; then
  zgenom ohmyzsh
  zgenom load zsh-users/zsh-autosuggestions
  zgenom load zsh-users/zsh-syntax-highlighting
  zgenom load djui/alias-tips
  zgenom load zsh-users/zsh-completions
  zgenom load unixorn/fzf-zsh-plugin
  zgenom load chitoku-k/fzf-zsh-completions
  zgenom load toku-sa-n/zsh-dot-up
  zgenom save
fi
