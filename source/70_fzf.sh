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
