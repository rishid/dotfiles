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

# ── 3. Fish shell ─────────────────────────────────────────────────────────────
# git and curl already ship with Xcode CLT above, so the only thing we still
# need a real installer for is fish (chezmoi and mise get their own official
# installers in step 4). Pulling the latest .pkg from GitHub releases avoids
# hardcoding a version that will go stale.
step "3/7  Fish shell"
if command -v fish &>/dev/null; then
    success "Already installed: $(fish --version)"
else
    info "Looking up latest fish-shell release..."
    FISH_PKG_URL="$(curl -fsSL https://api.github.com/repos/fish-shell/fish-shell/releases/latest \
        | grep -m1 -o '"browser_download_url": *"[^"]*\.pkg"' \
        | sed -E 's/.*"(https:[^"]+)"$/\1/')"
    [[ -n "$FISH_PKG_URL" ]] || die "Could not find a .pkg asset in the latest fish-shell release"

    FISH_TMP_DIR="$(mktemp -d)"
    FISH_PKG="$FISH_TMP_DIR/fish.pkg"
    info "Downloading ${FISH_PKG_URL}..."
    curl -fsSL -o "$FISH_PKG" "$FISH_PKG_URL" || die "Failed to download fish .pkg"

    pkgutil --check-signature "$FISH_PKG" &>/dev/null \
        || warn "fish .pkg signature could not be verified — proceeding anyway"

    info "Installing fish (you may be prompted for your account password)..."
    sudo -v < /dev/tty || die "sudo access is required to install fish"
    sudo installer -pkg "$FISH_PKG" -target / || die "fish installation failed"
    rm -rf "$FISH_TMP_DIR"

    command -v fish &>/dev/null || die "fish installation reported success but fish is not on PATH"
    success "Installed fish: $(fish --version)"
fi

# ── 4. mise ────────────────────────────────────────────────────────────────────
step "4/7  mise"
# Install mise via official installer so that mise self-update works
if [[ -x "$HOME/.local/bin/mise" ]]; then
    success "mise already installed: $($HOME/.local/bin/mise --version)"
else
    info "Installing mise via official installer..."
    curl https://mise.run | sh || die "mise installation failed"
    success "mise installed: $($HOME/.local/bin/mise --version)"
fi
export PATH="$HOME/.local/bin:$PATH"

# ── 5. chezmoi init & apply ───────────────────────────────────────────────────
step "5/7  chezmoi init + apply"
info "chezmoi will prompt for your age key passphrase to decrypt secrets."
# chezmoi is already declared in mise/config.toml for ongoing version
# management (step 6 installs it there), so we only need a throwaway copy
# here to do the initial clone + apply. get.chezmoi.io's installer supports
# downloading and immediately running chezmoi in one shot: pass -b for a
# temp bindir plus the chezmoi subcommand/args to run after downloading.
CHEZMOI_TMP_DIR="$(mktemp -d)"
if [[ -d "$DOTFILES_DIR/.git" ]]; then
    info "Dotfiles already at $DOTFILES_DIR — running update..."
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$CHEZMOI_TMP_DIR" update \
        || die "chezmoi update failed"
else
    info "Cloning dotfiles to $DOTFILES_DIR and applying..."
    # Use the same flags as the documented install command in README
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$CHEZMOI_TMP_DIR" \
        init --source "$DOTFILES_DIR" --apply "$DOTFILES_REPO" \
        || die "chezmoi init failed — check output above for details"
fi
rm -rf "$CHEZMOI_TMP_DIR"
success "chezmoi apply complete"

# ── 6. Install all mise tools ─────────────────────────────────────────────────
step "6/7  mise tool install"
MISE_CONFIG="$HOME/.config/mise/config.toml"
if [[ ! -f "$MISE_CONFIG" ]]; then
    die "Expected mise config at $MISE_CONFIG — chezmoi apply may have failed"
fi

info "Trusting mise config and installing all tools (go, node, python, kubectl, gh, ...)..."
info "This will take several minutes on a fresh machine."
"$HOME/.local/bin/mise" trust "$MISE_CONFIG" 2>/dev/null || true
"$HOME/.local/bin/mise" install || warn "Some mise tools failed — run 'mise install' manually to retry"
success "mise tools installed"
echo ""
"$HOME/.local/bin/mise" list

# ── 7. Set fish as default shell ──────────────────────────────────────────────
step "7/7  Default shell → fish"
FISH_PATH=""
for p in /opt/homebrew/bin/fish /usr/local/bin/fish; do
    if [[ -x "$p" ]]; then FISH_PATH="$p"; break; fi
done

if [[ -z "$FISH_PATH" ]]; then
    die "fish not found — the fish install in step 3 should have succeeded above"
fi

# On MDM-managed work Macs, security policy blocks editing /etc/shells and
# running chsh. chezmoi deploys ~/.zshrc with an exec-into-fish guard instead.
if grep -qF "$FISH_PATH" /etc/shells 2>/dev/null; then
    # /etc/shells already has fish — we can use chsh normally
    if [[ "$SHELL" != "$FISH_PATH" ]]; then
        info "Changing default shell to fish (you may be prompted for your password)..."
        chsh -s "$FISH_PATH" < /dev/tty || warn "chsh failed — fish will still launch via ~/.zshrc"
        success "Default shell → $FISH_PATH"
    else
        success "fish is already the default shell"
    fi
else
    # /etc/shells is not writable (common on corporate Macs)
    if echo "$FISH_PATH" | sudo tee -a /etc/shells > /dev/null 2>&1; then
        info "Changing default shell to fish (you may be prompted for your password)..."
        chsh -s "$FISH_PATH" < /dev/tty || warn "chsh failed — fish will still launch via ~/.zshrc"
        success "Default shell → $FISH_PATH"
    else
        warn "/etc/shells is policy-restricted — skipping chsh"
        info "fish will auto-launch via ~/.zshrc (deployed by chezmoi)"
    fi
fi

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
success "Bootstrap complete!"
echo ""
echo "  Open a new terminal to start using fish."
  echo "  To keep everything up to date, open fish and run: dotup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
