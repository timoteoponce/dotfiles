#!/usr/bin/env sh
#
# Idempotent installer. Safe to run as many times as you like:
#   - already-installed packages are skipped
#   - correct symlinks are left untouched
#   - a step that fails warns and the rest still runs
#
# mise is the only package layer. There is no Homebrew here; install.sh puts mise
# itself in ~/.local/bin, then everything else comes from mise.toml.
#
# A run also refreshes: mise, the mise.toml tools, fish, and the Nerd Font each
# move to the newest version they can, but only when that is actually different.
# Every one of those steps is fail-soft - a failed refresh keeps what you have.
#
# Env:
#   DOTFILES_NO_REFRESH=1  skip the refresh pass; do only what is missing
#   DOTFILES_YES=1         answer "yes" to the shell-change prompt (non-interactive)
#   DOTFILES_SKIP_FONT=1   skip the JetBrains Mono Nerd Font
#   MISE_VERSION=...       pin mise for this run (also forces a reinstall)
#   FISH_VERSION=...       pin fish for this run, macOS only

DOTFILES_DIR="$HOME/.dotfiles"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
LOCAL_BIN="$HOME/.local/bin"
FISH_LINK="$LOCAL_BIN/fish"
FONT_STAMP="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/font-version"
NERD_FONTS_URL="https://github.com/ryanoasis/nerd-fonts/releases"

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

refresh_allowed() { [ "${DOTFILES_NO_REFRESH:-}" != "1" ]; }

# mise reads its global config (the linked mise.toml) from anywhere, but -C keeps
# a stray project mise.toml in the cwd from changing what gets installed.
mise_cmd() { mise -C "$DOTFILES_DIR" "$@"; }

# newest tag of a GitHub repo, from the releases/latest redirect
github_latest_tag() {
  curl -fsSI "https://github.com/$1/releases/latest" 2>/dev/null \
    | sed -n 's|.*/tag/||p' | tr -d '\r' | tail -1
}

check_prereqs() {
  missing=""
  for cmd in git curl tar; do
    command -v "$cmd" >/dev/null 2>&1 || missing="$missing $cmd"
  done
  [ -z "$missing" ] && return 0

  # git is the one tool mise cannot provide: no upstream git tarball, and the OS
  # ships the one that works with the system credential helpers.
  warn "missing:$missing (install them with your package manager, then re-run)"
  case "$(detect_os)" in
    macos) warn "on macOS: xcode-select --install" ;;
    linux) warn "on Debian/Ubuntu: sudo apt install git curl tar" ;;
  esac
}

bootstrap_mise() {
  case "$(uname -sm)" in
    'Darwin arm64') asset="macos-arm64" ;;
    'Darwin x86_64') asset="macos-x64" ;;
    'Linux x86_64') asset="linux-x64" ;;
    'Linux aarch64' | 'Linux arm64') asset="linux-arm64" ;;
    *) warn "no mise build for $(uname -sm); see https://mise.jdx.dev/getting-started.html"; return 1 ;;
  esac

  version="${MISE_VERSION:-$(github_latest_tag jdx/mise)}"
  [ -n "$version" ] || { warn "could not read the latest mise release; set MISE_VERSION"; return 1; }

  info "Installing mise $version ($asset)..."
  tmp="$(mktemp -d)" || return 1
  if curl -fsSL -o "$tmp/mise.tar.gz" \
       "https://github.com/jdx/mise/releases/download/$version/mise-$version-$asset.tar.gz" \
     && tar xzf "$tmp/mise.tar.gz" -C "$tmp" \
     && mkdir -p "$LOCAL_BIN" \
     && install -m 0755 "$tmp/mise/bin/mise" "$LOCAL_BIN/mise"; then
    rm -rf "$tmp"
    PATH="$LOCAL_BIN:$PATH"; export PATH
    printf '  installed %s\n' "$LOCAL_BIN/mise"
  else
    warn "mise download failed; see https://mise.jdx.dev/getting-started.html"
    rm -rf "$tmp"
    return 1
  fi
}

# mise verifies the release signature and skips anything younger than 24h, which
# is why it does the fetching here instead of a second hand-rolled download.
refresh_mise() {
  refresh_allowed || return 0
  installed="$(mise --version 2>/dev/null | awk '{print $1}' | sed 's/^v//')"
  latest="$(github_latest_tag jdx/mise)"
  latest="${latest#v}"
  if [ -z "$latest" ]; then
    warn "could not read the latest mise release; staying on $installed"
    return 0
  fi
  [ "$installed" = "$latest" ] && return 0

  info "Updating mise $installed -> $latest..."
  # self-update skips releases younger than minimum_release_age (24h by default),
  # so the newest tag can be a few hours too fresh to install. Report what
  # actually happened instead of assuming it took.
  log="$(mktemp)" || return 1
  if mise_cmd self-update --yes >"$log" 2>&1; then
    now="$(mise --version 2>/dev/null | awk '{print $1}')"
    if [ "$now" = "$installed" ]; then
      info "mise stays on $installed; $latest is too new to install yet, re-run later"
    else
      printf '  mise is now %s\n' "$now"
    fi
  else
    warn "mise self-update failed; staying on $installed"
    sed 's/^/  /' "$log" >&2
  fi
  rm -f "$log"
}

