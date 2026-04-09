#!/usr/bin/env bash
# Bootstrap a fresh macOS machine with chezmoi dotfiles.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/rishid/dotfiles/master/bootstrap-macos.sh | bash
#   # or clone first then run:
#   ./bootstrap-macos.sh

set -euo pipefail

DOTFILES_REPO="rishid"
DOTFILES_DIR="$HOME/.dotfiles"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { echo -e "${BLUE}[INFO]${NC}  $*"; }
success() { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*" >&2; exit 1; }

# ── 1. Verify macOS ──────────────────────────────────────────────────────────
if [[ "$(uname)" != "Darwin" ]]; then
    error "This script is for macOS only."
fi

info "Starting macOS bootstrap..."
sw_vers

# ── 2. Xcode Command Line Tools ──────────────────────────────────────────────
if ! xcode-select -p &>/dev/null; then
    info "Installing Xcode Command Line Tools..."
    xcode-select --install
    # Wait for installation to finish
    echo "Press Enter once Xcode Command Line Tools installation is complete..."
    read -r
else
    success "Xcode Command Line Tools already installed"
fi

# ── 3. Homebrew ───────────────────────────────────────────────────────────────
if ! command -v brew &>/dev/null; then
    info "Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    success "Homebrew already installed"
fi

# Load Homebrew into current shell session
if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    success "Homebrew configured (Apple Silicon: /opt/homebrew)"
elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
    success "Homebrew configured (Intel: /usr/local)"
else
    error "Homebrew installed but brew not found in expected locations"
fi

# ── 4. Essential bootstrap tools ─────────────────────────────────────────────
info "Installing essential tools..."
for pkg in git curl fish age chezmoi; do
    if brew list --formula "$pkg" &>/dev/null 2>&1; then
        success "$pkg already installed"
    else
        brew install "$pkg"
        success "Installed $pkg"
    fi
done

# ── 5. Age key (required for encrypted secrets) ───────────────────────────────
AGE_KEY="$HOME/.config/chezmoi/key.txt"
if [[ ! -f "$AGE_KEY" ]]; then
    warn "Age decryption key not found at $AGE_KEY"
    echo ""
    echo "You need to place your age private key at: $AGE_KEY"
    echo "Options:"
    echo "  1. Copy from another machine:  scp other-machine:~/.config/chezmoi/key.txt $AGE_KEY"
    echo "  2. Decrypt from backup:        age --decrypt -o $AGE_KEY key.txt.age"
    echo "  3. Generate a new key (will break encrypted secret decryption):"
    echo "     age-keygen -o $AGE_KEY"
    echo ""
    echo "Press Enter to continue after placing the key (or Ctrl-C to abort)..."
    read -r
    if [[ ! -f "$AGE_KEY" ]]; then
        warn "Key still not found — chezmoi will prompt for it or skip encrypted files"
    else
        chmod 400 "$AGE_KEY"
        success "Age key found"
    fi
else
    chmod 400 "$AGE_KEY"
    success "Age key already present"
fi

# ── 6. chezmoi init & apply ───────────────────────────────────────────────────
info "Initializing chezmoi with dotfiles from $DOTFILES_REPO..."

if [[ -d "$DOTFILES_DIR/.git" ]]; then
    warn "Dotfiles already cloned at $DOTFILES_DIR, running update instead"
    chezmoi update --source-path "$DOTFILES_DIR/tilde"
else
    chezmoi init \
        --source "$DOTFILES_DIR" \
        --apply \
        "$DOTFILES_REPO"
fi

success "chezmoi apply completed"

# ── 7. Install mise and tools ─────────────────────────────────────────────────
if command -v mise &>/dev/null; then
    info "Installing development tools via mise (this may take a while)..."
    mise install 2>&1 || warn "Some mise tools failed to install — run 'mise install' manually"
    success "mise tools installed"
else
    warn "mise not found — run 'brew install mise && mise install' to install dev tools"
fi

# ── 8. Set fish as default shell ──────────────────────────────────────────────
FISH_PATH=""
for p in /opt/homebrew/bin/fish /usr/local/bin/fish; do
    if [[ -x "$p" ]]; then
        FISH_PATH="$p"
        break
    fi
done

if [[ -n "$FISH_PATH" ]]; then
    if ! grep -qF "$FISH_PATH" /etc/shells; then
        info "Adding $FISH_PATH to /etc/shells..."
        echo "$FISH_PATH" | sudo tee -a /etc/shells > /dev/null
    fi

    if [[ "$SHELL" != "$FISH_PATH" ]]; then
        info "Setting default shell to fish..."
        chsh -s "$FISH_PATH"
        success "Default shell set to $FISH_PATH"
        echo ""
        warn "Log out and back in (or open a new terminal) for fish to take effect"
    else
        success "Fish is already the default shell"
    fi
else
    warn "Fish shell not found in expected paths — run 'brew install fish' manually"
fi

# ── 9. Summary ────────────────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
success "Bootstrap complete!"
echo ""
echo "Next steps:"
echo "  • Open a new terminal (or log out/in) to start using fish"
echo "  • Run 'mise install' if any tools failed during setup"
echo "  • Add SSH keys to ~/.ssh/autoload for auto-loading"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
