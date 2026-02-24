# Dotfiles

Automated dotfiles management using [rcm](https://github.com/thoughtbot/rcm).

## Requirements

- macOS or Linux
- Internet connection (for Homebrew and package installation)

## What's Included

- **gitconfig** - Git aliases and configuration
- **tmux.conf** - Tmux settings
- **ideavimrc** - IdeaVim configuration
- **psqlrc** - PostgreSQL client configuration
- **config/fish/** - Fish shell configuration
- **LazyVim** - Neovim distribution (installed to `~/.config/nvim`)

## Quick Install

```bash
git clone https://github.com/yourusername/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

On first launch of `nvim`, LazyVim will automatically install all plugins.

## What the Installer Does

1. **Detects OS** (macOS or Linux)
2. **Installs Homebrew** (if not already installed)
3. **Installs packages** via Homebrew:
   - `rcm` - dotfiles manager
   - `fish` - shell
   - `mise` - version manager
   - `fzf`, `ripgrep`, `eza`, `bat` - CLI utilities
   - `lazygit`, `lazydocker` - TUI tools
   - `neovim` - text editor
   - `diffmerge` (macOS) / `meld` (Linux) - diff tool
   - JetBrains Mono Nerd Font
4. **Links dotfiles** via `rcup`
5. **Installs LazyVim** (prompts for backup of existing config)
6. **Prompts to change shell** to fish

## Manual Installation

If you prefer to install manually:

```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install packages
brew install rcm fish mise fzf ripgrep eza bat lazygit lazydocker neovim

# Link dotfiles
rcup

# Install LazyVim
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git

# Start neovim to auto-install plugins
nvim
```

## LazyVim Configuration

LazyVim configuration is located in `~/.config/nvim/`. Key files:

- `init.lua` - entry point
- `lua/plugins/` - plugin configuration
- `lua/config/` - user configuration

After installation, refer to [LazyVim docs](https://lazyvim.org) for customization.
