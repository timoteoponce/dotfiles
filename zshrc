# Set custom prompt
autoload -Uz compinit promptinit
compinit
promptinit

# This will set the default prompt to the walters theme
prompt fire

setopt histignorealldups sharehistory

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

# Initialize completion
autoload -U compinit
compinit -D
# Use modern completion system
autoload -Uz compinit
compinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
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

# Nicer history
export HISTSIZE=100000
export HISTFILE="$HOME/.history"
export SAVEHIST=$HISTSIZE

# By default, zsh considers many characters part of a word (e.g., _ and -).
# Narrow that down to allow easier skipping through words via M-f and M-b.
export WORDCHARS='*?[]~&;!$%^<>'

alias la='ls -alh --git'
alias fsl='fossil'
alias ls='ls --color=auto'

# others
source ~/.sdkman/bin/sdkman-init.sh

export SBT_OPTS="-Xmx1G -XX:+UseConcMarkSweepGC -XX:+CMSClassUnloadingEnabled -XX:MaxPermSize=1G -Xss2M  -Duser.timezone=GMT"
export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin


# Use vim as the editor
export EDITOR=vim

function clean_docker(){
  docker volume rm $(docker volume ls -qf dangling=true) || true;
  docker rmi $(docker images --filter "dangling=true" -q --no-trunc) || true;
  docker rmi $(docker images | grep "none" | awk '/ / { print $3 }') || true;
  docker rm $(docker ps -qa --no-trunc --filter "status=exited") || true;
  docker volume rm $(docker volume ls -f 'dangling=true') || true;
}
# Utils
function mkcd() { mkdir -p $1 && cd $1 }
function cdf() { cd *$1*/ } # stolen from @topfunky

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


export PATH="$HOME/bin:$PATH"
# rbenv

export FZF_DEFAULT_COMMAND="rg --files --hidden --glob '!.git/**' --glob '!build/**' --glob '!.dart_tool/**' --glob '!.idea' --glob '!node_modules'"

export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
