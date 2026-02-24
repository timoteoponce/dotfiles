# AGENTS.md - Dotfiles Repository Guide

## Overview

This is a dotfiles repository using [rcm](https://github.com/thoughtbot/rcm) for management. It contains configuration files for:
- **Fish shell** (`config/fish/`)
- **Git** (`gitconfig`)
- **Tmux** (`tmux.conf`)
- **Neovim/LazyVim** (managed separately at `~/.config/nvim`)
- **IdeaVim** (`ideavimrc`)
- **PostgreSQL** (`psqlrc`)

## Repository Structure

```
.dotfiles/
├── install.sh          # Main installation script
├── gitconfig          # Git configuration with aliases
├── tmux.conf          # Tmux settings
├── vimrc              # Vim configuration (legacy)
├── ideavimrc          # IdeaVim configuration
├── psqlrc             # PostgreSQL client config
├── config/fish/       # Fish shell configuration
│   └── config.fish    # Main fish config with aliases
├── .github/           # GitHub templates
│   └── PULL_REQUEST_TEMPLATE.md
└── README.md
```

## Build/Lint/Test Commands

This is a configuration repository, not a software project. There are no traditional build/test commands.

### Validation Commands

Validate shell scripts before committing:
```bash
# Check shell script syntax
sh -n install.sh

# Validate fish syntax (if fish available)
fish -n config/fish/config.fish

# Validate gitconfig
git config --list --local > /dev/null
```

### Linking/Unlinking Dotfiles

```bash
# Link all dotfiles (uses rcm)
rcup -v

# Unlink dotfiles
rcdn -v

# Link specific dotfile
rcup gitconfig
```

### Testing Changes

After making changes to dotfiles:
1. Restart your terminal or source the config file
2. Test the specific tool (e.g., run `tmux` to test tmux.conf)
3. Verify no errors in the tool's output

For fish: `source config/fish/config.fish`
For git: `git config --list` to verify settings

## Code Style Guidelines

### General Principles

- Use existing conventions in each config file
- Keep configurations minimal and well-organized
- Comment non-obvious settings
- Use consistent indentation (2 spaces for shell/fish, follow file conventions for others)

### Gitconfig

- INI format with sections in `[section]` format
- Use 2-space indentation within sections
- Group related settings together
- Use meaningful aliases (keep them short)
- Example aliases already in use: `ci`, `co`, `df`, `br`, `st`, `lg`

### Fish Shell (config.fish)

- Use `set` for variables, `set -Ux` for universal exports
- Use `alias` for command aliases
- Group related aliases together with comments
- Use descriptive but concise names
- Place interactive-only code in `if status is-interactive` blocks
- Always use double quotes for strings

### Tmux

- Use `#` for comments
- Group related settings with blank lines
- Use `set -g` for global options, `setw` for window options
- Keep settings alphabetical within groups

### Vim/Neovim

- Use double quotes for comments
- Group settings by category with comment headers
- Use meaningful variable names with `g:` prefix for globals
- Keep plugin configurations near their plugin declarations

### Shell Scripts (install.sh)

- Use `#!/usr/bin/env sh` shebang for portability
- Use `set -e` for error handling
- Use functions for logical groupings
- Use lowercase with underscores for function names
- Test all exit paths

### Naming Conventions

- **Files**: Use lowercase with no special characters (e.g., `gitconfig`, `tmux.conf`)
- **Aliases**: Use lowercase, short but descriptive (e.g., `ll`, `lzg`)
- **Functions**: Use lowercase with underscores (e.g., `install_packages`)
- **Variables**: Use uppercase for globals, lowercase for locals

### Error Handling

- Always use `set -e` in shell scripts
- Use `command -v` to check for command availability before using
- Provide meaningful error messages with `echo`
- Return appropriate exit codes (0 for success, 1 for failure)

### Import Conventions

This repository does not use package managers. Dependencies are installed via:
- Homebrew (macOS/Linux)
- The included `install.sh` script

When adding new tools:
1. Add to `install.sh` in the `install_packages` function
2. Add aliases to appropriate config file
3. Update README.md if it's a major tool

## Important Notes

- The `vimrc` is legacy; LazyVim at `~/.config/nvim` is the primary editor config
- Personal information (name, email) is already configured in gitconfig - do not change unless explicitly requested
- This repository is managed with rcm - do NOT manually symlink files
- Test all changes interactively before committing

## LazyVim Configuration

LazyVim is installed separately at `~/.config/nvim/`. It has its own plugin system and configuration. Do not edit LazyVim files from this repository - configure it directly at `~/.config/nvim/`.
