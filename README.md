# Dotfiles

Personal macOS (+ light Linux) setup. Small on purpose.

```bash
git clone https://github.com/timoteoponce/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh          # safe to re-run any time
```

## One package layer: mise

`mise.toml` → `~/.config/mise/config.toml` is the only place packages come from.
It holds the CLI tools (`gh`, `tmux`, `neovim`, `ripgrep`, `fzf`, `bat`, `eza`,
`delta`, `zoxide`, `lazygit`, `lazydocker`) and the language runtimes. There is
no Homebrew here; `install.sh` puts `mise` itself in `~/.local/bin` from its
GitHub release, then runs `mise install`.

## Runs also refresh

Every `./install.sh` moves things to their newest version when that is actually
different, and only then:

| What | How |
|------|-----|
| mise | `mise self-update`, after comparing `mise --version` to the newest release |
| the tools in `mise.toml` | `mise upgrade` — newest *within each request*, so an exact pin like `java` stays put |
| fish | Linux: re-points `~/.local/bin/fish`. macOS: re-unpacks the bundle, after checking the new binary runs |
| the Nerd Font | re-downloaded when the upstream tag moves |

Every step is fail-soft: a failed refresh warns and keeps what you have, and a
downloaded fish is never allowed to replace a working login shell before it has
been run once. `DOTFILES_NO_REFRESH=1 ./install.sh` skips the refresh entirely
and only fills in what is missing.

Knobs: `MISE_VERSION=…`, `FISH_VERSION=…` (pin for one run, and force the
reinstall), `DOTFILES_SKIP_FONT=1`, `DOTFILES_YES=1` (no prompt).

Two tools are deliberately outside that flow:

- **`fish` on macOS.** Upstream ships no macOS tarball, only a `.app` bundle, so
  `install.sh` downloads the bundle and unpacks its relocatable `usr/local` tree
  into `~/.local`. On Linux, fish is a mise tool (`os = "linux"` in
  `mise.toml`). Either way the login shell is the fixed path `~/.local/bin/fish`.
- **`git`.** No upstream git tarball exists, and the OS one is the one that pairs
  with the system credential helpers. macOS: `xcode-select --install`. Linux:
  your package manager.

The rest comes from the OS: `curl`, `tar`, a C toolchain if a runtime builds
from source. On Linux, install `xclip` (or `xsel` / `wl-clipboard`) for tmux and
Neovim clipboard support; `install.sh` prints the command if it finds none.

## macOS extras

- **JetBrains Mono Nerd Font** — installed by `install.sh` into `~/Library/Fonts`
  on macOS, `~/.local/share/fonts` on Linux.
- **Ghostty** — apps are not installed here. Download
  `https://release.files.ghostty.org/1.3.1/Ghostty.dmg`, drag it to
  `/Applications`; the app updates itself afterwards. Its config is already
  linked.

Docker is intentionally not managed. Use Docker Desktop, OrbStack, or your
distro's package manager (`colima`, `docker`, `docker-compose`).

## What's linked

`install.sh` symlinks individual files (never whole directories, so tool-managed
files like `fish_variables` stay local):

| Repo | Target |
|------|--------|
| `gitconfig` / `gitignore` | `~/.gitconfig` / `~/.gitignore` |
| `tmux.conf`, `ideavimrc`, `psqlrc` | `~/.tmux.conf`, `~/.ideavimrc`, `~/.psqlrc` |
| `config/fish/{config.fish,conf.d/*,functions/*}` | `~/.config/fish/…` |
| `config/ghostty/config` | `~/.config/ghostty/config` |
| `config/lazygit/config.yml` | `~/.config/lazygit/config.yml` |
| `config/lazydocker/config.yml` | `~/.config/lazydocker/config.yml` |
| `config/bat/config` | `~/.config/bat/config` |
| `mise.toml` | `~/.config/mise/config.toml` |

Existing real files are backed up to `*.bak.<timestamp>` before linking.

## Machine-specific bits (not tracked)

The installer creates these empty; put anything host- or work-specific in them:

- `~/.gitconfig.local` — corp hosts, credential managers (`git-credential-manager`, etc.)
- `~/.config/fish/local.fish` — machine-specific `PATH`, aliases, and work-only snippets

## fish

- `conf.d/00-path.fish` — PATH
- `conf.d/10-tools.fish` — mise · zoxide · fzf key bindings
- `conf.d/aliases.fish` — `ls`/`eza`, `cat`/`bat`, `ff`, editor shortcuts
- `conf.d/abbr.fish` — inline-expanding `g*` / `d*` git & docker abbreviations
- `functions/dsh.fish` — fzf-pick a running container and shell into it
- `functions/mkcd.fish` — `mkdir -p` + `cd`

The login shell is always the fixed path `~/.local/bin/fish`, so a fish upgrade
never invalidates `chsh`. If you run `mise upgrade fish` by hand, re-run
`./install.sh` to re-point that symlink.

## git

`delta` is the pager and diff/interactive filter (side-by-side, line numbers,
navigate with `n`/`N`). Merge tool is `nvimdiff`. `rerere`, rebase autosquash +
autostash on. GitHub auth via `gh`.

## Neovim

`config/nvim` is the whole config, linked to `~/.config/nvim`. Leader is `,`.

- `,f` files, `,b` buffers, `,/` search (Telescope)
- `,e` folder tree, hidden until then (nvim-tree)
- `,r` search and replace across files, with a preview
- `,t` cycle a few built-in colorschemes

Neovim's own syntax handles highlighting, including Markdown. Autocomplete is off.
Plugins install through Neovim 0.12's `vim.pack` the first time `nvim` runs.
`mise install` provides that Neovim on macOS and other Linux too. An older
`nvim` still opens files; it just skips the plugins.