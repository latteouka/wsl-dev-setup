#!/bin/bash
# WSL Dev Environment Setup
# Runs inside WSL (Ubuntu) to set up the full dev environment.
# Can be called by Phase 1 PowerShell script, or run standalone.

set -e

# ─── Colors ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

success() { echo -e "  ${GREEN}[✓]${NC} $1"; }
warn()    { echo -e "  ${YELLOW}[!]${NC} $1"; }
fail()    { echo -e "  ${RED}[✗]${NC} $1"; }
header()  { echo -e "\n${CYAN}${BOLD}── $1 ──${NC}"; }

# ─── Globals ──────────────────────────────────────────────────────────────────
REPO_URL="https://github.com/latteouka/wsl-dev-setup.git"
REPO_DIR="$HOME/wsl-dev-setup"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

# ─── Helpers ──────────────────────────────────────────────────────────────────

backup_file() {
    local src="$1"
    if [ -e "$src" ] || [ -L "$src" ]; then
        mkdir -p "$BACKUP_DIR"
        cp -a "$src" "$BACKUP_DIR/"
        warn "Backed up: $src -> $BACKUP_DIR/"
    fi
}

backup_dir() {
    local src="$1"
    if [ -d "$src" ] || [ -L "$src" ]; then
        mkdir -p "$BACKUP_DIR"
        cp -a "$src" "$BACKUP_DIR/"
        warn "Backed up: $src -> $BACKUP_DIR/"
    fi
}

# ─── 1. Confirmation Prompt ──────────────────────────────────────────────────

echo ""
echo -e "${CYAN}${BOLD}"
echo " ╭──────────────────────────────────────────────────╮"
echo " │           WSL Dev Environment Setup              │"
echo " ├──────────────────────────────────────────────────┤"
echo " │  This script will:                               │"
echo " │                                                  │"
echo " │  1. Install apt packages (fish, tmux, nvim, ...) │"
echo " │  2. Clone / update wsl-dev-setup repo            │"
echo " │  3. Set up Fish shell config                     │"
echo " │  4. Set up Tmux config + tpm                     │"
echo " │  5. Set up Neovim config (symlink)               │"
echo " │  6. Configure Git (interactive)                  │"
echo " │  7. Install Claude Code                          │"
echo " │  8. Set up Claude Code settings + skills         │"
echo " │  9. Set default shell to Fish                    │"
echo " │                                                  │"
echo " │  Existing configs will be backed up to:          │"
echo " │    ~/.dotfiles_backup/{timestamp}/               │"
echo " ╰──────────────────────────────────────────────────╯"
echo -e "${NC}"

read -rp "  Continue? [Y/n] " confirm
if [[ "$confirm" =~ ^[Nn] ]]; then
    echo "  Aborted."
    exit 0
fi

# ─── 2. Install apt packages ─────────────────────────────────────────────────

header "Installing apt packages"

sudo apt-get update -y

# eza: add community repo if eza is not already available
if ! dpkg -s eza &>/dev/null; then
    if ! apt-cache show eza &>/dev/null 2>&1; then
        warn "Adding eza community repo..."
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
            | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
            | sudo tee /etc/apt/sources.list.d/gierens.list > /dev/null
        sudo chmod 644 /etc/apt/keyrings/gierens.gpg
        sudo apt-get update -y
    fi
fi

sudo apt-get install -y \
    fish tmux neovim git curl wget unzip \
    eza fd-find ripgrep fzf \
    build-essential

success "apt packages installed"

# ─── 3. Clone repo ───────────────────────────────────────────────────────────

header "wsl-dev-setup repo"

if [ -d "$REPO_DIR/.git" ]; then
    warn "Repo already exists, pulling latest..."
    git -C "$REPO_DIR" pull --ff-only && success "Repo updated" || warn "Pull failed (diverged?), skipping"
else
    git clone "$REPO_URL" "$REPO_DIR"
    success "Repo cloned to $REPO_DIR"
fi

# ─── 4. Fish config ──────────────────────────────────────────────────────────

header "Fish shell config"

mkdir -p "$HOME/.config/fish"

# config.fish
backup_file "$HOME/.config/fish/config.fish"
cp "$REPO_DIR/config/fish/config.fish" "$HOME/.config/fish/config.fish"
success "config.fish installed"

# fish_plugins
backup_file "$HOME/.config/fish/fish_plugins"
cp "$REPO_DIR/config/fish/fish_plugins" "$HOME/.config/fish/fish_plugins"
success "fish_plugins installed"

# Install fisher + plugins (place function file first, then update — avoids reload loops)
mkdir -p "$HOME/.config/fish/functions"
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish \
    -o "$HOME/.config/fish/functions/fisher.fish"
success "fisher function installed"

FISH_PATH="$(which fish)"
if [ -x "$FISH_PATH" ]; then
    success "Installing fisher plugins (tide, z, nvm, etc.)..."
    "$FISH_PATH" -c 'fisher update'
    success "fisher plugins installed"

    # Configure tide: single-line, compact, no extra spaces
    "$FISH_PATH" -c 'set -U tide_left_prompt_items context pwd git character'
    "$FISH_PATH" -c 'set -U tide_prompt_add_newline_before false'
    "$FISH_PATH" -c 'set -U tide_left_prompt_suffix ""'
    success "tide configured (single-line, compact)"
fi

# ─── 5. Tmux config ──────────────────────────────────────────────────────────

header "Tmux config"

