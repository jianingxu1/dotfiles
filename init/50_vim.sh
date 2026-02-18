# Backups, swaps and undos are stored here.
mkdir -p $DOTFILES/caches/vim

# Ensure vim-plug is present (we don't track plug.vim; .vimrc also installs it on first open).
PLUG_VIM="${DOTFILES}/link/.vim/autoload/plug.vim"
if [[ ! -f "$PLUG_VIM" ]] && [[ "$(type -P curl)" ]]; then
  mkdir -p "$(dirname "$PLUG_VIM")"
  curl -fLo "$PLUG_VIM" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

# Download Vim plugins.
if [[ "$(type -P vim)" ]]; then
  vim +PlugUpgrade +PlugUpdate +qall
fi

