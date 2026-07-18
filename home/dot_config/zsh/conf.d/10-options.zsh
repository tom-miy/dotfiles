HISTFILE="$HOME/.zsh_history"
HISTSIZE=1000000
SAVEHIST=1000000

setopt EXTENDED_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_NO_STORE
setopt SHARE_HISTORY
setopt AUTO_CD
setopt EXTENDED_GLOB
setopt NO_FLOW_CONTROL
unsetopt BEEP

bindkey -v
KEYTIMEOUT=2

bindkey '^[[A' history-beginning-search-backward
bindkey '^[[B' history-beginning-search-forward
bindkey '^[[3~' delete-char
bindkey '^[[1~' beginning-of-line
bindkey '^[[H' beginning-of-line
bindkey '^[[4~' end-of-line
bindkey '^[[F' end-of-line

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^xe' edit-command-line
