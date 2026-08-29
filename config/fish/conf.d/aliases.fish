# Aliases: wrappers that need flags. Short verbs live in abbr.fish instead.

status is-interactive; or exit

if type -q eza
    alias ls 'eza -lh --group-directories-first --icons'
    alias lsa 'eza -lah --group-directories-first --icons'
    alias lt 'eza --tree --level=2 --long --icons --git'
    alias lta 'eza --tree --level=2 --long --all --icons --git'
end

if type -q bat
    alias cat 'bat --paging=never'
end

if type -q fzf
    alias ff "fzf --preview 'bat --style=numbers --color=always {}'"
end

alias e $EDITOR
alias n nvim
alias lzg lazygit
alias lzd lazydocker
