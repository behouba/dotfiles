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

PACKAGES=(zsh tmux starship git nvim)

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

setup_git_identities() {
  local gdir="$HOME/.config/git"
  mkdir -p "$gdir"
  if [[ -f "$gdir/work" && -f "$gdir/personal.local" && -f "$gdir/allowed_signers" ]]; then
    info "Git identities already configured."
    return
  fi
  if [[ ! -t 0 ]]; then
    warn "No terminal — skipping git identity setup. Re-run install.sh interactively."
    return
  fi

  info "Setting up git identities (SSH signing)..."
  local personal_key work_email work_key
  read -rp "Personal signing key [~/.ssh/id_rsa_work.pub]: " personal_key
  read -rp "Work email [dgdev2@dominiongrimm.ca]: " work_email
  read -rp "Work signing key [~/.ssh/github_dg.pub]: " work_key
  personal_key="${personal_key:-~/.ssh/id_rsa_work.pub}"
  work_email="${work_email:-dgdev2@dominiongrimm.ca}"
  work_key="${work_key:-~/.ssh/github_dg.pub}"

  printf '[user]\n\tsigningkey = %s\n' "$personal_key" > "$gdir/personal.local"
  printf '[user]\n\temail = %s\n\tsigningkey = %s\n' "$work_email" "$work_key" > "$gdir/work"

  local personal_email
  personal_email="$(git config -f "$DOTFILES/git/.config/git/personal" user.email)"
  : > "$gdir/allowed_signers"
  [[ -f "${personal_key/#\~/$HOME}" ]] && echo "$personal_email $(cut -d' ' -f1,2 "${personal_key/#\~/$HOME}")" >> "$gdir/allowed_signers"
  [[ -f "${work_key/#\~/$HOME}" ]] && echo "$work_email $(cut -d' ' -f1,2 "${work_key/#\~/$HOME}")" >> "$gdir/allowed_signers"
  success "Git identities configured. Add both keys to GitHub as Signing Keys."
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
setup_git_identities
set_zsh_default

echo ""
echo "Done! Open a new terminal (or run: exec zsh) to start using your setup."
