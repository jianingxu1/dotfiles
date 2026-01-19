# CTRL-S to copy the command into clipboard using pbcopy
if [[ "$OSTYPE" =~ ^darwin ]]; then
  export FZF_CTRL_R_OPTS="
    --bind 'ctrl-s:execute-silent(echo -n {2..} | pbcopy)+abort'
    --color header:italic
    --header 'Press CTRL-S to copy command into clipboard'"
fi

# Preview file content using bat (https://github.com/sharkdp/bat)
export FZF_CTRL_T_OPTS="
  --walker-skip .git,node_modules,target
  --preview 'bat -n --color=always {}'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'"

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