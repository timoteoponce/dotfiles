# AGENTS.md — Dotfiles Repository Guide

## Overview

Personal dotfiles for macOS, with a Linux path that uses the same CLI tools
when they are already installed. Kept deliberately small.

Configs: **fish** (`config/fish/`), **git** (`gitconfig` + `gitignore`), **tmux**
(`tmux.conf`), **Ghostty** (`config/ghostty/`), **Alacritty**
(`config/alacritty/`), **lazygit** / **lazydocker** (`config/`), **bat**
(`config/bat/`), **IdeaVim** (`ideavimrc`), **psql** (`psqlrc`),
**Neovim** (`config/nvim/`, the one directory symlink).

## Structure

```
.dotfiles/
├── install.sh            # idempotent installer (brew + official mise + symlinks + nvim + chsh)
├── Brewfile              # macOS bootstrap: fish, git, gh, tmux, ghostty, alacritty, aerospace, font
├── mise.toml             # CLIs at "latest" -> ~/.config/mise/config.toml
├── gitconfig / gitignore # -> ~/.gitconfig / ~/.gitignore
├── tmux.conf             # -> ~/.tmux.conf
├── ideavimrc / psqlrc    # -> ~/.ideavimrc / ~/.psqlrc
└── config/
    ├── fish/{config.fish, conf.d/*.fish, functions/*.fish}
    ├── ghostty/config
    ├── alacritty/alacritty.toml
    ├── lazygit/config.yml
    ├── lazydocker/config.yml
    ├── bat/config
    └── nvim/init.lua      # whole directory is symlinked to ~/.config/nvim
```

## Packages

- **Homebrew (`Brewfile`)** — macOS installs Homebrew when it is missing, then
  `brew bundle --no-upgrade`. Formulae: fish, git, gh, tmux. Casks: Ghostty,
  Alacritty, Aerospace, JetBrainsMono Nerd Font. The Alacritty cask is disabled
  upstream (Gatekeeper, 2026-09-01); bundle warns and continues. Do not add a tap.
- **Linux** — Homebrew runs only when `fish`, `git`, `gh`, or `tmux` is missing,
  and then installs only those formulae. No casks.
- **mise** — the official `https://mise.run` binary at `~/.local/bin/mise`.
  Never a Homebrew formula (that formula's fish hook hardcodes its own binary).
  `mise.toml` tracks `latest` for neovim, ripgrep, fzf, bat, eza, zoxide,
  lazygit, lazydocker, and usage. Language runtimes are per-project, commented
  examples only.

## Install / linking

`./install.sh` is safe to re-run: installed packages are skipped, correct
symlinks are left untouched, and a failing step warns instead of aborting.
It symlinks **individual files** so tool-managed files like `fish_variables`
stay local. `config/nvim` is the exception: the whole directory is linked to
`~/.config/nvim`. Existing real files are moved to `*.bak.<timestamp>` before
linking. There is no `rcm` — do not reintroduce it.

The first run on a new machine asks for git `user.name` and `user.email` and
writes them with `git config --file ~/.gitconfig.local`. Later runs ask only
for a value that is still empty. No TTY: it warns and continues.

## Machine-specific / secret bits (untracked)

- `~/.gitconfig.local` — `user.name`, `user.email`, credential managers, corp
  hosts. Pulled in via `[include]` in `gitconfig`. The tracked `gitconfig` has
  **no name and no email** on purpose; don't add either.
- `~/.config/fish/local.fish` — machine-specific PATH, aliases, and work-only
  snippets. Sourced at the end of `config.fish`.

`install.sh` creates both if missing. It does not edit an existing `local.fish`.

## fish conventions

- `config.fish` stays tiny. Real config is `conf.d/*.fish`, sourced automatically
  in filename order: `00-path` (`~/.local/bin`) → `10-tools` (brew shellenv for
  `/opt/homebrew`, `/usr/local`, or Linuxbrew, then mise, for every shell;
  zoxide and fzf only when interactive) → `aliases` → `abbr`.
- `aliases.fish` = wrappers that need flags; `abbr.fish` = inline-expanding
  `g*`/`d*` git & docker abbreviations. Functions go in `functions/`.
- Guard interactive-only code with `status is-interactive; or exit`. brew and
  mise stay above that guard.
- Prefer `set -gx` and `fish_add_path -g` over universal variables. Universal
  vars persist per-machine and can't be reset from the repo. `local.fish` should
  use `-g` too; then `set -eU fish_user_paths` once.

## git conventions

- INI, 2-space indent within `[section]`.
- Pager is `less`. Merge tool is `nvim-merge`. tmux copy is OSC 52
  (`copy-selection-and-cancel`), not an external clipboard program.
- Keep aliases short (`ci`, `co`, `df`, `st`, `lg`, `undo`).

## Validation before committing

```bash
sh -n install.sh
fish -n config/fish/config.fish        # and conf.d/*.fish, functions/*.fish
git config --file gitconfig --list >/dev/null
ghostty +show-config >/dev/null        # if ghostty installed
./install.sh                            # must be a no-op on a set-up machine
```

## Don't

- Reintroduce `rcm`, `vimrc`, a `vim/` tree, LazyVim, NixOS, or a Homebrew mise formula.
- Put `user.name`, `user.email`, tokens, or corp URLs in tracked files — use `*.local`.
- Add build-artifact patterns to the global `gitignore` (per-project only).
- Install xclip or point tmux copy at a clipboard CLI. OSC 52 is the clipboard path.
