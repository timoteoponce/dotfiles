# Entry point. Keep this tiny — real config lives in conf.d/*.fish, which fish
# sources automatically (in filename order) before this file.

if not status is-interactive
    exit
end

set -gx EDITOR nvim
set -gx VISUAL nvim

# Machine-local, untracked: work config, installer snippets (grok, opencode), etc.
# Created by install.sh if missing; never linked from the repo.
test -f ~/.config/fish/local.fish; and source ~/.config/fish/local.fish
