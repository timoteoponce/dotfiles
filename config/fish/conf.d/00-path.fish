# PATH for every fish, interactive or not.
# Homebrew's prefix comes from `brew shellenv` in 10-tools.fish, which covers
# Apple Silicon, Intel, and Linuxbrew. Machine-specific paths belong in
# ~/.config/fish/local.fish.
#
# -g writes a global variable for this session. fish_add_path without it stores
# a universal fish_user_paths, which this repo cannot reset.

if test -d $HOME/.local/bin
    fish_add_path -g $HOME/.local/bin
end
