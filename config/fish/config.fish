if status is-interactive
    # Commands to run in interactive sessions can go here
end

set -Ux EDITOR vim

#
# useful aliases
#
alias ls="ls --color=auto"
# File system
alias ls='eza -lh --group-directories-first --icons'
alias lsa='ls -a'
alias lt='eza --tree --level=2 --long --icons --git'
alias lta='lt -a'
alias ff="fzf --preview 'bat --style=numbers --color=always {}'"
# Directories
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias n='nvim'
alias lzg='lazygit'
alias lzd='lazydocker'
#
# homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"
# mise
mise activate fish | source

#tmux new-session -A -s mySession
