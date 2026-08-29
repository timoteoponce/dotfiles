# Dotfiles

Personal macOS (+ light Linux) setup. Small on purpose.

```bash
git clone https://github.com/timoteoponce/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

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
- `~/.config/fish/local.fish` — extra `PATH`, installer snippets (grok, opencode…), work aliases

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

LazyVim lives in `~/.config/nvim` and is **not** managed by this repo — clone it
once (the installer does, if absent) and manage it on its own.
