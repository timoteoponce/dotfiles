

# Added by Toolbox App
export PATH="$PATH:/Users/timoteo/Library/Application Support/JetBrains/Toolbox/scripts"
# others
if [[ -e ~/.sdkman/bin/sdkman-init.sh ]]; then
  source ~/.sdkman/bin/sdkman-init.sh
fi

export SBT_OPTS="-Xmx1G -XX:+UseConcMarkSweepGC -XX:+CMSClassUnloadingEnabled -XX:MaxPermSize=1G -Xss2M  -Duser.timezone=GMT"

if [[ -d "$HOME/go" ]]; then
  export GOROOT=$HOME/go
  export GOPATH=$HOME/projects/go
  export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
fi

if [[ -d "$HOME/.nvm" ]]; then
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
fi

if [[ -d "$HOME/.rbenv" ]]; then
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init - zsh)"
fi


# Set PATH, MANPATH, etc., for Homebrew.
eval "$(/opt/homebrew/bin/brew shellenv)"
