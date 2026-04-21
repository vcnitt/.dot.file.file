#!/bin/bash
# Prompt for password once and keep sudo alive
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Install all available macOS updates (will apply on final reboot)
sudo softwareupdate -i -a

# Install Xcode Command Line Tools silently
if ! xcode-select -p &>/dev/null; then
  touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
  CLT_LABEL=$(softwareupdate -l 2>/dev/null | grep -B 1 "Command Line Tools" | awk -F'*' '/^ *\*/ {print $2}' | sed 's/^ Label: //' | tr -d '\n' | head -1)
  if [ -n "$CLT_LABEL" ]; then
    sudo softwareupdate -i "$CLT_LABEL" --verbose
  fi
  rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
fi
until xcode-select -p &>/dev/null; do sleep 5; done

# Install Homebrew
if ! command -v brew &>/dev/null; then
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
# Add Homebrew to PATH (Apple Silicon)
eval "$(/opt/homebrew/bin/brew shellenv)"

# Write Brewfile to temp location and run it
BREWFILE=$(mktemp)
cat > "$BREWFILE" << 'EOF'
# Password manager
cask "1password"
# Anthropic's official Claude AI desktop app
cask "claude"
# JetBrains DataGrip
cask "datagrip"
# GitHub command-line tool
brew "gh"
# Distributed revision control system
brew "git"
# Desktop client for GitHub repositories
cask "github"
# Web browser
cask "google-chrome"
# JetBrains tools manager
cask "jetbrains-toolbox"
# Tableau Desktop
cask "tableau"
# Connect to Windows
cask "windows-app"
EOF
brew bundle --file="$BREWFILE"
rm "$BREWFILE"

# ----- SQL Server drivers for Tableau -----

# Install Microsoft ODBC driver
brew tap microsoft/mssql-release https://github.com/Microsoft/homebrew-mssql-release
HOMEBREW_ACCEPT_EULA=Y brew install msodbcsql18

# Install Microsoft JDBC driver for Tableau
mkdir -p ~/Library/Tableau/Drivers
curl -L "https://go.microsoft.com/fwlink/?linkid=2356504" -o /tmp/sqljdbc.tar.gz
tar -xzf /tmp/sqljdbc.tar.gz -C /tmp
cp /tmp/sqljdbc_*/enu/jars/mssql-jdbc-*jre11.jar ~/Library/Tableau/Drivers/

# ----- macOS settings -----

# Mouse: turn off natural scrolling
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# Screenshots: disable Shift+Cmd+3, Shift+Cmd+4, Shift+Cmd+5
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 28 "{enabled = 0;}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 29 "{enabled = 0;}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 30 "{enabled = 0;}"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 184 "{enabled = 0;}"
# Remap "copy selected area to clipboard" to Cmd+4
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 31 "{enabled = 1; value = { parameters = (52, 21, 1048576); type = standard; }; }"

# Dock: clear all default apps, then add the ones you want
defaults write com.apple.dock persistent-apps -array
defaults write com.apple.dock persistent-apps -array-add \
  "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/System/Applications/Notes.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>" \
  "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/System/Applications/System Settings.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>" \
  "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Microsoft Teams.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>" \
  "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Microsoft Edge.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>" \
  "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Microsoft Outlook.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>" \
  "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Claude.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>" \
  "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/DataGrip.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>" \
  "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/1Password.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"

# Apply Dock/menu bar changes
killall Dock
killall SystemUIServer

# Reboot in 10 seconds to apply all settings and finalize updates
echo "Setup complete. Rebooting in 10 seconds..."
sleep 10
sudo shutdown -r now
