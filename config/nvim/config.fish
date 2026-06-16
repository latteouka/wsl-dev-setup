#install fish
#install Oh-my-fish for theme
#install fisher for installing plugin
#install shellder(theme) z(jump) colored_man_pages

source ~/.zshrc

set fish_greeting ""

set -gx TERM xterm-256color

# theme
set -g theme_color_scheme terminal-dark
set -g fish_prompt_pwd_dir_length 0
set -g theme_display_user yes
set -g theme_hide_hostname no
set -g theme_hostname always

# aliases
alias ls "eza --icons"
alias la "eza -A"
alias ll "eza -l -g --icons"
alias lla "ll -A"
alias lah "ll -Ah"
alias g git
alias gp "git push"
alias ga "git add ."
alias gc "git commit -m"
alias vim nvim
alias v nvim
alias vr "nvim -R"
alias y yarn
alias d docker
alias k kubectl
alias c clear
alias note 'cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/Notes && vim'

command -qv nvim && alias vim nvim

if type -q exa
    alias ll "exa -l -g --icons"
    alias lla "ll -a"
end

set -gx EDITOR nvim

set -gx PATH bin $PATH
set -gx PATH ~/bin $PATH
set -gx PATH ~/.local/bin $PATH
set -gx PATH /opt/homebrew/bin $PATH
set -gx PATH /opt/homebrew/sbin $PATH
set -gx PATH /usr/sbin $PATH
set -gx PATH /sbin $PATH
set -gx PATH /usr/local/bin $PATH
set -gx PATH /Library/Apple/usr/bin $PATH
set -gx PATH /Library/Frameworks/Python.framework/Versions/3.9/bin $PATH
set -gx PATH /Users/chunn/Library/Python/3.9/bin $PATH
set -gx PATH /Users/chunn/.yarn/bin $PATH
set -gx PATH ~/Library/Android/sdk/emulator $PATH
set -gx PATH ~/Library/Android/sdk/tools $PATH
set -gx PATH ~/Library/Android/sdk/tools/bin $PATH
set -gx PATH ~/Library/Android/sdk/platform-tools $PATH
# set -gx PATH ~/Library/Android/sdk/build-tools/31.0.0 $PATH
set -gx PATH /usr/local/opt/ruby/bin $PATH
set -gx PATH ~/.rbenv/bin $PATH
set -gx PATH ~/.rbenv/shims $PATH
set -gx PATH /usr/local/opt/ruby/bin $PATH
set -gx PATH /usr/local/lib/ruby/gems/3.0.0/bin $PATH

# nodes
set -gx PATH ~/.local/share/nvm/v20.16.0/bin $PATH

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
# if test -f /opt/anaconda3/bin/conda
#     eval /opt/anaconda3/bin/conda "shell.fish" "hook" $argv | source
# else
#     if test -f "/opt/anaconda3/etc/fish/conf.d/conda.fish"
#         . "/opt/anaconda3/etc/fish/conf.d/conda.fish"
#     else
#         set -x PATH "/opt/anaconda3/bin" $PATH
#     end
# end
# <<< conda initialize <<<


status is-interactive; and source (pyenv init --path | psub)
