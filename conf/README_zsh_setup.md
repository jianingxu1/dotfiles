# Zsh setup

The installer links `link/.zshrc`, `link/.p10k.zsh`, and the Zgenom submodule into your home directory. It installs Zsh through the OS package list; it does not change your login shell. Select Zsh in your terminal or use `chsh` separately if needed.

On startup, `link/.zshrc` loads the instant-prompt cache and then the numbered files in `source/`.

## Plugins and completions

Edit `source/20_plugins.sh`. Zgenom manages:

- Oh My Zsh with the `git` plugin and completion initialization.
- Extra Zsh completions, native fzf widgets, and fzf-tab.
- alias-tips, zoxide, zsh-dot-up, and Zgenom updates.
- Powerlevel10k, autosuggestions, and syntax highlighting.

The first fresh shell after a plugin-list change rebuilds the saved setup and may download plugins. Existing shells retain their loaded plugins. Install fzf and zoxide through the package lists before opening the shell. Native fzf integration requires a version supporting `fzf --zsh`.

Keep fzf widgets before fzf-tab, then autosuggestions and syntax highlighting. Do not initialize the framework or fzf again in other startup files.

## Where to customize

| Setting | File |
| --- | --- |
| Plugin list and order | `source/20_plugins.sh` |
| Native fzf initialization | `conf/zsh/fzf.zsh` |
| fzf keys and preview options | `source/70_fzf.sh` |
| Prompt appearance | `link/.p10k.zsh` or `p10k configure` |
| Aliases | `source/60_aliases.sh` |
| PATH | `source/01_path.sh` |
| History and autosuggestions | `source/50_history.sh` |

Use `src 60_aliases` to reload aliases. Open a fresh shell to apply plugin-list changes. The interactive configuration uses Zsh syntax despite the `.sh` extension; Bash runs the installer only.
