# WSL Fish Shell Config
# Adapted from macOS dotfiles — removed Homebrew / macOS-specific paths

function fish_greeting
    echo ' ╭─────────────────────────────────────╮'
    echo ' │  Dev Environment Ready              │'
    echo ' ├─────────────────────────────────────┤'
    echo ' │  cd <dir>     進入目錄              │'
    echo ' │  mkdir <name> 建立目錄              │'
    echo ' │  cl           啟動 Claude Code      │'
    echo ' │  clr          恢復上次 Claude 對話  │'
    echo ' │  ll           列出檔案（詳細）      │'
    echo ' │  z <keyword>  快速跳轉目錄          │'
    echo ' │  Ctrl+R       搜尋歷史指令          │'
    echo ' │  tmux         開啟多視窗終端        │'
    echo ' ╰─────────────────────────────────────╯'
end

# Vim mode
fish_vi_key_bindings

# 停用 Ctrl+U（預設會刪除整行）
bind --erase --preset -M insert ctrl-u
bind --erase --preset -M default ctrl-u

# 語法高亮顏色（Tokyo Night）
set -g fish_color_normal normal
set -g fish_color_command white
set -g fish_color_keyword blue
set -g fish_color_quote yellow
set -g fish_color_redirection cyan
set -g fish_color_end green
set -g fish_color_error red
set -g fish_color_param cyan
set -g fish_color_comment brblack
set -g fish_color_selection --background=brblack
set -g fish_color_operator cyan
set -g fish_color_escape yellow
set -g fish_color_autosuggestion brblack
set -g fish_color_valid_path --underline

# Fisher 自動安裝與插件同步
if not functions -q fisher
    and not set -q __fisher_installing
    set -g __fisher_installing 1
    echo "Installing fisher + plugins (one-time setup)..."
    curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
    fisher update
    set -e __fisher_installing
end

# aliases
alias ls "eza --icons"
alias la "eza -A"
alias ll "eza -l -g --icons"
alias lla "ll -A"
alias lah "ll -Ah"
alias g git
alias gf "git fetch"
alias ga "git add ."
alias gc "git commit -m"
alias vim nvim
alias v nvim
alias vr "nvim -R"
alias p pnpm
alias d docker
alias c clear
alias k kubectl

command -qv nvim && alias vim nvim

if type -q exa
    alias ll "exa -l -g --icons"
    alias lla "ll -a"
end

set -gx EDITOR nvim

# PATH — WSL paths only
set -gx PATH ~/.local/bin $PATH
set -gx PATH ~/bin $PATH
set -gx PATH /usr/local/bin $PATH

# Node.js — 由 nvm.fish 管理，設定 nvm_default_version 為 lts

# Claude Code
alias cl "claude --dangerously-skip-permissions"
alias clr "claude --dangerously-skip-permissions --resume"
