# WSL Fish Shell Config
# Adapted from macOS dotfiles — removed Homebrew / macOS-specific paths

function fish_greeting
    set -l c (set_color cyan)
    set -l g (set_color green)
    set -l y (set_color yellow)
    set -l m (set_color magenta)
    set -l d (set_color brblack)
    set -l r (set_color normal)
    echo ""
    echo " "$d"╭─────────────────────────────────────╮"$r
    echo " "$d"│"$r"  "$g"Dev Environment Ready"$r"              "$d"│"$r
    echo " "$d"├─────────────────────────────────────┤"$r
    echo " "$d"│"$r"  "$c"cd"$r" <dir>     "$d"進入目錄"$r"              "$d"│"$r
    echo " "$d"│"$r"  "$c"mkdir"$r" <name> "$d"建立目錄"$r"              "$d"│"$r
    echo " "$d"│"$r"  "$y"cl"$r"           "$d"啟動 Claude Code"$r"      "$d"│"$r
    echo " "$d"│"$r"  "$y"clr"$r"          "$d"恢復上次 Claude 對話"$r"  "$d"│"$r
    echo " "$d"│"$r"  "$c"ll"$r"           "$d"列出檔案（詳細）"$r"      "$d"│"$r
    echo " "$d"│"$r"  "$m"z"$r" <keyword>  "$d"快速跳轉目錄"$r"          "$d"│"$r
    echo " "$d"│"$r"  "$m"Ctrl+R"$r"       "$d"搜尋歷史指令"$r"          "$d"│"$r
    echo " "$d"│"$r"  "$c"tmux"$r"         "$d"開啟多視窗終端"$r"        "$d"│"$r
    echo " "$d"╰─────────────────────────────────────╯"$r
    echo ""
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

# 確保起始目錄是家目錄（WSL 可能繼承 Windows 路徑）
if string match -q '/mnt/*' (pwd)
    cd ~
end

# PATH — WSL paths only
set -gx PATH ~/.local/bin $PATH
set -gx PATH ~/bin $PATH
set -gx PATH /usr/local/bin $PATH

# Node.js — 由 nvm.fish 管理，設定 nvm_default_version 為 lts

# Claude Code
alias cl "claude --dangerously-skip-permissions"
alias clr "claude --dangerously-skip-permissions --resume"

# 自動進入 tmux（如果不在 tmux 內且是互動 shell）
if status is-interactive
    and not set -q TMUX
    tmux new-session -A -s main
end
