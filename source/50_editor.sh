# Editing

export VISUAL=vim
export EDITOR="$VISUAL"

function q() {
  if [[ -t 0 ]]; then
    $VISUAL "$@"
  else
    # Read from STDIN (and hide the annoying "Reading from stdin..." message)
    $VISUAL - > /dev/null
  fi
}
alias qv="q $DOTFILES/link/.{,g}vimrc +'cd $DOTFILES'"
alias qs="q $DOTFILES"

# For when you have vim on the brain
alias :q=exit
