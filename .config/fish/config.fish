# 1. Add user paths and environment variables first
fish_add_path $HOME/.local/bin
fish_add_path $HOME/.pyenv/shims
set -x EDITOR /opt/homebrew/bin/nvim
set -x PYTHONPATH $HOME/.local/lib/python $PYTHONPATH
set -x ERL_AFLAGS "-kernel shell_history enabled"

mise activate fish | source

fish_add_path $(go env GOPATH)/bin

# 3. Initialize Homebrew after ASDF
eval "$(/opt/homebrew/bin/brew shellenv)"

# 4. Source Google Cloud SDK
source "$(brew --prefix)/share/google-cloud-sdk/path.fish.inc"

# 5. Interactive shell tools
if status is-interactive
    zoxide init fish | source
    starship init fish | source
end

export MISE_ENV_FILE=.env

# 6. FZF options and aliases
set fzf_fd_opts --hidden --max-depth 5
alias lazy_commit="git diff --cached | sgpt -s \"Generate git commit message, for my changes. never use git add.\""
alias lazy_branch="git diff --cached | sgpt -s \"Create branch name based on the changes\""
alias lazy_pr="gh pr create --fill && gh pr merge --auto --squash"
alias aider="aider --config $HOME/.config/aider/aider.conf.yaml"

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init2.fish 2>/dev/null || :
