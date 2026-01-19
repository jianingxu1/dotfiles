# Consolidate PATH with clear priority order:
# 1. Local bin (highest priority for user overrides)
# 2. Dotfiles bin
# 3. User bin
# 4. System paths
# 5. Homebrew (lower priority to not override system)
PATH="$HOME/.local/bin:$DOTFILES/bin:$HOME/bin:/usr/local/sbin:$PATH:/opt/homebrew/bin:/opt/homebrew/sbin"

export -U PATH