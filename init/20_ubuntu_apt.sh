# Ubuntu specific configuration
is_ubuntu || return 0

sudo apt update || { e_error "apt update failed"; return 1; }
xargs sudo apt install --assume-yes < "$DOTFILES/conf/packages/apt" || return 1
