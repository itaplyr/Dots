# ── Fish Shell Configuration ───────────────────────────────

# Aliases
alias ll 'ls -la'
alias la 'ls -A'
alias l 'ls -CF'
alias gs 'git status'
alias gp 'git push'
alias gl 'git log --oneline --graph'
alias gd 'git diff'
alias cat 'bat --paging=never'
alias grep 'rg'

# Environment
set -gx EDITOR nvim
set -gx BROWSER firefox
set -gx XDG_CONFIG_HOME ~/.config
set -gx XDG_DATA_HOME ~/.local/share
set -gx XDG_STATE_HOME ~/.local/state

# Fish greeting
function fish_greeting
    echo "Welcome back, $(whoami)"
end

# Prompt
function fish_prompt
    set_color cyan
    echo -n (prompt_pwd)
    set_color normal
    echo -n ' > '
end

# Key bindings
function fish_user_key_bindings
    bind \cr history-pager
    bind \cf forward-word
    bind \cb backward-word
end

# PATH
fish_add_path ~/.local/bin
fish_add_path ~/.cargo/bin
