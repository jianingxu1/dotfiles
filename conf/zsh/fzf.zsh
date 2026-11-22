# Initialize native fzf widgets once, before completion and highlighting plugins.
# Install fzf through the package lists instead of downloading it on shell startup.
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi
