# AGENTS.md — Dotfiles Repository Guide

## Overview

Personal dotfiles for macOS (+ light Linux). Kept deliberately small.

Configs: **fish** (`config/fish/`), **git** (`gitconfig` + `gitignore`), **tmux**
(`tmux.conf`), **Ghostty** (`config/ghostty/`), **lazygit** / **lazydocker**
(`config/`), **bat** (`config/bat/`), **IdeaVim** (`ideavimrc`), **psql** (`psqlrc`).
Neovim/LazyVim lives at `~/.config/nvim` and is **not** managed here.

## Structure

```
.dotfiles/
├── install.sh            # single idempotent installer (brew + mise + symlinks + LazyVim + chsh)
├── Brewfile              # bootstrap layer: fish, git, gh, mise, tmux, ghostty cask, font
├── mise.toml             # tool + runtime layer: pinned CLIs + java/clojure/ruby -> ~/.config/mise/config.toml
├── gitconfig / gitignore # -> ~/.gitconfig / ~/.gitignore
├── tmux.conf             # -> ~/.tmux.conf
├── ideavimrc / psqlrc    # -> ~/.ideavimrc / ~/.psqlrc
└── config/
    ├── fish/{config.fish, conf.d/*.fish, functions/*.fish}
    ├── ghostty/config
    ├── lazygit/config.yml
    ├── lazydocker/config.yml
    └── bat/config
```

## Two package layers

- **Homebrew (`Brewfile`)** — only the shell, GUI casks, font, and a couple of
  stable formulae. Installed with `brew bundle --no-upgrade`.
- **mise (`mise.toml`)** — pinned standalone CLIs (ripgrep, fzf, bat, eza, delta,
  zoxide, lazygit, lazydocker, neovim) plus language runtimes. `mise install`.

## Install / linking

`./install.sh` does everything and is safe to re-run: installed packages are
skipped, correct symlinks are left untouched, and a failing step warns instead of
aborting. It symlinks **individual files** (never whole dirs) so tool-managed
files like `fish_variables` stay local. Existing real files are moved to
`*.bak.<timestamp>` before linking. There is no `rcm` — do not reintroduce it.

## Machine-specific / secret bits (untracked)

- `~/.gitconfig.local` — `user.email`, credential managers, corp hosts. Pulled in
  via `[include]` in `gitconfig`. The tracked `gitconfig` has **no email** on
  purpose; don't add one.
- `~/.config/fish/local.fish` — extra PATH, installer snippets (grok, opencode),
  work aliases, the `try` function. Sourced at the end of `config.fish`.

`install.sh` creates both if missing.

## fish conventions

- `config.fish` stays tiny. Real config is `conf.d/*.fish`, sourced automatically
  in filename order: `00-path` → `10-tools` (brew/mise/zoxide/fzf) → `aliases` → `abbr`.
- `aliases.fish` = wrappers that need flags; `abbr.fish` = inline-expanding
  `g*`/`d*` git & docker abbreviations. Functions go in `functions/`.
- Guard interactive-only code with `status is-interactive; or exit`.
- Prefer `set -gx` over `set -Ux` in tracked files (universal vars persist
  per-machine and can't be reset from the repo).

## git conventions

- INI, 2-space indent within `[section]`.
- `delta` is pager + interactive/diff filter; merge tool is `nvim-merge`.
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

- Reintroduce `rcm`, `vimrc`, or a `vim/` tree (removed — user is on LazyVim).
- Edit LazyVim from this repo (`~/.config/nvim` is separate).
- Put `user.email`, tokens, or corp URLs in tracked files — use `*.local`.
- Add build-artifact patterns to the global `gitignore` (per-project only).
