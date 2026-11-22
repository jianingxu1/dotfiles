# Dotfiles

## Installation

### macOS
```sh
export DOTFILES_GH_USER=jianingxu1
export DOTFILES_GH_BRANCH=main
bash -c "$(curl -fsSL https://raw.github.com/$DOTFILES_GH_USER/dotfiles/$DOTFILES_GH_BRANCH/bin/dotfiles)" && source ~/.zshrc
```

Or:
```sh
git clone https://github.com/jianingxu1/dotfiles.git ~/.dotfiles --recursive
~/.dotfiles/bin/dotfiles
source ~/.zshrc
```

### To update the dotfiles:
```sh
dotfiles
```

### To upgrade installed macOS packages:
```sh
brew bundle install --upgrade --file="$HOME/.dotfiles/conf/packages/Brewfile"
```

The installer uses `--no-upgrade` and does not run blanket upgrades or cleanup.
Homebrew doctor warnings are shown but do not block package installation. Update and installation failures still stop setup.

To retry just the package installation:
```sh
eval "$(/opt/homebrew/bin/brew shellenv)"
brew bundle install --no-upgrade --file="$HOME/.dotfiles/conf/packages/Brewfile"
```

### To modify the dotfiles:
Just modify the ~/.dotfiles repository that has been cloned in your machine, and add the commits.

To push the changes, you have to before:
Use a personal SSH key for this repository (when you already have a work key)
If your machine already uses a work SSH key tied to your company GitHub, pushes from this repo may fail or be attributed to the wrong account. By creating a separate personal key and wiring this repo to use it (via an SSH host alias), you can keep both keys side-by-side without affecting other repos.

1) Generate a personal key and add it to your GitHub account:
```sh
ssh-keygen -t rsa -b 4096 -C "58917306+jianingxu1@users.noreply.github.com" -f ~/.ssh/id_rsa_personal
cat ~/.ssh/id_rsa_personal.pub
# Add this key to GitHub: Settings -> SSH and GPG keys -> New SSH key
```

2) Tell SSH to use this key when talking to a "personal" GitHub host alias:
```sh
cat >> ~/.ssh/config <<'EOF'
Host github.com-personal
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_rsa_personal
  IdentitiesOnly yes
EOF
```

3) Set repo-local identity and point the remote at the personal host alias:
```sh
cd ~/.dotfiles
git config user.email 58917306+jianingxu1@users.noreply.github.com
git config user.name "Jianing Xu"
git remote set-url origin git@github.com-personal:jianingxu1/dotfiles.git
# Now pushes from this repo will use your personal key
```

## Index

