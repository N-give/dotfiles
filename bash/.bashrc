shopt -s checkwinsize

TERM=xterm-256color
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

alias v="nvim"
alias grep="grep --color=auto"
alias gs="git status"
alias zj="zellij"

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

bind '"\e[A":history-search-backward'
bind '"\e[B":history-search-forward'

export EDITOR=nvim

set -o vi

eval "$(direnv hook bash)"
eval "$(starship init bash)"
eval "$(zoxide init bash)"
