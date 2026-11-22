# Working in this repository

Be concise, direct, and practical. Use plain language. Be critical and honest when asked for advice.

Keep this file concise and update it whenever repository structure, setup, or validation changes.

This is a personal dotfiles repository for macOS and Ubuntu. The interactive shell is Zsh; the installer is Bash. Edit the repository files that own a setting, using the map below. Keep changes small and preserve existing comments and unrelated local edits.

## Where to make changes

| Change                                                              | File or directory                                         |
| ------------------------------------------------------------------- | --------------------------------------------------------- |
| Shell aliases and small command shortcuts                           | `source/60_aliases.sh`                                    |
| PATH ordering                                                       | `source/01_path.sh`                                       |
| Zgenom plugins, completions, shell integrations                     | `source/20_plugins.sh`                                    |
| Prompt appearance configuration loading                | `source/30_p10k.sh`                                       |
| Prompt appearance and displayed segments                            | `link/.p10k.zsh`                                          |
| Default editor, `q`, `qv`, `qs` helpers                             | `source/50_editor.sh`                                     |
| History and autosuggestion settings                                 | `source/50_history.sh`                                    |
| fzf bindings and previews                            | `source/70_fzf.sh`                                        |
| Remote tmux attachment helper (`rtmux`)                             | `source/70_tmux.sh`                                       |
| Shell entry point and `src`/`dotfiles` functions | `link/.zshrc`                                             |
| tmux keys, panes, windows, status bar                               | `link/.tmux.conf`                                         |
| Ghostty settings                                                    | `config/ghostty/config`                                   |
| Vim options, mappings, plugins, colors                              | `link/.vimrc`                                             |
| Neovim options, mappings, autocmds                                  | `config/nvim/lua/config/{options,keymaps,autocmds}.lua`   |
| Neovim plugin additions and overrides                               | New Lua specs in `config/nvim/lua/plugins/`               |
| Neovim bootstrap and LazyVim setup                                  | `config/nvim/init.lua`, `config/nvim/lua/config/lazy.lua` |
| LazyVim extras and pinned plugin versions                           | `config/nvim/lazyvim.json`, `config/nvim/lazy-lock.json`  |
| Neovim Lua formatting                                               | `config/nvim/stylua.toml` (2 spaces, 120 columns)         |
| Shared Git configuration template                                   | `copy/.gitconfig`                                         |
| Global Git ignore patterns                                          | `link/.gitignore_global`                                  |
| macOS CLI tools, GUI apps, Mac App Store apps                       | `conf/packages/Brewfile`                                  |
| Ubuntu packages                                                     | `conf/packages/apt`                                       |
| Installation, updates, copies, symlinks, init selection             | `bin/dotfiles`                                            |
| OS-specific setup and installation steps                            | `init/*.sh`                                               |
| User-facing installation documentation                              | `README.md`, `conf/README_zsh_setup.md`                   |

## Shell loading order

1. `~/.zshrc` links to `link/.zshrc`, which loads the instant prompt and sets `DOTFILES=~/.dotfiles`.
2. Its `src` function sources **every entry** in `source/` in filename order.
3. `source/00_dotfiles.sh` sources `bin/dotfiles` with the `source` argument. This defines shared helpers and returns before installer actions.
4. The remaining files load PATH, plugins, prompt, editor/history, aliases, then fzf/tmux helpers.

Put new shell behavior in the appropriate existing `source/` file. If it needs its own file, use a numbered `.sh` filename that places it after its dependencies. These files run in Zsh despite the extension. Do not place notes, backups, or subdirectories in `source/`: the loader does not filter for `.sh`.

`src 60_aliases` reloads a single module; `src` reloads all modules. `source ~/.zshrc` reloads the entry point. The `dotfiles` shell function runs the full installer and then `src`; it is not just a shell reload.

