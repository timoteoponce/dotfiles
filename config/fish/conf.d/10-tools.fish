# Tool initialisation. brew and mise run for every shell so `fish -c` can see
# them. zoxide and fzf are interactive-only.

if test -x /opt/homebrew/bin/brew
    /opt/homebrew/bin/brew shellenv | source
else if test -x /usr/local/bin/brew
    /usr/local/bin/brew shellenv | source
else if test -x /home/linuxbrew/.linuxbrew/bin/brew
    /home/linuxbrew/.linuxbrew/bin/brew shellenv | source
end

if test -x $HOME/.local/bin/mise
    $HOME/.local/bin/mise activate fish | source
else if type -q mise
    mise activate fish | source
end

# Default editor for every fish, so `fish -c` and tools that shell out see it.
set -gx EDITOR nvim
set -gx VISUAL nvim

status is-interactive; or exit

# zoxide: `z <dir>` jumps, `zi` picks interactively
if type -q zoxide
    zoxide init fish | source
end

# fzf key bindings: Ctrl-R history, Ctrl-T files, Alt-C cd
if type -q fzf
    fzf --fish | source
end
