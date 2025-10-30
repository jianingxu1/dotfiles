alias la="ls -la"
alias path='echo $PATH | tr -s ":" "\n"'

alias sconfig="source ~/.zshrc"
alias vconfig="vim ~/.zshrc"
alias svenv="source .venv/bin/activate"

# In Ubuntu, bat is called batcat due to a name clash
if [[ "$(uname -s)" == "Linux" ]]; then
    if [[ ! -e ~/.local/bin/bat && ! -L ~/.local/bin/bat ]]; then
        mkdir -p ~/.local/bin
        ln -s /usr/bin/batcat ~/.local/bin/bat
    fi
fi
# Add syntax highlighting to cat with bat
command -v bat >/dev/null 2>&1 && alias cat='bat --style plain --paging=never'

# Arc
alias af="arc flow"
alias ad="arc diff"
alias ap="arc patch"

# Information
alias gs="git status --short --branch"
alias glog="git log --abbrev-commit --decorate --date=relative --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all"
alias glg="git log --graph --abbrev-commit --decorate --date=relative --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all"

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
