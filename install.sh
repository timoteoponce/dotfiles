#!/usr/bin/env sh
#
# Idempotent installer. Safe to run as many times as you like:
#   - already-installed packages are skipped
#   - correct symlinks are left untouched
#   - a step that fails warns and the rest still runs
#
# macOS: install Homebrew if it is missing, then brew bundle (fish, git, gh,
# tmux, and the casks).
# Linux: Homebrew is only installed when fish, git, gh, or tmux is missing.
# mise is always the official binary at ~/.local/bin/mise, never a brew formula.
#
# Env:
#   DOTFILES_YES=1   answer "yes" to the shell-change prompt (non-interactive)

DOTFILES_DIR="$HOME/.dotfiles"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

info() { printf '\033[1;34m==>\033[0m %s\n' "$1"; }
warn() { printf '\033[1;33m!!\033[0m  %s\n' "$1" >&2; }

detect_os() {
  case "$(uname -s)" in
    Darwin) echo "macos" ;;
    Linux) echo "linux" ;;
    *) echo "unsupported" ;;
  esac
}

login_shell() {
  case "$(detect_os)" in
    macos) dscl . -read "/Users/$(id -un)" UserShell 2>/dev/null | awk '{print $2}' ;;
    linux) getent passwd "$(id -un)" 2>/dev/null | cut -d: -f7 ;;
  esac
}

# Apple Silicon, Intel, then Linux. A custom prefix already on PATH still works.
load_brew_env() {
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  elif [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  elif command -v brew >/dev/null 2>&1; then
    eval "$(brew shellenv)"
  fi
}

install_homebrew() {
  load_brew_env
  if command -v brew >/dev/null 2>&1; then
    info "Homebrew present"
    return 0
  fi
  info "Installing Homebrew..."
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
    warn "Homebrew install failed"
    return 1
  }
  load_brew_env
  if ! command -v brew >/dev/null 2>&1; then
    warn "Homebrew installed but not on PATH"
    return 1
  fi
  return 0
}

# Drop the Homebrew formula so its fish vendor hook cannot shadow ~/.local/bin/mise.
remove_brew_mise() {
  command -v brew >/dev/null 2>&1 || return 0
  brew list --formula mise >/dev/null 2>&1 || return 0
  info "Removing Homebrew mise"
  brew uninstall mise || warn "could not uninstall Homebrew mise"
}

# Ask for the sudo password once and keep the timestamp fresh until we exit.
SUDO_READY=""
ensure_sudo() {
  [ -n "$SUDO_READY" ] && return 0
  [ "$(id -u)" = "0" ] && { SUDO_READY=1; return 0; }
  command -v sudo >/dev/null 2>&1 || return 1
  [ -t 0 ] || sudo -n true 2>/dev/null || return 1
  sudo -v || return 1
  SUDO_READY=1
  ( while kill -0 "$$" 2>/dev/null; do sudo -n true 2>/dev/null; sleep 50; done ) &
}

