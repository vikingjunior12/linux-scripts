#!/bin/bash

# Tmux Setup Script with Catppuccin Theme
# This script installs tmux and configures it with the Catppuccin Mocha theme

set -e

echo "=================================="
echo "  Tmux Setup with Catppuccin"
echo "=================================="

# Check if tmux is installed, if not install it
if ! command -v tmux &> /dev/null; then
    echo "tmux is not installed. Installing..."

    # Detect package manager and install
    if command -v apt-get &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y tmux
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y tmux
    elif command -v yum &> /dev/null; then
        sudo yum install -y tmux
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm tmux
    elif command -v zypper &> /dev/null; then
        sudo zypper install -y tmux
    else
        echo "Error: Could not detect package manager. Please install tmux manually."
        exit 1
    fi

    echo "tmux installed successfully!"
else
    echo "tmux is already installed ($(tmux -V))"
fi

# Create tmux config directory
echo "Creating tmux configuration directory..."
mkdir -p ~/.config/tmux/plugins

# Clone Catppuccin theme
echo "Downloading Catppuccin theme..."
CATPPUCCIN_DIR=~/.config/tmux/plugins/catppuccin/tmux
if [ -d "$CATPPUCCIN_DIR" ]; then
    echo "Catppuccin already exists. Updating..."
    cd "$CATPPUCCIN_DIR"
    git pull
    cd - > /dev/null
else
    mkdir -p ~/.config/tmux/plugins/catppuccin
    git clone -b v2.1.3 https://github.com/catppuccin/tmux.git "$CATPPUCCIN_DIR"
    echo "Catppuccin theme downloaded successfully!"
fi

# Create tmux configuration file
echo "Creating tmux configuration..."
cat > ~/.config/tmux/tmux.conf << 'EOF'
# Options to make tmux more pleasant
set -g mouse on
set -g default-terminal "tmux-256color"
set-option -g status-position top

# Configure the catppuccin plugin
set -g @catppuccin_flavor "mocha"
set -g @catppuccin_window_status_style "rounded"

# Load catppuccin
run ~/.config/tmux/plugins/catppuccin/tmux/catppuccin.tmux

# Make the status line pretty and add some modules
set -g status-right-length 100
set -g status-left-length 100
set -g status-left ""
set -g status-right "#{E:@catppuccin_status_application}"
set -ag status-right "#{E:@catppuccin_status_session}"
EOF

# Create symlink to standard location if needed
if [ ! -f ~/.tmux.conf ] && [ ! -L ~/.tmux.conf ]; then
    echo "Creating symlink from ~/.tmux.conf to ~/.config/tmux/tmux.conf..."
    ln -s ~/.config/tmux/tmux.conf ~/.tmux.conf
elif [ -f ~/.tmux.conf ] && [ ! -L ~/.tmux.conf ]; then
    echo "Warning: ~/.tmux.conf already exists as a regular file."
    echo "Backing it up to ~/.tmux.conf.backup..."
    mv ~/.tmux.conf ~/.tmux.conf.backup
    ln -s ~/.config/tmux/tmux.conf ~/.tmux.conf
fi

# Reload tmux config if server is running
if pgrep -x tmux > /dev/null; then
    echo "Reloading tmux configuration for running sessions..."
    tmux source-file ~/.config/tmux/tmux.conf 2>/dev/null || true
    # Reload for all sessions
    for session in $(tmux list-sessions -F '#{session_name}' 2>/dev/null); do
        tmux source-file ~/.config/tmux/tmux.conf
    done
    echo "Configuration reloaded for existing tmux sessions!"
fi

echo ""
echo "=================================="
echo "  Setup Complete!"
echo "=================================="
echo ""
echo "Configuration saved to: ~/.config/tmux/tmux.conf"
echo "Catppuccin theme installed in: ~/.config/tmux/plugins/catppuccin/tmux"
echo ""
echo "To start using your new tmux configuration:"
echo "  1. If tmux is already running: Close and restart tmux, or press Ctrl+B then : and type 'source ~/.config/tmux/tmux.conf'"
echo "  2. If tmux is not running: Start tmux with: tmux"
echo ""
echo "Note: Make sure you have a Nerd Font installed for proper icon display!"
echo "Enjoy your beautiful tmux setup!"
