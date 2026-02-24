# Dotfiles

Automated dotfiles management using [rcm](https://github.com/thoughtbot/rcm).

## Requirements

- macOS or Linux
- Internet connection (for Homebrew and package installation)

## What's Included

- **vimrc** - Vim configuration with plugins (fzf, vim-airline, etc.)
- **gitconfig** - Git aliases and configuration
- **tmux.conf** - Tmux settings
- **ideavimrc** - IdeaVim configuration
- **psqlrc** - PostgreSQL client configuration
- **config/fish/** - Fish shell configuration
- **config/nvim/** - Neovim configuration (sourced from vimrc)

## Quick Install

```bash
git clone https://github.com/yourusername/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

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
5. **Installs vim plugins** via `:PlugInstall`
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

# Install vim plugins
vim +PlugInstall +qall

# Change shell
chsh -s $(which fish)
```

## Manual Plugin Installation

If you only need to install vim plugins:

```bash
vim +PlugInstall +qall
```
