if [[ ! -z "$DEVPOD_NAME" ]]; then
    # Install latest version on devpod
    if [[ ! -f "$HOME/.fzf.zsh" ]]; then
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        echo "y y n " | tr ' ' '\n' | ~/.fzf/install
    fi
    export FZF_PATH="$HOME/.fzf"
    export PATH="$HOME/.fzf/bin:$PATH"
    source "$HOME/.fzf.zsh"
fi

source <(fzf --zsh)