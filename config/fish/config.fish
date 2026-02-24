if status is-interactive
    # Commands to run in interactive sessions can go here
end

set EDITOR nvim
set -Ux EDITOR nvim

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
alias e="$EDITOR"
#
# homebrew
if test -x /opt/homebrew/bin/brew
    eval "$(/opt/homebrew/bin/brew shellenv)"
else if test -x /home/linuxbrew/.linuxbrew/bin/brew
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
end
# mise
mise activate fish | source

# try - experiment directories
try init fish | source
