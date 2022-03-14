source ~/.sdkman/bin/sdkman-init.sh

export SBT_OPTS="-Xmx1G -XX:+UseConcMarkSweepGC -XX:+CMSClassUnloadingEnabled -XX:MaxPermSize=1G -Xss2M  -Duser.timezone=GMT"
export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

alias la='ls -alh --git'
alias fsl='fossil'

# Nicer history
export HISTSIZE=100000
export HISTFILE="$HOME/.history"
export SAVEHIST=$HISTSIZE

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


export PATH="/usr/local/sbin:$PATH"
# rbenv

export FZF_DEFAULT_COMMAND="rg --files --hidden --glob '!.git/**' --glob '!build/**' --glob '!.dart_tool/**' --glob '!.idea' --glob '!node_modules'"
