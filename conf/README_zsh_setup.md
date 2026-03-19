# Zsh + Oh My Zsh + Powerlevel10k Setup

This dotfiles configuration includes automated setup for:

- **Zsh** as the default shell
- **Oh My Zsh** framework
- **Powerlevel10k** theme
- **Useful zsh plugins**

## What gets installed

### Init Scripts
- `30_osx_zsh_setup.sh`: Installs Oh My Zsh, Powerlevel10k, and useful plugins

### Linked Files
- `.zshrc`: Main zsh configuration
- `.p10k.zsh`: Powerlevel10k theme configuration
- `.zshenv`: Environment variables

### Plugins Installed
- **zsh-autosuggestions**: Fish-like autosuggestions
- **zsh-syntax-highlighting**: Syntax highlighting for commands
- **git**: Git aliases and functions
- **brew**: Homebrew completions
- **macos**: macOS-specific aliases

## Manual Steps After Running Dotfiles

1. **Restart your terminal** or run `exec zsh` to switch to zsh
3. **Run `p10k configure`** if you want to reconfigure the prompt

## Customization

### Adding More Plugins
Edit `~/.dotfiles/link/.zshrc` and add plugins to the `plugins=()` array.

### Customizing the Prompt
Run `p10k configure` or edit `~/.dotfiles/link/.p10k.zsh` directly.

## Compatibility

The setup maintains compatibility with the existing bash-based dotfiles:
- All `source/*.sh` files are loaded in zsh
- Bash functions and aliases work in zsh
- The setup gracefully handles both bash and zsh environments
