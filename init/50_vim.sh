# Backups, swaps and undos are stored here.
mkdir -p "$DOTFILES/caches/vim" || return 1

# Ensure vim-plug is present (we don't track plug.vim; .vimrc also installs it on first open).
PLUG_VIM="${DOTFILES}/link/.vim/autoload/plug.vim"
if [[ ! -f "$PLUG_VIM" ]] && [[ "$(type -P curl)" ]]; then
  mkdir -p "$(dirname "$PLUG_VIM")" || return 1
  curl -fLo "$PLUG_VIM" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim || return 1
fi

# Download Vim plugins.
if [[ "$(type -P vim)" ]]; then
  vim +PlugUpgrade +PlugUpdate +qall || return 1
fi

