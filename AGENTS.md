# AGENTS.md — Dotfiles Repository Guide

## Overview

Personal dotfiles for macOS (+ light Linux). Kept deliberately small.

Configs: **fish** (`config/fish/`), **git** (`gitconfig` + `gitignore`), **tmux**
(`tmux.conf`), **Ghostty** (`config/ghostty/`), **lazygit** / **lazydocker**
(`config/`), **bat** (`config/bat/`), **IdeaVim** (`ideavimrc`), **psql** (`psqlrc`),
**Neovim** (`config/nvim/`, the one directory symlink).

## Structure

```
.dotfiles/
├── install.sh            # single idempotent installer (mise + symlinks + fish + font + nvim + chsh)
├── mise.toml             # the only package layer: CLIs + java/clojure/ruby -> ~/.config/mise/config.toml
├── gitconfig / gitignore # -> ~/.gitconfig / ~/.gitignore
├── tmux.conf             # -> ~/.tmux.conf
├── ideavimrc / psqlrc    # -> ~/.ideavimrc / ~/.psqlrc
└── config/
    ├── fish/{config.fish, conf.d/*.fish, functions/*.fish}
    ├── ghostty/config
    ├── lazygit/config.yml
    ├── lazydocker/config.yml
    ├── bat/config
    └── nvim/init.lua      # whole directory is symlinked to ~/.config/nvim
```

## One package layer: mise

`mise.toml` holds everything: `gh`, `tmux`, ripgrep, fzf, bat, eza, delta,
zoxide, lazygit, lazydocker, neovim, plus language runtimes. `mise install`.
No Homebrew, no Nix flake — `install.sh` fetches `mise` itself from its GitHub
release into `~/.local/bin`.

Outside mise, and only because it cannot be otherwise:

- **`fish`** — a mise tool on Linux (`os = "linux"`). On macOS `install.sh`
  unpacks the official release `.app` bundle's `usr/local` tree into `~/.local`.
  Both end at `~/.local/bin/fish`, the login shell path `chsh` and `/etc/shells`
  hold, so upgrading fish never invalidates the account record.
- **`git`** — no upstream tarball exists; the OS one pairs with the system
  credential helpers.
- **`xclip`** on Linux — distro package, needed by tmux / Neovim.
- **apps** (Ghostty, …) — never installed here; `config/ghostty/config` is linked
  and the dmg URL lives in the README.

## Refresh on every run

`./install.sh` also moves things forward, each step only when the version really
differs: mise (`self-update`, compared against the newest release tag), the
tools (`mise upgrade`, newest *within each request*, so exact pins like `java`
stay put), fish, and the Nerd Font (stamped at
`${XDG_STATE_HOME:-~/.local/state}/dotfiles/font-version`).

Rules that keep this safe — keep them when editing `install.sh`:

- fail-soft everywhere: a failed refresh warns and keeps the working install
- never replace a working binary before running it once (`fish --version`)
- `DOTFILES_NO_REFRESH=1` skips the whole pass: install-only, offline-friendly

## Install / linking

`./install.sh` does everything and is safe to re-run: installed packages are
skipped, correct symlinks are left untouched, and a failing step warns instead of
aborting. It symlinks **individual files** so tool-managed files like
`fish_variables` stay local. `config/nvim` is the exception: the whole directory
is linked to `~/.config/nvim`. Existing real files are moved to
`*.bak.<timestamp>` before linking. There is no `rcm` — do not reintroduce it.

## Machine-specific / secret bits (untracked)

- `~/.gitconfig.local` — `user.email`, credential managers, corp hosts. Pulled in
  via `[include]` in `gitconfig`. The tracked `gitconfig` has **no email** on
  purpose; don't add one.
- `~/.config/fish/local.fish` — machine-specific PATH, aliases, and work-only
  snippets. Sourced at the end of `config.fish`.

`install.sh` creates both if missing.

## fish conventions

- `config.fish` stays tiny. Real config is `conf.d/*.fish`, sourced automatically
  in filename order: `00-path` → `10-tools` (mise/zoxide/fzf) → `aliases` → `abbr`.
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
mise config >/dev/null                 # linked mise.toml parses
ghostty +show-config >/dev/null        # if ghostty installed
./install.sh                            # must be a no-op on a set-up machine
```

## Don't

- Reintroduce `rcm`, `vimrc`, a `vim/` tree, or LazyVim. Neovim config is `config/nvim/init.lua`.
- Reintroduce Homebrew, a `Brewfile`, `/opt/homebrew` PATH entries, or a Nix
  flake / `nixos/`. mise plus the OS provides everything.
- Put `user.email`, tokens, or corp URLs in tracked files — use `*.local`.
- Add build-artifact patterns to the global `gitignore` (per-project only).
- Track `config/nvim/nvim-pack-lock.json`: Neovim regenerates it through the
  `config/nvim` symlink on every run, so committing it just churns the repo.
  Pin plugin revs there only if reproducibility starts mattering.
