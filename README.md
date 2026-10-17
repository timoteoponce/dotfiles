# Dotfiles

Personal macOS setup, plus Linux when the CLI tools are already there. Small on purpose.

```bash
git clone https://github.com/timoteoponce/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh          # safe to re-run any time
```

On first run the script asks for your git name and email and writes them to
`~/.gitconfig.local`. A re-run asks only for a value that is still missing.

## What gets installed

| | macOS | Linux |
| --- | --- | --- |
| Homebrew | Installed if missing, then `brew bundle` | Only if `fish`, `git`, `gh`, or `tmux` is missing. Then just those formulae |
| fish, git, gh, tmux | Homebrew formulae | Distro packages, or Homebrew for the ones that are missing |
| Ghostty, Aerospace, JetBrainsMono Nerd Font | Homebrew casks | Not installed (casks are macOS-only) |
| Alacritty | Cask. Homebrew disabled the official cask on 2026-09-01 (Gatekeeper). `brew bundle` warns and continues | Not installed |
| mise | Official binary at `~/.local/bin/mise` (`https://mise.run`). On Linux that build is the static one | Same |

`mise.toml` tracks `latest` for the CLIs: neovim, ripgrep, fzf, bat, eza, zoxide, lazygit, lazydocker, usage. Language runtimes are not global. Put java, clojure, ruby, node, python, or go in a project's own `mise.toml`.

Update the casks and formulae with `brew bundle`. Update the CLIs with `mise upgrade`.

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

`config/nvim` is the exception: the whole directory is linked to `~/.config/nvim`.
Existing real files are backed up to `*.bak.<timestamp>` before linking.

## Machine-specific bits (not tracked)

- `~/.gitconfig.local` — `user.name`, `user.email`, corp hosts, credential managers. `install.sh` creates it and prompts for the name and email.
- `~/.config/fish/local.fish` — machine-specific `PATH`, aliases, and work-only snippets.

`fish_add_path` without `-g` stores paths in the universal variable `fish_user_paths`, which this repo cannot reset. Tracked config uses `fish_add_path -g`. In `local.fish`, do the same, then once:

```fish
set -eU fish_user_paths
```

## fish

- `conf.d/00-path.fish` — `~/.local/bin`
- `conf.d/10-tools.fish` — `brew shellenv` (Apple Silicon, Intel, or Linuxbrew), mise for every shell, then zoxide and fzf in interactive shells
- `conf.d/aliases.fish` — `ls`/`eza`, `cat`/`bat`, `ff`, editor shortcuts
- `conf.d/abbr.fish` — inline-expanding `g*` / `d*` git & docker abbreviations
- `functions/dsh.fish` — fzf-pick a running container and shell into it
- `functions/mkcd.fish` — `mkdir -p` + `cd`

## git

Pager is `less`. Merge tool is `nvim-merge`. `rerere`, rebase autosquash and
autostash are on. GitHub auth is `gh`. Copy in tmux goes through the terminal
(OSC 52), which Ghostty accepts. Alacritty has OSC 52 copy and paste turned on.

## Neovim

`config/nvim` is the whole config, linked to `~/.config/nvim`. Leader is `,`.

- `,f` files, `,b` buffers, `,/` search (Telescope)
- `,e` folder tree, hidden until then (nvim-tree)
- `,r` search and replace across files, with a preview
- `,t` cycle a few built-in colorschemes

Neovim's own syntax handles highlighting, including Markdown. Autocomplete is off.
Plugins install through Neovim 0.12's `vim.pack` the first time `nvim` runs.
`mise install` provides that Neovim. An older `nvim` still opens files; it just
skips the plugins.
