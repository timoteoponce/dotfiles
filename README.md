# Dotfiles

Personal macOS (+ light Linux) setup. Small on purpose.

```bash
git clone https://github.com/timoteoponce/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh          # safe to re-run any time
```

On a NixOS machine, `./install.sh` also applies `nixos/` (see `nixos/README.md`).
Each machine keeps its own `/etc/nixos/hardware-configuration.nix`.
That is the system: KDE, browsers, Podman, Tailscale, Zed, VS Code. Homebrew
and mise still install the shell tools and runtimes. IntelliJ is not installed.

## Two package layers

| Layer | File | What goes here |
|-------|------|----------------|
| **Bootstrap** | `Brewfile` | The shell, GUI casks, fonts — things Homebrew is uniquely good at. Small and stable. |
| **Tools + runtimes** | `mise.toml` → `~/.config/mise/config.toml` | Pinned standalone CLIs (ripgrep, fzf, bat, eza, delta, zoxide, lazygit, lazydocker, neovim) and language runtimes. Cross-platform, version-pinned. |

Update everything: `brew bundle && mise upgrade`.

## What's linked

`install.sh` symlinks individual files (never whole directories, so tool-managed
files like `fish_variables` stay local):

| Repo | Target |
|------|--------|
| `gitconfig` / `gitignore` | `~/.gitconfig` / `~/.gitignore` |
| `tmux.conf`, `ideavimrc`, `psqlrc` | `~/.tmux.conf`, `~/.ideavimrc`, `~/.psqlrc` |
| `aerospace.toml` | `~/.aerospace.toml` |
| `config/fish/{config.fish,conf.d/*,functions/*}` | `~/.config/fish/…` |
| `config/ghostty/config` | `~/.config/ghostty/config` |
| `config/alacritty/alacritty.toml` | `~/.config/alacritty/alacritty.toml` |
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
- `conf.d/10-tools.fish` — brew · mise · zoxide · fzf key bindings
- `conf.d/aliases.fish` — `ls`/`eza`, `cat`/`bat`, `ff`, editor shortcuts
- `conf.d/abbr.fish` — inline-expanding `g*` / `d*` git & docker abbreviations
- `functions/dsh.fish` — fzf-pick a running container and shell into it
- `functions/mkcd.fish` — `mkdir -p` + `cd`

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
