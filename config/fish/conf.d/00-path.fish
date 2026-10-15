# PATH entries that should exist in every interactive shell.
# Machine-specific paths belong in ~/.config/fish/local.fish instead.

# ~/.local/bin holds the login shell (install.sh links it) and bin/ scripts.
test -d $HOME/.local/bin; and fish_add_path $HOME/.local/bin