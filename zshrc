# Set custom prompt
autoload -Uz compinit promptinit vcs_info colors
compinit -D 
promptinit
colors

# This will set the default prompt to the X theme, preview prompt themes with 'prompt -p'
prompt suse

setopt histignorealldups sharehistory
zstyle ':vcs_info:*' enable git svn
# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

# add vcs_info to prompt
zstyle ':vcs_info:*' enable git svn
zstyle ':vcs_info:*' formats "%F{010}(%b)%f "
precmd() { vcs_info }
setopt prompt_subst
PROMPT='%m:%n @ %F{green}%1d \$%f ${vcs_info_msg_0_}'

## Options section
setopt correct                                                  # Auto correct mistakes
setopt extendedglob                                             # Extended globbing. Allows using regular expressions with *
setopt nocaseglob                                               # Case insensitive globbing
setopt rcexpandparam                                            # Array expension with parameters
setopt nocheckjobs                                              # Don't warn about running processes when exiting
setopt numericglobsort                                          # Sort filenames numerically when it makes sense
setopt nobeep                                                   # No beep
setopt appendhistory                                            # Immediately append history instead of overwriting
setopt histignorealldups                                        # If a new command is a duplicate, remove the older one
setopt autocd                                                   # if only directory path is entered, cd there.
setopt inc_append_history                                       # save commands are added to the history immediately, otherwise only when shell exits.
setopt histignorespace                                          # Don't save commands that start with space

# Use modern completion system
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# Color man pages
export LESS_TERMCAP_mb=$'\E[01;32m'
export LESS_TERMCAP_md=$'\E[01;32m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;47;34m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;36m'
export LESS=-R

# Nicer history
export HISTSIZE=100000
export HISTFILE="$HOME/.history"
export SAVEHIST=$HISTSIZE

# By default, zsh considers many characters part of a word (e.g., _ and -).
# Narrow that down to allow easier skipping through words via M-f and M-b.
export WORDCHARS='*?[]~&;!$%^<>'
# Use vim as the editor
export EDITOR=vim
#
# Useful functions
#
function clean_docker(){
  docker volume rm $(docker volume ls -qf dangling=true) || true;
  docker rmi $(docker images --filter "dangling=true" -q --no-trunc) || true;
  docker rmi $(docker images | grep "none" | awk '/ / { print $3 }') || true;
  docker rm $(docker ps -qa --no-trunc --filter "status=exited") || true;
  docker volume rm $(docker volume ls -f 'dangling=true') || true;
}

# Compression
compress() { tar -czf "${1%/}.tar.gz" "${1%/}"; }
alias decompress="tar -xzf"
#
if [[ -d "$HOME/bin" ]]; then
  export PATH="$HOME/bin:$PATH"
fi

export FZF_DEFAULT_COMMAND="rg --files --hidden --glob '!.git/**' --glob '!build/**' --glob '!.dart_tool/**' --glob '!.idea' --glob '!node_modules'"
#
# useful aliases
#
alias ls="ls --color=auto"
# File system
alias ls='eza -lh --group-directories-first --icons'
alias lsa='ls -a'
alias lt='eza --tree --level=2 --long --icons --git'
alias lta='lt -a'
alias ff="fzf --preview 'bat --style=numbers --color=always {}'"
# Directories
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
#
# zsh plugins
#
# Check if zplug is installed
if [[ ! -d ~/.zplug_repo ]]; then
  echo "zplug not found, cloning repository" \
    && git clone https://github.com/zplug/zplug ~/.zplug_repo \
    && source ~/.zplug_repo/init.zsh && zplug update --self
fi
# Essential loading of init.zsh 
source ~/.zplug_repo/init.zsh
# 
zplug "plugins/git", from:oh-my-zsh
# zplug "plugins/sudo", from:oh-my-zsh
# zplug "plugins/command-not-found", from:oh-my-zsh
# Make sure to use double quotes to prevent shell expansion
zplug "zsh-users/zsh-syntax-highlighting"
zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-history-substring-search"
zplug "zsh-users/zsh-completions"
# zplug "themes/robbyrussell", from:oh-my-zsh, as:theme   # Theme
# Load theme file
#zplug 'dracula/zsh', as:theme

# zplug - install/load new plugins when zsh is started or reloaded
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi
zplug load 

## 
## setup zellij
##
#if [[ -z "$ZELLIJ" ]]; then
#  if [[ "$ZELLIJ_AUTO_ATTACH" == "true" ]]; then
#    zellij attach -c
#  else
#    zellij
#  fi

#  if [[ "$ZELLIJ_AUTO_EXIT" == "true" ]]; then
#    exit
#  fi
#fi