# Nerd Font so eza/ls icons render. macOS gets it from the Brewfile cask.
install_font() {
  [ "$(detect_os)" = "linux" ] || return 0
  fonts_dir="$HOME/.local/share/fonts/JetBrainsMonoNerdFont"
  if ls "$fonts_dir"/*.ttf >/dev/null 2>&1; then
    info "JetBrainsMono Nerd Font present"
    return 0
  fi
  info "Installing JetBrainsMono Nerd Font..."
  tmp="$(mktemp -d)"
  if curl -fsSL -o "$tmp/font.tar.xz" \
      https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz \
    && mkdir -p "$fonts_dir" \
    && tar -xJf "$tmp/font.tar.xz" -C "$fonts_dir" --wildcards '*.ttf'; then
    command -v fc-cache >/dev/null 2>&1 && fc-cache -f "$HOME/.local/share/fonts" >/dev/null 2>&1
    info "Font installed. Set your terminal font to 'JetBrainsMono Nerd Font'."
  else
    warn "Nerd Font install failed"
  fi
  rm -rf "$tmp"
}

brew_packages() {
  if [ "$(detect_os)" = "macos" ]; then
    command -v brew >/dev/null 2>&1 || ensure_sudo || true
    install_homebrew || { warn "skipping brew bundle"; remove_brew_mise; return; }
    info "Installing packages from Brewfile..."
    # --no-upgrade: re-runs only install what's missing.
    brew bundle --file "$DOTFILES_DIR/Brewfile" --no-upgrade || warn "brew bundle reported errors"
  else
    missing=""
    for cmd in fish git gh tmux; do
      command -v "$cmd" >/dev/null 2>&1 || missing="$missing $cmd"
    done
    if [ -z "$missing" ]; then
      info "fish, git, gh, and tmux present; skipping Homebrew"
    else
      info "Missing CLI tools:$missing"
      command -v brew >/dev/null 2>&1 || load_brew_env
      command -v brew >/dev/null 2>&1 || ensure_sudo || true
      if install_homebrew; then
        for cmd in fish git gh tmux; do
          command -v "$cmd" >/dev/null 2>&1 && continue
          info "Installing $cmd..."
          brew install "$cmd" || warn "$cmd install failed"
        done
      else
        warn "Install these yourself:$missing"
      fi
    fi
  fi
  remove_brew_mise
}

# link_file <repo-relative-src> <absolute-dest>
link_file() {
  src="$DOTFILES_DIR/$1"
  dest="$2"
  [ -e "$src" ] || { warn "missing $src"; return; }
  mkdir -p "$(dirname "$dest")"

  if [ -L "$dest" ]; then
    [ "$(readlink "$dest")" = "$src" ] && return   # already correct
    rm "$dest"
  elif [ -e "$dest" ]; then
    backup="$dest.bak.$(date +%s)"
    mv "$dest" "$backup"
    info "backed up $dest -> $(basename "$backup")"
  fi

  ln -s "$src" "$dest" && printf '  linked %s\n' "$dest"
}

link_dotfiles() {
  info "Linking dotfiles..."

  link_file gitconfig      "$HOME/.gitconfig"
  link_file gitignore      "$HOME/.gitignore"
  link_file tmux.conf      "$HOME/.tmux.conf"
  link_file ideavimrc      "$HOME/.ideavimrc"
  link_file psqlrc         "$HOME/.psqlrc"
  link_file aerospace.toml "$HOME/.aerospace.toml"
  link_file mise.toml      "$CONFIG_HOME/mise/config.toml"

  # fish: link individual files so fish's own runtime files stay local
  link_file config/fish/config.fish "$CONFIG_HOME/fish/config.fish"
  for f in "$DOTFILES_DIR"/config/fish/conf.d/*.fish; do
    link_file "config/fish/conf.d/$(basename "$f")" "$CONFIG_HOME/fish/conf.d/$(basename "$f")"
  done
  for f in "$DOTFILES_DIR"/config/fish/functions/*.fish; do
    link_file "config/fish/functions/$(basename "$f")" "$CONFIG_HOME/fish/functions/$(basename "$f")"
  done

  link_file config/ghostty/config        "$CONFIG_HOME/ghostty/config"
  link_file config/alacritty/alacritty.toml "$CONFIG_HOME/alacritty/alacritty.toml"
  link_file config/lazygit/config.yml    "$CONFIG_HOME/lazygit/config.yml"
  link_file config/lazydocker/config.yml "$CONFIG_HOME/lazydocker/config.yml"
  link_file config/bat/config            "$CONFIG_HOME/bat/config"
  link_file config/containers/registries.conf "$CONFIG_HOME/containers/registries.conf"

  # personal scripts -> ~/.local/bin (on PATH; git auto-discovers git-* as subcommands)
  for f in "$DOTFILES_DIR"/bin/*; do
    [ -e "$f" ] || continue
    link_file "bin/$(basename "$f")" "$HOME/.local/bin/$(basename "$f")"
  done
}

ensure_local_files() {
  if [ ! -e "$CONFIG_HOME/fish/local.fish" ]; then
    mkdir -p "$CONFIG_HOME/fish"
    printf '%s\n' '# Machine-specific fish config (not tracked). PATH tweaks, installer snippets, work stuff.' > "$CONFIG_HOME/fish/local.fish"
    info "created ~/.config/fish/local.fish"
  fi
}

# Name and email stay in ~/.gitconfig.local. Ask only for values that are missing.
ensure_git_identity() {
  localfile="$HOME/.gitconfig.local"
  if [ ! -e "$localfile" ]; then
    printf '%s\n' '# Machine-specific git config (not tracked).' > "$localfile"
    info "created ~/.gitconfig.local"
  fi

  name=$(git config --file "$localfile" --get user.name 2>/dev/null || true)
  email=$(git config --file "$localfile" --get user.email 2>/dev/null || true)
  if [ -n "$name" ] && [ -n "$email" ]; then
    return 0
  fi
  if [ ! -t 0 ]; then
    warn "No TTY. Set user.name and user.email in ~/.gitconfig.local, then re-run."
    return 0
  fi

  if [ -z "$name" ]; then
    printf 'Git user.name: '
    read -r name || name=""
    if [ -n "$name" ]; then
      git config --file "$localfile" user.name "$name"
    else
      warn "user.name left unset"
    fi
  fi
  if [ -z "$email" ]; then
    printf 'Git user.email: '
    read -r email || email=""
    if [ -n "$email" ]; then
      git config --file "$localfile" user.email "$email"
    else
      warn "user.email left unset"
    fi
  fi
}

mise_bin() {
  if [ -x "$HOME/.local/bin/mise" ]; then
    printf '%s\n' "$HOME/.local/bin/mise"
  elif command -v mise >/dev/null 2>&1; then
    command -v mise
  fi
}

install_mise() {
  if [ -x "$HOME/.local/bin/mise" ]; then
    info "mise present at ~/.local/bin/mise"
    return 0
  fi
  info "Installing mise to ~/.local/bin/mise..."
  mkdir -p "$HOME/.local/bin"
  curl -fsSL https://mise.run | sh || { warn "mise install failed"; return 1; }
}

mise_install() {
  bin=$(mise_bin) || true
  if [ -z "$bin" ]; then
    warn "mise not installed; skipping tool install"
    return 0
  fi
  info "Installing tools via mise..."
  "$bin" trust "$CONFIG_HOME/mise/config.toml" >/dev/null 2>&1 || true
  "$bin" trust "$DOTFILES_DIR/mise.toml" >/dev/null 2>&1 || true
  "$bin" install || warn "mise install reported errors"
  "$bin" completion fish --install || warn "mise fish completion install failed"
}

install_nvim() {
  src="$DOTFILES_DIR/config/nvim"
  dest="$CONFIG_HOME/nvim"
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    info "nvim config already linked"
  else
    if [ -e "$dest" ] || [ -L "$dest" ]; then
      backup="$dest.bak.$(date +%s)"
      mv "$dest" "$backup"
      info "backed up nvim config -> $(basename "$backup")"
    fi
    mkdir -p "$(dirname "$dest")"
    ln -s "$src" "$dest"
    printf '  linked %s\n' "$dest"
  fi
  bin=$(mise_bin) || true
  if [ -n "$bin" ]; then
    info "Installing Neovim plugins..."
    "$bin" exec -- nvim --headless "+qa" || warn "nvim plugin install failed"
  elif command -v nvim >/dev/null 2>&1; then
    info "Installing Neovim plugins..."
    nvim --headless "+qa" || warn "nvim plugin install failed"
  else
    warn "nvim not on PATH; plugins install on first launch"
  fi
}

change_shell() {
  fish_path="$(command -v fish)" || {
    warn "fish not found; skipping shell change"
    return
  }
  [ "$(login_shell)" = "$fish_path" ] && { info "login shell already fish"; return; }

  if [ "${DOTFILES_YES:-}" = "1" ]; then
    reply=y
  elif [ ! -t 0 ]; then
    warn "No TTY. Run 'chsh -s $fish_path' to switch the login shell."
    return
  else
    printf "Change login shell to fish? [y/N] "
    read -r reply
  fi
  case "$reply" in
    [Yy]*) ;;
    *) info "skipping shell change"; return ;;
  esac

  # sudo chsh reuses the cached sudo password instead of prompting again.
  ensure_sudo || { warn "sudo unavailable. Run 'chsh -s $fish_path' yourself."; return; }
  if [ "$(detect_os)" = "linux" ] && ! grep -q "^$fish_path$" /etc/shells 2>/dev/null; then
    echo "$fish_path" | sudo tee -a /etc/shells >/dev/null
  fi
  sudo chsh -s "$fish_path" "$(id -un)" && info "login shell set to fish (restart your terminal)"
}

main() {
  [ "$(detect_os)" = "unsupported" ] && { echo "Unsupported OS"; exit 1; }
  [ -d "$DOTFILES_DIR" ] || { echo "Clone dotfiles to $DOTFILES_DIR first"; exit 1; }
  info "Detected OS: $(detect_os)"

  brew_packages
  install_font
  link_dotfiles
  ensure_local_files
  ensure_git_identity
  install_mise
  mise_install
  install_nvim
  change_shell

  info "Done. Re-run this script any time; it only does what's missing."
}

main "$@"
