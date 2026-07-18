git-whoami() {
    mise run git-identity
}

ghcr() {
    gh repo create "$@" || return
    ghq get "$1" || return
    code "$(ghq list --full-path -e "$1")"
}
