#!/bin/bash

# Install Xcode Command Line Tools
xcode-select --install 2>/dev/null
until xcode-select -p &>/dev/null; do sleep 5; done

# Install Homebrew
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Add Homebrew to PATH (Apple Silicon)
eval "$(/opt/homebrew/bin/brew shellenv)"

# Write Brewfile to temp location and run it
BREWFILE=$(mktemp)
cat > "$BREWFILE" << 'EOF'
# Distributed revision control system
brew "git"
# GitHub command-line tool
brew "gh"
# Desktop client for GitHub repositories
cask "github"
# Anthropic's official Claude AI desktop app
cask "claude"
# Connect to Windows
cask "windows-app"
# Web browser
cask "google-chrome"
# JetBrains tools manager
cask "jetbrains-toolbox"
# JetBrains DataGrip
cask "datagrip"
# Tableau Desktop
cask "tableau"
EOF

brew bundle --file="$BREWFILE"
rm "$BREWFILE"
