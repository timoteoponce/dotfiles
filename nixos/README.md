# NixOS laptop

This directory is the system half of the setup for the Dell Inspiron 3493.
Homebrew, mise, and the shell configs stay in the rest of the repo.

## What the flake installs

- KDE Plasma 6, the current user `timoteo`, fish as the login shell
- Battery policy from `powerdevilrc` (balanced on AC, power-saver on battery)
- Bluetooth, Intel video decode, thermald, fwupd
- Tailscale, with the firewall open. Log in once: `sudo tailscale up`
- Podman, a `docker` command, and `docker compose`, pulling public images from Docker Hub
- Firefox, Brave, Edge, LibreOffice, Spotify, Transmission Qt, Ghostty, Alacritty, Zed, VS Code
- System tools: vim, nano, btop, git, curl. `gh` comes from the Brewfile
- Edge app entries: Teams, Outlook, Calendar, OneDrive, Google Drive

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

The first switch on a system that does not have flakes enabled yet is the same
command. `install.sh` passes the experimental-features flag for you.

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