install_mise() {
  if ! command -v mise >/dev/null 2>&1; then
    bootstrap_mise || return 1
    return 0
  fi
  # self-update refuses when something else installed mise (a package manager),
  # so only offer it for the copy install.sh owns.
  if [ "$(command -v mise)" = "$LOCAL_BIN/mise" ]; then
    refresh_mise
  else
    info "mise present ($(command -v mise)); update it through whatever installed it"
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

  # personal scripts -> ~/.local/bin (on PATH; git auto-discovers git-* as subcommands)
  for f in "$DOTFILES_DIR"/bin/*; do
    [ -e "$f" ] || continue
    link_file "bin/$(basename "$f")" "$HOME/.local/bin/$(basename "$f")"
  done
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
  mise_cmd trust "$CONFIG_HOME/mise/config.toml" >/dev/null 2>&1 || true
  mise_cmd trust "$DOTFILES_DIR/mise.toml" >/dev/null 2>&1 || true
  mise_cmd install || warn "mise install reported errors"

  # Before ensure_fish, so the login-shell symlink follows the version that just
  # landed. "upgrade" stays inside each request: an exact pin such as java does
  # not move, "latest" tools go to the newest release.
  if refresh_allowed; then
    info "Updating tools to the newest matching version..."
    mise_cmd upgrade || warn "mise upgrade reported errors"
  fi
}

# Login shell on Linux: a fixed path that survives version bumps is what /etc/shells
# and chsh need, so ~/.local/bin/fish points at whatever mise installed.
fish_from_mise() {
  info "Linking fish (mise)..."
  fish_bin="$(mise_cmd which fish 2>/dev/null)" || fish_bin=""
  [ -n "$fish_bin" ] && [ -x "$fish_bin" ] || { warn "mise did not resolve fish; run 'mise install'"; return 1; }

  mkdir -p "$LOCAL_BIN"
  if [ "$(readlink "$FISH_LINK" 2>/dev/null)" != "$fish_bin" ]; then
    ln -sf "$fish_bin" "$FISH_LINK" && printf '  linked %s\n' "$FISH_LINK"
  fi
  "$FISH_LINK" --version >/dev/null 2>&1 || { warn "$FISH_LINK does not run"; return 1; }
}

# macOS has no fish tarball upstream, only the .app bundle from a release. Its
# Contents/Resources/base is a relocatable /usr/local tree, so bin/ and share/
# copied into ~/.local keep working there. etc/ is skipped on purpose: that is
# where our own ~/.config/fish lives.
fish_from_app_bundle() {
  installed="$("$FISH_LINK" --version 2>/dev/null | awk '{print $NF}')"
  version="${FISH_VERSION:-$(github_latest_tag fish-shell/fish-shell)}"

  if [ -n "$installed" ]; then
    if [ -z "$version" ] || [ "$installed" = "$version" ]; then
      info "fish present ($installed)"
      return 0
    fi
    # A newer one exists. Take it on request (an explicit pin) or on a normal
    # refresh; otherwise leave the working shell alone.
    if [ -z "${FISH_VERSION:-}" ] && ! refresh_allowed; then
      info "fish present ($installed); $version available"
      return 0
    fi
  elif [ -z "$version" ]; then
    warn "could not read the latest fish release; set FISH_VERSION"
    return 1
  fi

  info "Installing fish $version from the official macOS bundle..."
  tmp="$(mktemp -d)" || return 1
  url="https://github.com/fish-shell/fish-shell/releases/download/$version/fish-$version.app.zip"
  if ! curl -fsSL -o "$tmp/fish.zip" "$url" || ! unzip -q "$tmp/fish.zip" -d "$tmp"; then
    warn "fish download failed; keeping ${installed:-$FISH_LINK}"
    rm -rf "$tmp"
    return 1
  fi

  base="$tmp/fish-$version.app/Contents/Resources/base/usr/local"
  # Validate the new binary before it can replace a working login shell.
  if [ ! -x "$base/bin/fish" ] || [ "$("$base/bin/fish" --version 2>/dev/null | awk '{print $NF}')" != "$version" ]; then
    warn "the downloaded fish does not run; keeping ${installed:-$FISH_LINK}"
    rm -rf "$tmp"
    return 1
  fi

  mkdir -p "$LOCAL_BIN" "$HOME/.local/share/fish"
  cp "$base/bin/fish" "$base/bin/fish_indent" "$base/bin/fish_key_reader" "$LOCAL_BIN/" \
    && cp -R "$base/share/fish/." "$HOME/.local/share/fish/" \
    && chmod +x "$LOCAL_BIN"/fish "$LOCAL_BIN"/fish_indent "$LOCAL_BIN"/fish_key_reader \
    || { warn "could not unpack fish into ~/.local; keeping ${installed:-$FISH_LINK}"; rm -rf "$tmp"; return 1; }
  rm -rf "$tmp"

  printf '  installed %s\n' "$("$FISH_LINK" --version)"
}

ensure_fish() {
  case "$(detect_os)" in
    linux) fish_from_mise ;;
    macos) fish_from_app_bundle ;;
  esac
}

install_font() {
  [ "${DOTFILES_SKIP_FONT:-}" = "1" ] && { info "skipping font (DOTFILES_SKIP_FONT=1)"; return 0; }

  case "$(detect_os)" in
    macos) font_dir="$HOME/Library/Fonts" ;;
    *) font_dir="${XDG_DATA_HOME:-$HOME/.local/share}/fonts" ;;
  esac
  mkdir -p "$font_dir"

  # The stamp is the upstream tag of the files on disk. Machines that predate it
  # fall back to "do the files exist".
  have=""
  [ -f "$FONT_STAMP" ] && have="$(cat "$FONT_STAMP" 2>/dev/null)"
  latest="$(github_latest_tag ryanoasis/nerd-fonts)"
  # shellcheck disable=SC2012 # no glob option in POSIX sh, and a missing dir is fine
  ls "$font_dir"/JetBrainsMonoNerdFont-*.ttf >/dev/null 2>&1 || have=""

  if [ -n "$have" ] && { [ "$have" = "$latest" ] || ! refresh_allowed; }; then
    info "Nerd Font present ($have)"
    return 0
  fi

  info "Installing JetBrains Mono Nerd Font..."
  tmp="$(mktemp -d)" || return 1
  if [ -n "$latest" ]; then
    url="$NERD_FONTS_URL/download/$latest/JetBrainsMono.tar.xz"
  else
    warn "could not read the latest nerd-fonts release; installing whatever is newest"
    url="$NERD_FONTS_URL/latest/download/JetBrainsMono.tar.xz"
  fi

  if curl -fsSL -o "$tmp/font.tar.xz" "$url" && tar xJf "$tmp/font.tar.xz" -C "$tmp" \
     && cp "$tmp"/JetBrainsMonoNerdFont-*.ttf "$font_dir/"; then
    # Stamp only a tag we actually resolved, so a failed HEAD costs one
    # re-download rather than a stamp that never matches.
    if [ -n "$latest" ]; then
      mkdir -p "$(dirname "$FONT_STAMP")"
      printf '%s\n' "$latest" > "$FONT_STAMP"
    fi
    printf '  installed %s font files (%s)\n' \
      "$(ls "$font_dir"/JetBrainsMonoNerdFont-*.ttf | wc -l | tr -d ' ')" "${latest:-unrecorded}"
  else
    warn "font download failed; grab it from https://www.nerdfonts.com/font-downloads"
  fi
  rm -rf "$tmp"
  if command -v fc-cache >/dev/null 2>&1; then
    fc-cache -f "$font_dir" >/dev/null 2>&1
  fi
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
  # mise's neovim, so Mac and other Linux boxes don't pick up an older nvim.
  if command -v mise >/dev/null 2>&1; then
    info "Installing Neovim plugins..."
    mise_cmd exec -- nvim --headless "+qa" || warn "nvim plugin install failed"
  elif command -v nvim >/dev/null 2>&1; then
    info "Installing Neovim plugins..."
    nvim --headless "+qa" || warn "nvim plugin install failed"
  else
    warn "nvim not on PATH; plugins install on first launch"
  fi
}

change_shell() {
  fish_path="$FISH_LINK"
  [ -x "$fish_path" ] || fish_path="$(command -v fish 2>/dev/null)"
  [ -n "$fish_path" ] || { warn "fish not found; skipping shell change"; return; }
  # chsh writes the path into the account record: never point it at a shell that
  # does not start.
  "$fish_path" --version >/dev/null 2>&1 || { warn "$fish_path does not run; skipping shell change"; return; }
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

# Things no package layer here can install: they come from the distro.
linux_hints() {
  [ "$(detect_os)" = "linux" ] || return 0
  if command -v xclip >/dev/null 2>&1 || command -v xsel >/dev/null 2>&1 || command -v wl-copy >/dev/null 2>&1; then
    return 0
  fi
  info "no clipboard tool found; tmux and Neovim copy/paste need one:"
  printf '  apt: sudo apt install xclip    dnf: sudo dnf install xclip\n'
  printf '  pacman: sudo pacman -S xclip   zypper: sudo zypper install xclip\n'
}

main() {
  [ "$(detect_os)" = "unsupported" ] && { echo "Unsupported OS"; exit 1; }
  [ -d "$DOTFILES_DIR" ] || { echo "Clone dotfiles to $DOTFILES_DIR first"; exit 1; }
  info "Detected OS: $(detect_os)"

  check_prereqs
  install_mise
  link_dotfiles
  ensure_local_files
  mise_install
  ensure_fish
  install_font
  install_nvim
  change_shell
  linux_hints

  info "Done. Re-run this script any time; it refreshes and does what's missing."
}

main "$@"