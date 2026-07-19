# ── Fish Shell Configuration ───────────────────────────────

# Aliases
alias ll 'ls -la'
alias la 'ls -A'
alias l 'ls -CF'
alias nv 'nvim'
alias kl 'pkill -9'
alias ga 'git add'
alias gc 'git commit'
alias gm 'git commit -m'
alias gp 'git push'
alias cat 'bat --paging=never'
alias grep 'rg'
alias pcm 'sudo pacman'

# Environment
set -gx EDITOR nvim
set -gx BROWSER google-chrome-stable
set -gx XDG_CONFIG_HOME ~/.config
set -gx XDG_DATA_HOME ~/.local/share
set -gx XDG_STATE_HOME ~/.local/state

# PATH (fast, no duplicates)
set -gx PATH ~/.local/bin ~/.cargo/bin $PATH

# Prompt
function fish_prompt
    set_color cyan
    echo -n (prompt_pwd)
    set_color normal
    echo -n ' ~> '
end

set fish_greeting
if status is-interactive
    if test $LINES -ge 15 -a $COLUMNS -ge 90
        fastfetch
    end
end
