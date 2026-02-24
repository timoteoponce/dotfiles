#!/usr/bin/env sh
set -e

DOTFILES_DIR="$HOME/.dotfiles"

detect_os() {
  case "$OSTYPE" in
    darwin*) echo "macos" ;;
    linux-*) echo "linux" ;;
    *) echo "unsupported" ;;
  esac
}

install_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    echo "Homebrew already installed"
    return
  fi
  echo "Installing Homebrew..."
  /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

install_packages() {
  echo "Installing packages via Homebrew..."

  brew install rcm
  brew install fish
  brew install mise fzf ripgrep eza bat lazygit lazydocker
  brew install neovim

  os="$(detect_os)"
  if [ "$os" = "macos" ]; then
    brew install diffmerge
  else
    brew install meld
  fi

  brew tap homebrew/cask-fonts
  brew install --cask font-jetbrains-mono-nerd-font 2>/dev/null || echo "Nerd font installation skipped (may fail on some distros)"
}

link_dotfiles() {
  echo "Linking dotfiles with rcm..."
  rcup -v
}

install_lazyvim() {
  echo "Installing LazyVim..."
  nvim_config_dir="$HOME/.config/nvim"

  if [ -d "$nvim_config_dir" ]; then
    printf "Backup existing nvim config? [y/N] "
    read -r reply
    case "$reply" in
      [Yy]*) 
        mv "$nvim_config_dir" "${nvim_config_dir}.bak"
        echo "Backed up to ${nvim_config_dir}.bak"
        ;;
      *) 
        echo "Skipping LazyVim installation"
        return
        ;;
    esac
  fi

  git clone https://github.com/LazyVim/starter "$nvim_config_dir"
  rm -rf "$nvim_config_dir/.git"

  echo "LazyVim installed. Run 'nvim' to install plugins."
}

change_shell() {
  echo "Changing default shell to fish..."
  printf "Change shell to fish? (requires password) [y/N] "
  read -r reply
  echo
  case "$reply" in
    [Yy]*) ;;
    *) echo "Skipping shell change"
       return ;;
  esac

  fish_path=$(command -v fish)

  os="$(detect_os)"
  if [ "$os" = "linux" ]; then
    if [ ! -f /etc/shells ] || ! grep -q "$fish_path" /etc/shells 2>/dev/null; then
      echo "$fish_path" | sudo tee -a /etc/shells
    fi
  fi

  chsh -s "$fish_path"
}

main() {
  os="$(detect_os)"
  if [ "$os" = "unsupported" ]; then
    echo "Unsupported OS: $OSTYPE"
    exit 1
  fi

  echo "Detected OS: $os"

  if [ ! -d "$DOTFILES_DIR" ]; then
    echo "Dotfiles not found at $DOTFILES_DIR"
    echo "Please clone your dotfiles first"
    exit 1
  fi

  install_homebrew
  install_packages
  link_dotfiles
  install_lazyvim
  change_shell

  echo "Installation complete! Restart your terminal."
}

main "$@"
