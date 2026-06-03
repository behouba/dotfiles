#!/usr/bin/env bash
set -e

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

info()    { echo "[INFO] $*"; }
success() { echo "[OK]   $*"; }
warn()    { echo "[WARN] $*"; }

install_packages() {
  info "Installing system packages..."
  if command -v dnf &>/dev/null; then
    sudo dnf install -y zsh git curl autojump neovim
  elif command -v apt &>/dev/null; then
    sudo apt update && sudo apt install -y zsh git curl autojump neovim
  elif command -v pacman &>/dev/null; then
    sudo pacman -S --noconfirm zsh git curl autojump neovim
  else
    warn "Unknown package manager — install zsh, git, curl, autojump, neovim manually."
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
  mkdir -p "$HOME/.zsh/plugins"

  if [[ ! -f "$HOME/.zsh/plugins/zsh-autosuggestions.zsh" ]]; then
    info "Installing zsh-autosuggestions..."
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions /tmp/zsh-autosuggestions
    cp /tmp/zsh-autosuggestions/zsh-autosuggestions.zsh "$HOME/.zsh/plugins/"
    rm -rf /tmp/zsh-autosuggestions
    success "zsh-autosuggestions installed."
  else
    info "zsh-autosuggestions already present."
  fi

  if [[ ! -f "$HOME/.zsh/plugins/zsh-syntax-highlighting.zsh" ]]; then
    info "Installing zsh-syntax-highlighting..."
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting /tmp/zsh-syntax-highlighting
    cp /tmp/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh "$HOME/.zsh/plugins/"
    mkdir -p "$HOME/.zsh/plugins/highlighters"
    cp -r /tmp/zsh-syntax-highlighting/highlighters "$HOME/.zsh/plugins/"
    rm -rf /tmp/zsh-syntax-highlighting
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

link() {
  local src="$1" dst="$2"
  if [[ -e "$dst" && ! -L "$dst" ]]; then
    warn "Backing up existing $dst → $dst.bak"
    mv "$dst" "$dst.bak"
  fi
  ln -sf "$src" "$dst"
  success "Linked $dst → $src"
}

create_symlinks() {
  info "Creating symlinks..."
  link "$DOTFILES/zsh/.zshrc"            "$HOME/.zshrc"
  mkdir -p "$HOME/.config"
  link "$DOTFILES/starship/starship.toml" "$HOME/.config/starship.toml"
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
create_symlinks
set_zsh_default

echo ""
echo "Done! Open a new terminal (or run: exec zsh) to start using your setup."
