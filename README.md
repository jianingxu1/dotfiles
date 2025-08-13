# Dotfiles Setup

This repository contains my personal dotfiles for macOS.  
It uses [GNU Stow](https://www.gnu.org/software/stow/) to manage symlinks.

## Prerequisites

1. Install Homebrew
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## Installation Steps

1. **Clone this repository**
```bash
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

2. **Install all the applications, casks, taps, and dependencies listed within Brewfile**
```bash
brew bundle
```

2. **Create symlinks of your .dotfiles into parent directory**
```bash
stow .
```
