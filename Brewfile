# Bootstrap layer. CLIs with standalone binaries live in mise.toml.
# mise itself is installed by install.sh from https://mise.run, not here.
# Run: brew bundle --file Brewfile

brew "fish"   # login shell: macOS does not ship one
brew "git"
brew "gh"     # GitHub auth + git credential helper
brew "tmux"

cask "ghostty"
cask "alacritty" # upstream cask is disabled (Gatekeeper, 2026-09-01); bundle warns and continues
cask "aerospace" # tiling window manager
cask "font-jetbrains-mono-nerd-font"

# Docker runtime is intentionally not managed here.
# Install Docker Desktop, OrbStack, or: brew install colima docker docker-compose
