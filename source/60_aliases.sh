alias la="ls -la"
alias path='echo $PATH | tr -s ":" "\n"'

alias sconfig="source ~/.zshrc"
alias vconfig="vim ~/.zshrc"
alias svenv="source .venv/bin/activate"

# Arc
alias af="arc flow"
alias ad="arc diff"
alias ap="arc patch"

# Information
alias gs="git status --short --branch"
alias glog="git log --pretty=format:'%C(yellow)%h\\ %ad%Cred%d\\ %Creset%s%Cblue\\ [%cn]' --decorate --date=short"

# Navigation
alias gbr="git branch"
alias gco='git checkout'
alias gsw="git switch"

# Commit
alias gad="git add"
alias gco="git commit --verbose"
alias gcm="git commit --message"
alias gcam="git commit --all --message"

# Fixing
alias grt="git restore"
alias gfix="git commit --amend --verbose"
alias grei="git rebase -i"
alias greiall="git rebase -i --root"
alias gcont="git rebase --continue"

alias gd="git diff"
alias gpu="git pull"
