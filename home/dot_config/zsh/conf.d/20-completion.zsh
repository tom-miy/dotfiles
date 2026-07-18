export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43'

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list \
    '' \
    'm:{a-zA-Z}={A-Za-z}' \
    'r:|[._-]=* r:|=*' \
    'l:|=* r:|=*'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$HOME/.cache/zsh"
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' \
    format '%F{yellow}-- %d --%f'
zstyle ':completion:*:messages' \
    format '%F{purple}-- %d --%f'
zstyle ':completion:*:warnings' \
    format '%F{red}No matches found%f'
zstyle ':completion:*:processes' \
    command 'ps -u $USER -o pid,user,comm -w'
zstyle ':completion:*:ssh:*' hosts off
zstyle ':completion:*:scp:*' hosts off
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:git-*:*' group-order \
    heads-local heads-remote \
    branches-local branches-remote
zstyle ':completion:*' file-sort modification
zstyle ':completion:*' list-dirs-first true
zstyle ':completion:*' ignored-patterns \
    '*.pyc' '*.pyo' '*.bak' '*.swp' '*~'

zstyle ':fzf-tab:complete:cd:*' \
    fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:complete:ls:*' \
    fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:complete:*:*' \
    fzf-preview 'less ${(Q)realpath}'
zstyle ':fzf-tab:*' fzf-flags \
    --color=fg:1,fg+:2 \
    --bind=tab:accept
zstyle ':fzf-tab:*' use-fzf-default-opts yes