Zgenom manages plugins, Oh My Zsh (`plugins=(git)`), and Powerlevel10k through `source/20_plugins.sh`. Changes invalidate the saved setup in a fresh shell and may download plugins. Existing shells keep their loaded plugins. Native fzf widgets load once via `conf/zsh/fzf.zsh`, before fzf-tab, autosuggestions, and highlighting. `source/70_fzf.sh` only sets fzf options.

## Installation and file ownership

`bin/dotfiles` is a self-contained Bash installer. It updates the checkout and submodules, then processes these directories in order:

- `copy/`: copies each top-level entry into `~/`. `copy/.gitconfig` is a template; edits to it do not immediately change `~/.gitconfig`. The installer can skip a newer destination.
- `link/`: symlinks each top-level entry into `~/`, including hidden files and whole directories. For example, `link/.tmux.conf` becomes `~/.tmux.conf`.
- `config/`: symlinks each top-level entry into `~/.config/`, currently `ghostty` and `nvim`. Missing parent directories are created before linking.
- `init/`: selects and sources scripts in filename order, with OS-based defaults and remembered selections in `caches/init/selected`.

Existing destinations may be moved into timestamped `backups/` directories. Running the installer can pull Git changes, replace home-directory configs, install or upgrade packages, and update Vim plugins. Do not use it as a routine validation command.

Init scripts:

- `20_osx_homebrew.sh`: installs Homebrew if missing, runs doctor/update, and defines Homebrew helpers.
- `20_ubuntu_apt.sh`: updates APT and installs `conf/packages/apt`.
- `30_osx_homebrew_recipes.sh`: upgrades packages, installs `mas`, applies the Brewfile, and cleans up.
- `50_vim.sh`: creates `caches/vim`, downloads vim-plug if needed, and upgrades/updates Vim plugins.

Edit repository sources directly. Before assuming a home-directory file reflects the repo, inspect its symlink.

## Dependencies and generated files

- `link/.zgenom` is a Git submodule configured in `.gitmodules`. Change plugin declarations in `source/20_plugins.sh`; do not patch dependency code for ordinary configuration work.
- `link/.zgenom/sources/` contains downloaded plugins and generated initialization files.
- `link/.vim/plugged/` and `link/.vim/autoload/plug.vim` are installed dependencies, ignored by Git. Vim can install missing dependencies on startup.
- `config/nvim/lua/plugins/example.lua` is disabled by an early `return {}`. Add actual plugin specs in separate files. Neovim startup can bootstrap lazy.nvim and install plugins.
- `caches/`, `backups/`, tmux plugin/resurrect directories, and names containing `LOCAL` are ignored by the repository's `.gitignore`. Do not commit generated state or secrets. `LOCAL` files placed in `source/` still get sourced.
- Use `git ls-files` for the maintained file inventory. Broad recursive searches include many downloaded plugins; scope searches to the owning directory and exclude dependencies.

## Validation

Run regression tests with `python3 -m unittest discover -s test -v`. Installer tests mock setup commands; plugin tests run Zgenom with local fixtures. Both use temporary directories without network access. There is no CI configuration. Report what was actually checked.

For shell syntax checks without executing startup or installer actions:

```sh
zsh -f -n link/.zshrc
zsh -f -n link/.p10k.zsh
for file in source/*.sh; do zsh -f -n "$file" || break; done
bash -n bin/dotfiles
for file in init/*.sh; do bash -n "$file" || break; done
git diff --check
```

These checks do not prove runtime behavior. Shell startup can download or update plugins. Test interactive behavior deliberately when relevant. For tmux changes, use a separate test server/socket so the user's active sessions are unaffected.

Start and finish with `git status --short` and inspect the diff. If Git reports an fsmonitor IPC error, use `git -c core.fsmonitor=false status --short` for that invocation instead of changing Git settings.

## Documentation caveats

Use the current files as the source of truth. `README.md` contains inherited references to absent Bash entry points, `vendor/`, Xcode and cask init scripts. `conf/README_zsh_setup.md` mentions an absent Zsh setup script and `.zshenv`, and describes an older plugin setup. Do not recreate those files or follow those paths solely because the older docs mention them.