backup_file "$HOME/.tmux.conf"
cp "$REPO_DIR/config/tmux.conf" "$HOME/.tmux.conf"
success "tmux.conf installed"

# Install tpm
if [ -d "$HOME/.tmux/plugins/tpm" ]; then
    success "tpm already installed"
else
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    success "tpm installed (run prefix + I inside tmux to install plugins)"
fi

# ─── 6. Neovim config ────────────────────────────────────────────────────────

header "Neovim config"

if [ -L "$HOME/.config/nvim" ] && [ "$(readlink "$HOME/.config/nvim")" = "$REPO_DIR/config/nvim" ]; then
    success "nvim config already symlinked"
else
    backup_dir "$HOME/.config/nvim"
    rm -rf "$HOME/.config/nvim"
    ln -s "$REPO_DIR/config/nvim" "$HOME/.config/nvim"
    success "nvim config symlinked (lazy.nvim will auto-install plugins on first open)"
fi

# ─── 7. Git config ───────────────────────────────────────────────────────────

header "Git config"

backup_file "$HOME/.gitconfig"

echo ""
echo -e "  ${CYAN}Enter your Git identity:${NC}"
read -rp "    Name:  " git_name
read -rp "    Email: " git_email

if [ -z "$git_name" ] || [ -z "$git_email" ]; then
    warn "Name or email empty, skipping gitconfig generation"
else
    cat > "$HOME/.gitconfig" << EOF
[user]
	name = $git_name
	email = $git_email
[core]
	ignorecase = false
	editor = nvim
[alias]
	st = status
	ci = commit
	ca = commit -a
	br = branch
[init]
	defaultBranch = main
[pull]
	rebase = false
EOF
    success "gitconfig written for $git_name <$git_email>"
fi

# ─── 8. Install Claude Code ──────────────────────────────────────────────────

header "Claude Code"

if command -v claude &>/dev/null; then
    success "Claude Code already installed: $(claude --version 2>/dev/null || echo 'unknown version')"
else
    warn "Installing Claude Code..."
    curl -fsSL https://claude.ai/install.sh | bash
    success "Claude Code installed"
fi

# ─── 9. Claude Code settings + skills ────────────────────────────────────────

header "Claude Code settings & skills"

# Settings
mkdir -p "$HOME/.claude"

backup_file "$HOME/.claude/settings.json"
cp "$REPO_DIR/claude/settings.json" "$HOME/.claude/settings.json"
success "Claude settings.json installed"

# Skills — symlink ALL directories under $REPO_DIR/skills/
mkdir -p "$HOME/.claude/skills"

for skill_dir in "$REPO_DIR/skills"/*/; do
    [ -d "$skill_dir" ] || continue
    skill="$(basename "$skill_dir")"
    src="$REPO_DIR/skills/$skill"
    dest="$HOME/.claude/skills/$skill"
    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
        success "Skill already linked: $skill"
    else
        rm -rf "$dest"
        ln -s "$src" "$dest"
        success "Skill linked: $skill"
    fi
done

# CLAUDE.md files
mkdir -p "$HOME/projects"

backup_file "$HOME/CLAUDE.md"
cp "$REPO_DIR/claude/CLAUDE.md" "$HOME/CLAUDE.md"
success "~/CLAUDE.md installed"

backup_file "$HOME/projects/CLAUDE.md"
cp "$REPO_DIR/claude/projects-CLAUDE.md" "$HOME/projects/CLAUDE.md"
success "~/projects/CLAUDE.md installed"

# ─── 10. Set default shell to Fish ───────────────────────────────────────────

header "Default shell"

FISH_PATH="$(which fish)"

if ! grep -qxF "$FISH_PATH" /etc/shells; then
    echo "$FISH_PATH" | sudo tee -a /etc/shells > /dev/null
    success "Added $FISH_PATH to /etc/shells"
fi

if [ "$SHELL" = "$FISH_PATH" ]; then
    success "Default shell is already fish"
else
    sudo chsh -s "$FISH_PATH" "$USER"
    success "Default shell set to fish"
fi

# ─── 11. Node.js check ───────────────────────────────────────────────────────

header "Node.js"

if command -v node &>/dev/null; then
    success "Node.js found: $(node --version)"
else
    warn "Node.js not found"
    echo -e "  ${YELLOW}After opening a new Fish shell, run:${NC}"
    echo -e "  ${BOLD}  nvm install lts${NC}"
    echo -e "  ${YELLOW}(nvm.fish plugin will handle the rest)${NC}"
fi

# ─── 12. Completion ──────────────────────────────────────────────────────────

echo ""
echo -e "${GREEN}${BOLD}"
echo " ╭──────────────────────────────────────────────────╮"
echo " │           Setup Complete!                        │"
echo " ├──────────────────────────────────────────────────┤"
echo " │                                                  │"
echo " │  Next steps:                                     │"
echo " │                                                  │"
echo " │  1. Close this terminal window                   │"
echo " │  2. Open Windows Terminal → Ubuntu               │"
echo " │  3. Run: nvm install lts                         │"
echo " │  4. Run: claude   (to login)                     │"
echo " │  5. Open nvim once to install plugins            │"
echo " │  6. In tmux, press prefix + I to install plugins │"
echo " │                                                  │"
echo " ├──────────────────────────────────────────────────┤"
echo " │  Backups:  ~/.dotfiles_backup/                   │"
echo " │  Repo:     ~/wsl-dev-setup                       │"
echo " ╰──────────────────────────────────────────────────╯"
echo -e "${NC}"
