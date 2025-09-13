# OSX-only stuff. Abort if not OSX.
is_osx || return 1

# Import iTerm2 preferences if the plist file exists
ITERM2_PLIST="$DOTFILES/conf/iterm2_preferences.plist"

if [[ -f "$ITERM2_PLIST" ]]; then
  e_header "Importing iTerm2 preferences"
  
  # Check if iTerm2 is running and warn user
  if pgrep -x "iTerm2" > /dev/null; then
    e_arrow "iTerm2 is currently running. Preferences will be imported but may require restart to take effect."
  fi
  
  # Import the preferences
  defaults import com.googlecode.iterm2 "$ITERM2_PLIST"
  
  e_success "iTerm2 preferences imported successfully"
  e_arrow "Restart iTerm2 to apply all settings"
else
  e_error "iTerm2 preferences file not found at $ITERM2_PLIST"
fi

# Set iTerm2 to load preferences from a custom folder (optional)
# This allows for better sync across machines
ITERM2_PREFS_DIR="$DOTFILES/conf/iterm2"
if [[ -d "$ITERM2_PREFS_DIR" ]]; then
  e_header "Setting iTerm2 to use custom preferences directory"
  defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$ITERM2_PREFS_DIR"
  defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
  e_success "iTerm2 configured to use custom preferences directory"
fi
