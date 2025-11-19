#!/bin/bash

echo "Updating AI CLI tools..."

echo "Updating @anthropic-ai/claude-code..."
if ! sudo npm install -g @anthropic-ai/claude-code@latest; then
    echo "Update failed, cleaning up and retrying..."
    sudo rm -rf /usr/local/lib/node_modules/@anthropic-ai/claude-code
    sudo npm install -g @anthropic-ai/claude-code@latest
fi

echo "Updating @openai/codex..."
if ! sudo npm install -g @openai/codex@latest; then
    echo "Update failed, cleaning up and retrying..."
    sudo rm -rf /usr/local/lib/node_modules/@openai/codex
    sudo npm install -g @openai/codex@latest
fi

echo "Updating @google/gemini-cli..."
sudo npm install -g @google/gemini-cli@latest

echo "All AI CLI tools updated!"
