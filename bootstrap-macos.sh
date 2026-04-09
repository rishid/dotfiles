#!/usr/bin/env bash
# Bootstrap a fresh macOS machine with chezmoi dotfiles.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/rishid/dotfiles/master/bootstrap-macos.sh | bash
#   # or clone first then run:
#   ./bootstrap-macos.sh

set -uo pipefail   # -e removed: we handle errors explicitly for better messages

DOTFILES_REPO="rishid"
DOTFILES_DIR="$HOME/.dotfiles"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

info()    { echo -e "${BLUE}[INFO]${NC}  $*"; }
success() { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*" >&2; }
step()    { echo -e "\n${BOLD}── $* ──${NC}"; }
die()     { error "$*"; exit 1; }

# Print the failing command and line number if anything exits non-zero
trap 'error "Failed at line $LINENO: $BASH_COMMAND (exit $?)"' ERR

# ── 1. Verify macOS ──────────────────────────────────────────────────────────
step "1/7  Verify macOS"
if [[ "$(uname)" != "Darwin" ]]; then
    die "This script is for macOS only."
fi
sw_vers
success "macOS confirmed"

# ── 2. Xcode Command Line Tools ──────────────────────────────────────────────
step "2/7  Xcode Command Line Tools"
if ! xcode-select -p &>/dev/null; then
    info "Installing Xcode Command Line Tools..."
    xcode-select --install
    echo "Press Enter once the Xcode CLT installation popup is complete..."
    read -r < /dev/tty
    success "Installed: $(xcode-select -p)"
else
    success "Already installed: $(xcode-select -p)"
fi

# ── 3. Homebrew ───────────────────────────────────────────────────────────────
step "3/7  Homebrew"
if ! command -v brew &>/dev/null; then
    info "Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
        || die "Homebrew installation failed"
else
    success "Already installed: $(brew --version | head -1)"
fi

# Load Homebrew into current shell session
if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    success "Homebrew in PATH (Apple Silicon: /opt/homebrew)"
elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
    success "Homebrew in PATH (Intel: /usr/local)"
else
    die "Homebrew installed but brew not found in /opt/homebrew or /usr/local"
fi

# ── 4. Essential bootstrap tools ─────────────────────────────────────────────
step "4/7  Essential tools (git, curl, fish, chezmoi, mise)"
for pkg in git curl fish chezmoi mise; do
    if brew list --formula "$pkg" &>/dev/null; then
        success "$pkg already installed"
    else
        info "Installing $pkg..."
        brew install "$pkg" || die "Failed to install $pkg"
        success "Installed $pkg"
    fi
done

# ── 5. chezmoi init & apply ───────────────────────────────────────────────────
step "5/7  chezmoi init + apply"
info "chezmoi will prompt for your age key passphrase to decrypt secrets."
if [[ -d "$DOTFILES_DIR/.git" ]]; then
    info "Dotfiles already at $DOTFILES_DIR — running update..."
    chezmoi update || die "chezmoi update failed"
else
    info "Cloning dotfiles to $DOTFILES_DIR and applying..."
    # Use the same flags as the documented install command in README
    chezmoi init --source "$DOTFILES_DIR" --apply "$DOTFILES_REPO" \
        || die "chezmoi init failed — check output above for details"
fi
success "chezmoi apply complete"

# ── 6. Install all mise tools ─────────────────────────────────────────────────
step "6/7  mise tool install"
MISE_CONFIG="$HOME/.config/mise/config.toml"
if [[ ! -f "$MISE_CONFIG" ]]; then
    die "Expected mise config at $MISE_CONFIG — chezmoi apply may have failed"
fi

info "Trusting mise config and installing all tools (go, node, python, kubectl, gh, ...)..."
info "This will take several minutes on a fresh machine."
mise trust "$MISE_CONFIG" 2>/dev/null || true
mise install || warn "Some mise tools failed — run 'mise install' manually to retry"
success "mise tools installed"
echo ""
mise list

# ── 7. Set fish as default shell ──────────────────────────────────────────────
step "7/7  Default shell → fish"
FISH_PATH=""
for p in /opt/homebrew/bin/fish /usr/local/bin/fish; do
    if [[ -x "$p" ]]; then FISH_PATH="$p"; break; fi
done

if [[ -z "$FISH_PATH" ]]; then
    die "fish not found — 'brew install fish' should have succeeded above"
fi

if ! grep -qF "$FISH_PATH" /etc/shells; then
    info "Adding $FISH_PATH to /etc/shells (requires sudo)..."
    echo "$FISH_PATH" | sudo tee -a /etc/shells > /dev/null
fi

if [[ "$SHELL" != "$FISH_PATH" ]]; then
    info "Changing default shell to fish (you may be prompted for your password)..."
    chsh -s "$FISH_PATH" < /dev/tty || die "chsh failed — try: chsh -s $FISH_PATH"
    success "Default shell → $FISH_PATH"
else
    success "fish is already the default shell"
fi

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
success "Bootstrap complete!"
echo ""
echo "  Open a new terminal to start using fish."
  echo "  To keep everything up to date, open fish and run: dotup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
