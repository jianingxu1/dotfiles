rtmux() {
    case "$2" in
        "") autossh -M 0 $1 -t "if tmux -qu has; then tmux -qu attach; else EDITOR=emacs tmux -qu new; fi";;
        *) autossh -M 0 $1 -t "if tmux -qu has -t $2; then tmux -qu attach -t $2; else EDITOR=emacs tmux -qu new -s $2; fi";;
    esac
}