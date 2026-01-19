# Ubuntu specific configuration
is_ubuntu || return 1

sudo apt update || { e_error "apt update failed"; return 1; }
cat "$DOTFILES/conf/packages/apt" | xargs sudo apt install --assume-yes