- [About this project](#about-this-project)
- [How the "dotfiles" command works](#how-the-dotfiles-command-works)
  - [Other subdirectories](#other-subdirectories)
  - [The "copy" step](#the-copy-step)
  - [The "link" step](#the-link-step)
  - [The "config" step](#the-config-step)
  - [The "init" step](#the-init-step)
    - [OS X](#os-x)
    - [Ubuntu](#ubuntu)
    - [Both](#both)
- [Hacking my dotfiles](#hacking-my-dotfiles)
- [Aliases and Functions](#aliases-and-functions)
- [Validation](#validation)
- [Inspiration](#inspiration)
- [License](#license)

## About this project

I've been using bash on-and-off for a long time (since Slackware Linux was distributed on 1.44MB floppy disks). In all that time, every time I've set up a new Linux or OS X machine, I've copied over my `.bashrc` file and my `~/bin` folder to each machine manually. And I've never done a very good job of actually maintaining these files. It's been a total mess.

I finally decided that I wanted to be able to execute a single command to "bootstrap" a new system to pull down all of my dotfiles and configs, as well as install all the tools I commonly use. In addition, I wanted to be able to re-execute that command at any time to synchronize anything that might have changed. Finally, I wanted to make it easy to re-integrate changes back in, so that other machines could be updated.

That command is [dotfiles][dotfiles], and this is my "dotfiles" Git repo.

[dotfiles]: bin/dotfiles

## How the "dotfiles" command works

When [dotfiles][dotfiles] is run for the first time, it does a few things:

1. In Ubuntu, Git is installed if necessary via APT (it's already there in OSX).
1. This repo is cloned into your user directory, under `~/.dotfiles`.
1. Files in `/copy` are copied into `~/`. ([read more](#the-copy-step))
1. Files in `/link` are symlinked into `~/`. ([read more](#the-link-step))
1. Directories in `/config` are symlinked into `~/.config/`.
1. You are prompted to choose scripts in `/init` to be executed. The installer attempts to only select relevant scripts, based on the detected OS and the script filename.
1. Your chosen init scripts are executed (in alphanumeric order, hence the funky names). ([read more](#the-init-step))

On subsequent runs, step 1 is skipped, step 2 just updates the already-existing repo, and the init selection remembers what you selected the last time. The other steps are the same.

### Other subdirectories

* The `/backups` directory gets created when necessary. Any files in `~/` that would have been overwritten by files in `/copy` or `/link` get backed up there.
* The `/bin` directory contains executable shell scripts (including the [dotfiles][dotfiles] script) and symlinks to executable shell scripts. This directory is added to the path.
* The `/caches` directory contains cached files, used by some scripts or functions.
* The `/conf` directory just exists. If a config file doesn't **need** to go in `~/`, reference it from the `/conf` directory.
* The `/source` directory contains files that are sourced whenever a new shell is opened (in alphanumeric order, hence the funky names).
* The `/config` directory holds app configs linked into `~/.config/`.
* The `/test` directory contains installer and plugin-startup regression tests.

### The "copy" step
Any file in the `/copy` subdirectory will be copied into `~/`. Any file that _needs_ to be modified with personal information (like [copy/.gitconfig](copy/.gitconfig) which contains a name, email address, and shared Git defaults) should be _copied_ into `~/`. Because the file you'll be editing is no longer in `~/.dotfiles`, it's less likely to be accidentally committed into your public dotfiles repo.

### The "link" step
Any file in the `/link` subdirectory gets symlinked into `~/` with `ln -s`. Edit one or the other, and you change the file in both places. Don't link files containing sensitive data, or you might accidentally commit that data! If you're linking a directory that might contain sensitive data (like `~/.ssh`) add the sensitive files to your [.gitignore](.gitignore) file!

### The "config" step
Each top-level entry in `/config` is linked into `~/.config/`. The installer creates missing parent directories and backs up existing destinations. Currently this installs Ghostty and Neovim configuration.

### The "init" step
Selected scripts in `/init` are sourced in filename order. Failures stop the installer. Homebrew setup installs declared packages with `--no-upgrade`; installing missing dependencies may still require dependency upgrades. Vim setup updates its plugins.

#### OS X

* Homebrew via the [init/20_osx_homebrew.sh](init/20_osx_homebrew.sh) script
* Homebrew formulae, casks, and Mac App Store apps from `conf/packages/Brewfile` via the [init/30_osx_homebrew_recipes.sh](init/30_osx_homebrew_recipes.sh) script

#### Ubuntu
* APT packages from `conf/packages/apt` via the [init/20_ubuntu_apt.sh](init/20_ubuntu_apt.sh) script

#### Both
* Vim plugins via the [init/50_vim.sh](init/50_vim.sh) script

## Hacking my dotfiles

Because the [dotfiles][dotfiles] script is completely self-contained, you should be able to delete everything else from your dotfiles repo fork, and it will still work. Its installation steps process the `/copy`, `/link`, `/config` and `/init` subdirectories, which will be ignored if they are empty or don't exist.

## Aliases and Functions
The Zsh entry point is `link/.zshrc`. Add aliases, functions, and settings to the numbered files in `source/`; use `source/60_aliases.sh` for shortcuts. Every entry in `source/` is sourced in filename order, so keep notes and backups elsewhere.

Zgenom manages Oh My Zsh, Powerlevel10k, and plugins in `source/20_plugins.sh`. Plugin-list changes rebuild the saved setup in a fresh shell. Native fzf integration loads once through `conf/zsh/fzf.zsh`; `source/70_fzf.sh` holds its options. See [the Zsh guide](conf/README_zsh_setup.md) and [the repository map](AGENTS.md).

Use `src 60_aliases` to reload aliases or `src` to reload all modules. The `dotfiles` command also updates the repository and runs installation steps.

## Validation

```sh
python3 -m unittest discover -s test -v
```

The tests use temporary directories and local fixtures without installing packages or downloading plugins. They do not replace testing a real fresh installation or interactive terminal.

## Inspiration
<https://github.com/gf3/dotfiles>  
<https://github.com/mathiasbynens/dotfiles>  
(and 15+ years of accumulated crap)

## License
Copyright (c) 2014 "Cowboy" Ben Alman  
Licensed under the MIT license.  
<http://benalman.com/about/license/>
