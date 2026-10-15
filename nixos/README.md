# NixOS laptop

This directory is the shared system half of the setup. Homebrew, mise, and the
shell configs stay in the rest of the repo. Every NixOS machine that runs
`install.sh` applies the same flake, `laptop`.

Disks, initrd modules, and CPU microcode are not in this repo. The installer
writes those to `/etc/nixos/hardware-configuration.nix`, and the flake reads
that file. A second computer needs its own scan (`sudo nixos-generate-config`).
Do not copy this Inspiron's file onto it.

Machine-only settings go in `/etc/nixos/local.nix`, which the flake imports
when the file exists. See `local.nix.example` for this Inspiron's Wi-Fi,
Intel video decode, and thermald settings.

## What the flake installs

- KDE Plasma 6, the current user `timoteo`, fish as the login shell
- Battery policy from `powerdevilrc` (balanced on AC, power-saver on battery)
- Bluetooth, firmware updates, and graphics. Intel video decode and thermald are in `/etc/nixos/local.nix` on this Inspiron only
- Tailscale. The daemon starts at boot. A reusable auth key in `/etc/nixos/tailscale-authkey` logs the node in whenever it is down. That file is not in git
- Ollama for a remote coding machine, reachable only over Tailscale on port 11434. Pull a model with `ollama pull`
- SSH on port 22, so this user can log in remotely. Root still cannot use a password
- Podman, a `docker` command, and `docker compose`, pulling public images from Docker Hub
- Firefox, Brave, Edge, LibreOffice, Spotify, pCloud, Transmission Qt, Ghostty, Alacritty, Zed, VS Code
- System tools: vim, nano, btop, git, curl. `gh` comes from the Brewfile
- Edge app entries: Teams, Outlook, Calendar, OneDrive, Google Drive, YouTube, WhatsApp, X, Netflix

IntelliJ is not included. Neovim and the other CLI tools stay in `mise.toml`.

`powerdevilrc` is copied over the file in `~/.config` on every rebuild.
Change the copy in this directory when the battery policy should change.

## One command

After this repo is at `~/.dotfiles`:

```bash
~/.dotfiles/install.sh
```

On NixOS that applies this flake, then Homebrew, mise, and the config links.
The first time, `sudo` asks for your password, and the Homebrew installer asks
once more to create the `linuxbrew` user. Log out and back in afterwards so
fish, `nix-ld`, and the Bluetooth tray pick up the new session.

The first switch works even when flakes are not enabled yet. `nixos-rebuild`
turns that feature on for its own Nix calls.

## Publish with GitHub

Before Homebrew is installed, `gh` is not on the system. Use a temporary copy
for the first push:

```bash
nix-shell -p git gh
cd ~/.dotfiles
gh auth login
git push
```

`gh auth login` choices: GitHub.com, HTTPS, and "Login with a web browser".
It prints a one-time code and a URL. Paste the code in the browser while you
are logged in as the owner of `timoteoponce/dotfiles`. Leave the terminal
waiting until it says you are logged in, then `git push`.

Later pushes can be a normal `git push`. This repo's git config uses `gh` as
the credential helper.
