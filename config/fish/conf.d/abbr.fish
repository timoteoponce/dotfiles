# Abbreviations expand inline before running, so history stays honest and
# you keep learning the real commands.

status is-interactive; or exit

# --- git ---
abbr -a g    git
abbr -a gs   'git st'
abbr -a ga   'git add'
abbr -a gaa  'git add --all'
abbr -a gc   'git commit'
abbr -a gcm  'git commit -m'
abbr -a gca  'git commit --amend'
abbr -a gco  'git checkout'
abbr -a gsw  'git switch'
abbr -a gd   'git df'
abbr -a gds  'git df --staged'
abbr -a gl   'git lg'
abbr -a gp   'git push'
abbr -a gpf  'git push --force-with-lease'
abbr -a gpl  'git pull'
abbr -a gf   'git fetch'
abbr -a gb   'git branch'
abbr -a grb  'git rebase'
abbr -a grbi 'git rebase -i'
abbr -a gst  'git stash'
abbr -a gsp  'git stash pop'

# --- docker ---
abbr -a d    docker
abbr -a dc   'docker compose'
abbr -a dcu  'docker compose up -d'
abbr -a dcd  'docker compose down'
abbr -a dcl  'docker compose logs -f'
abbr -a dps  'docker ps'
abbr -a dpsa 'docker ps -a'
abbr -a di   'docker images'
abbr -a dex  'docker exec -it'
abbr -a dl   'docker logs -f'

# --- dirs ---
abbr -a ..   'cd ..'
abbr -a ...  'cd ../..'
abbr -a .... 'cd ../../..'
