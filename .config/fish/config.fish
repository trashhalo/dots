eval "$(/opt/homebrew/bin/brew shellenv)"
direnv hook fish | source
zoxide init fish | source
if status is-interactive
    starship init fish | source
end
fish_add_path $HOME/.local/bin
fish_add_path $HOME/.pyenv/shims
export EDITOR=/opt/homebrew/bin/nvim
set -x PYTHONPATH $HOME/.local/lib/python $PYTHONPATH
export ERL_AFLAGS="-kernel shell_history enabled"
source /opt/homebrew/opt/asdf/libexec/asdf.fish
source "$(brew --prefix)/share/google-cloud-sdk/path.fish.inc"
set fzf_fd_opts --hidden --max-depth 5
alias lazy_commit="git diff --cached | sgpt -s \"Generate git commit message, for my changes. never use git add.\""
alias lazy_branch="git diff --cached | sgpt -s \"Create branch name based on the changes\""
alias lazy_pr="gh pr create --fill && gh pr merge --auto --squash"
alias aider="aider --config $HOME/.config/aider/aider.conf.yaml"
