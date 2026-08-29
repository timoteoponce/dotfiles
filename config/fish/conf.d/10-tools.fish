# Tool initialisation. Order matters: brew -> mise -> everything mise provides.

status is-interactive; or exit

# Homebrew (also sets MANPATH / HOMEBREW_PREFIX / etc.)
if test -x /opt/homebrew/bin/brew
    /opt/homebrew/bin/brew shellenv | source
end

# mise: version manager + the CLI tools in ~/.dotfiles/mise.toml
if type -q mise
    mise activate fish | source
end

# zoxide: `z <dir>` jumps, `zi` picks interactively
if type -q zoxide
    zoxide init fish | source
end

# fzf key bindings: Ctrl-R history, Ctrl-T files, Alt-C cd
if type -q fzf
    fzf --fish | source
end
