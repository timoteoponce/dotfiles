#!/usr/bin/env sh
#
# Idempotent installer. Safe to run as many times as you like:
#   - already-installed packages are skipped
#   - correct symlinks are left untouched
#   - a step that fails warns and the rest still runs
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

install_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    info "Homebrew present"
  else
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
      warn "Homebrew install failed; skipping brew steps"; return 1
    }
  fi
  [ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"
  [ -x /home/linuxbrew/.linuxbrew/bin/brew ] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  return 0
}

brew_bundle() {
  command -v brew >/dev/null 2>&1 || { warn "brew not on PATH; skipping Brewfile"; return; }
  info "Installing packages from Brewfile..."
  if [ "$(detect_os)" = "linux" ]; then
    # casks (ghostty, fonts) are macOS-only: install the formulae only
    grep '^brew ' "$DOTFILES_DIR/Brewfile" | sed 's/^brew "\([^"]*\)".*/\1/' \
      | xargs brew install || warn "some brew formulae failed"
    # clipboard bridge for tmux / LazyVim on Linux
    brew install xclip >/dev/null 2>&1 || warn "xclip install skipped"
  else
    # --no-upgrade: re-runs only install what's missing, they don't churn your
    # toolchain. Run `brew upgrade` yourself when you actually want new versions.
    brew bundle --file "$DOTFILES_DIR/Brewfile" --no-upgrade || warn "brew bundle reported errors"
  fi
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

  link_file gitconfig  "$HOME/.gitconfig"
  link_file gitignore  "$HOME/.gitignore"
  link_file tmux.conf  "$HOME/.tmux.conf"
  link_file ideavimrc  "$HOME/.ideavimrc"
  link_file psqlrc     "$HOME/.psqlrc"
  link_file mise.toml  "$CONFIG_HOME/mise/config.toml"

  # fish: link individual files so fish's own runtime files stay local
  link_file config/fish/config.fish "$CONFIG_HOME/fish/config.fish"
  for f in "$DOTFILES_DIR"/config/fish/conf.d/*.fish; do
    link_file "config/fish/conf.d/$(basename "$f")" "$CONFIG_HOME/fish/conf.d/$(basename "$f")"
  done
  for f in "$DOTFILES_DIR"/config/fish/functions/*.fish; do
    link_file "config/fish/functions/$(basename "$f")" "$CONFIG_HOME/fish/functions/$(basename "$f")"
  done

  link_file config/ghostty/config        "$CONFIG_HOME/ghostty/config"
  link_file config/lazygit/config.yml    "$CONFIG_HOME/lazygit/config.yml"
  link_file config/lazydocker/config.yml "$CONFIG_HOME/lazydocker/config.yml"
  link_file config/bat/config            "$CONFIG_HOME/bat/config"
}

ensure_local_files() {
  if [ ! -e "$HOME/.gitconfig.local" ]; then
    printf '# Machine-specific git config (not tracked). Your user.email, corp hosts, credential managers, etc.\n[user]\n\temail = ponce.timoteo@gmail.com\n' > "$HOME/.gitconfig.local"
    info "created ~/.gitconfig.local"
  fi
  if [ ! -e "$CONFIG_HOME/fish/local.fish" ]; then
    mkdir -p "$CONFIG_HOME/fish"
    printf '# Machine-specific fish config (not tracked). PATH tweaks, installer snippets, work stuff.\n' > "$CONFIG_HOME/fish/local.fish"
    info "created ~/.config/fish/local.fish"
  fi
}

mise_install() {
  command -v mise >/dev/null 2>&1 || { warn "mise not on PATH; skipping (run 'mise install' after restart)"; return; }
  info "Installing tools via mise..."
  mise trust "$CONFIG_HOME/mise/config.toml" >/dev/null 2>&1 || true
  mise trust "$DOTFILES_DIR/mise.toml" >/dev/null 2>&1 || true
  mise install || warn "mise install reported errors"
}

install_lazyvim() {
  nvim_config_dir="$CONFIG_HOME/nvim"
  if [ -d "$nvim_config_dir" ]; then
    info "nvim config already present; leaving it alone"
    return
  fi
  info "Installing LazyVim starter..."
  git clone https://github.com/LazyVim/starter "$nvim_config_dir" \
    && rm -rf "$nvim_config_dir/.git" \
    && info "LazyVim installed. Run 'nvim' to sync plugins." \
    || warn "LazyVim clone failed"
}

change_shell() {
  fish_path="$(command -v fish)" || { warn "fish not found; skipping shell change"; return; }
  [ "$(login_shell)" = "$fish_path" ] && { info "login shell already fish"; return; }

  if [ "${DOTFILES_YES:-}" = "1" ]; then
    reply=y
  else
    printf "Change login shell to fish? [y/N] "
    read -r reply
  fi
  case "$reply" in
    [Yy]*) ;;
    *) info "skipping shell change"; return ;;
  esac

  if [ "$(detect_os)" = "linux" ] && ! grep -q "^$fish_path$" /etc/shells 2>/dev/null; then
    echo "$fish_path" | sudo tee -a /etc/shells >/dev/null
  fi
  chsh -s "$fish_path" && info "login shell set to fish (restart your terminal)"
}

main() {
  [ "$(detect_os)" = "unsupported" ] && { echo "Unsupported OS"; exit 1; }
  [ -d "$DOTFILES_DIR" ] || { echo "Clone dotfiles to $DOTFILES_DIR first"; exit 1; }
  info "Detected OS: $(detect_os)"

  install_homebrew
  brew_bundle
  link_dotfiles
  ensure_local_files
  mise_install
  install_lazyvim
  change_shell

  info "Done. Re-run this script any time; it only does what's missing."
}

main "$@"
