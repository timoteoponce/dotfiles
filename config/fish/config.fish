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
#
# homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"
# mise
mise activate fish | source

# The following snippet is meant to be used like this in your fish config:
#
# if status is-interactive
#     # Configure auto-attach/exit to your likings (default is off).
#     # set ZELLIJ_AUTO_ATTACH true
#     # set ZELLIJ_AUTO_EXIT true
#     eval (zellij setup --generate-auto-start fish | string collect)
# end
if not set -q ZELLIJ
    if test "$ZELLIJ_AUTO_ATTACH" = "true"
        zellij attach -c
    else
        zellij
    end

    if test "$ZELLIJ_AUTO_EXIT" = "true"
        kill $fish_pid
    end
end
