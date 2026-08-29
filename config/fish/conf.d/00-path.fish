# PATH entries that should exist in every interactive shell.
# Machine-specific paths belong in ~/.config/fish/local.fish instead.

for dir in /opt/homebrew/bin /opt/homebrew/sbin $HOME/.local/bin
    test -d $dir; and fish_add_path $dir
end
