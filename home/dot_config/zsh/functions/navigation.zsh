mcd() {
    mkdir -p -- "$1" && cd -- "$1"
}

croot() {
    local root
    root=$(git rev-parse --show-toplevel) || return
    cd -- "$root"
}

reload-zsh() {
    exec zsh
}

ghq-fzf() {
    local root repository
    root=$(ghq root) || return
    repository=$(ghq list | \
        fzf --preview "eza -la --git '$root'/{}") || return
    BUFFER="cd ${(q)root}/${(q)repository}"
    zle accept-line
}

zle -N ghq-fzf
bindkey '^g' ghq-fzf
