#!/bin/bash
# Prompt for password once and keep sudo alive
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

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
