# 1. Add user paths and environment variables first
fish_add_path $HOME/.local/bin
fish_add_path $HOME/.pyenv/shims
set -x EDITOR /opt/homebrew/bin/nvim
set -x PYTHONPATH $HOME/.local/lib/python $PYTHONPATH
set -x ERL_AFLAGS "-kernel shell_history enabled"

# 2. Source ASDF early to ensure its shims take priority
source /opt/homebrew/opt/asdf/libexec/asdf.fish
set -gx PATH $HOME/.asdf/shims $PATH

# 3. Initialize Homebrew after ASDF
eval "$(/opt/homebrew/bin/brew shellenv)"

set -gx PATH $HOME/.asdf/shims (string match -v $HOME/.asdf/shims $PATH)

# 4. Source Google Cloud SDK
source "$(brew --prefix)/share/google-cloud-sdk/path.fish.inc"

# 5. Interactive shell tools
if status is-interactive
    direnv hook fish | source
    zoxide init fish | source
    starship init fish | source
end

# 6. FZF options and aliases
set fzf_fd_opts --hidden --max-depth 5
alias lazy_commit="git diff --cached | sgpt -s \"Generate git commit message, for my changes. never use git add.\""
alias lazy_branch="git diff --cached | sgpt -s \"Create branch name based on the changes\""
alias lazy_pr="gh pr create --fill && gh pr merge --auto --squash"
alias aider="aider --config $HOME/.config/aider/aider.conf.yaml"
