#!/usr/bin/env bash
set -e

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

info()    { echo "[INFO] $*"; }
success() { echo "[OK]   $*"; }
warn()    { echo "[WARN] $*"; }

install_packages() {
  info "Installing system packages..."
  if command -v dnf &>/dev/null; then
    sudo dnf install -y zsh git curl autojump neovim tmux wl-clipboard xclip stow
  elif command -v apt &>/dev/null; then
    sudo apt update && sudo apt install -y zsh git curl autojump neovim tmux wl-clipboard xclip stow
  elif command -v pacman &>/dev/null; then
    sudo pacman -S --noconfirm zsh git curl autojump neovim tmux wl-clipboard xclip stow
  else
    warn "Unknown package manager — install zsh, git, curl, autojump, neovim, tmux, wl-clipboard, xclip, stow manually."
  fi
}

install_omz() {
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    info "Oh My Zsh already installed, skipping."
  else
    info "Installing Oh My Zsh..."
    RUNZSH=no CHSH=no sh -c \
      "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    success "Oh My Zsh installed."
  fi
}

install_zsh_plugins() {
  local PDIR="$HOME/.zsh/plugins"
  mkdir -p "$PDIR"

  if [[ ! -d "$PDIR/zsh-autosuggestions" ]]; then
    info "Installing zsh-autosuggestions..."
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions \
      "$PDIR/zsh-autosuggestions"
    success "zsh-autosuggestions installed."
  else
    info "zsh-autosuggestions already present."
  fi

  if [[ ! -d "$PDIR/zsh-syntax-highlighting" ]]; then
    info "Installing zsh-syntax-highlighting..."
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting \
      "$PDIR/zsh-syntax-highlighting"
    success "zsh-syntax-highlighting installed."
  else
    info "zsh-syntax-highlighting already present."
  fi
}

install_starship() {
  if command -v starship &>/dev/null; then
    info "Starship already installed."
  else
    info "Installing Starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- --yes
    success "Starship installed."
  fi
}

PACKAGES=(zsh tmux starship git)

stow_packages() {
  info "Linking dotfiles..."
  for pkg in "${PACKAGES[@]}"; do
    # Back up real files that would block stow
    while IFS= read -r f; do
      local dst="$HOME/${f#./}"
      if [[ -e "$dst" && ! -L "$dst" ]]; then
        warn "Backing up existing $dst → $dst.bak"
        mv "$dst" "$dst.bak"
      fi
    done < <(cd "$DOTFILES/$pkg" && find . -type f)
    stow --restow --target="$HOME" --dir="$DOTFILES" "$pkg"
    success "Linked $pkg"
  done
}

set_zsh_default() {
  if [[ "$SHELL" != "$(which zsh)" ]]; then
    info "Setting zsh as default shell..."
    chsh -s "$(which zsh)"
    success "Default shell changed to zsh. Log out and back in for it to take effect."
  else
    info "zsh is already the default shell."
  fi
}

install_packages
install_omz
install_zsh_plugins
install_starship
stow_packages
set_zsh_default

echo ""
echo "Done! Open a new terminal (or run: exec zsh) to start using your setup."
