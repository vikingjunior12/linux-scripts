#!/bin/bash

# Ubuntu Setup Script
# Installiert Entwicklungstools und Neovim

set -e # Script bei Fehler beenden

echo "======================================"
echo "Ubuntu Setup Script gestartet"
echo "======================================"
echo ""

# Farben für Output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# System Update
echo -e "${BLUE}[1/4] System wird aktualisiert...${NC}"
sudo apt update && sudo apt upgrade -y
echo -e "${GREEN}✓ System aktualisiert${NC}"
echo ""

# APT Pakete installieren
echo -e "${BLUE}[2/4] Installiere Pakete via apt...${NC}"
PACKAGES=(
  "alacritty"
  "micro"
  "zsh"
  "git"
  "gnome-shell-extensions"
  "gnome-shell-extension-manager"
  "gnome-tweaks"
  "curl"
  "speedtest-cli"
  "wget"
  "zoxide"
  "lsd"
  "eza"
  "tmux"
)

for package in "${PACKAGES[@]}"; do
  echo "  → Installiere $package..."
  sudo apt install -y "$package"
done
echo -e "${GREEN}✓ Alle APT-Pakete installiert${NC}"
echo ""

# Neovim manuell installieren
echo -e "${BLUE}[3/4] Installiere Neovim (latest)...${NC}"
NVIM_DIR="$HOME/.local/share/nvim-install"
NVIM_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"
TEMP_FILE="/tmp/nvim-linux-x86_64.tar.gz"

# Download
echo "  → Lade Neovim herunter von GitHub..."
wget -q --show-progress "$NVIM_URL" -O "$TEMP_FILE"

# Installationsverzeichnis erstellen
echo "  → Erstelle Installationsverzeichnis: $NVIM_DIR"
mkdir -p "$NVIM_DIR"

# Entpacken
echo "  → Entpacke Neovim..."
tar -xzf "$TEMP_FILE" -C "$NVIM_DIR" --strip-components=1

# Aufräumen
rm "$TEMP_FILE"

echo -e "${GREEN}✓ Neovim installiert in: $NVIM_DIR${NC}"
echo ""

# PATH in .zshrc eintragen
echo -e "${BLUE}[4/4] Konfiguriere .zshrc...${NC}"
ZSHRC="$HOME/.zshrc"

# .zshrc erstellen falls nicht vorhanden
if [ ! -f "$ZSHRC" ]; then
  echo "  → Erstelle neue .zshrc Datei..."
  touch "$ZSHRC"
fi

# PATH Eintrag hinzufügen (nur wenn noch nicht vorhanden)
if ! grep -q "$NVIM_DIR/bin" "$ZSHRC"; then
  echo "" >>"$ZSHRC"
  echo "# Neovim PATH (hinzugefügt durch Setup-Script)" >>"$ZSHRC"
  echo "export PATH=\"$NVIM_DIR/bin:\$PATH\"" >>"$ZSHRC"
  echo "  → Neovim PATH zu .zshrc hinzugefügt"
else
  echo "  → Neovim PATH bereits in .zshrc vorhanden"
fi

echo -e "${GREEN}✓ .zshrc konfiguriert${NC}"
echo ""

# Zusammenfassung
echo "======================================"
echo -e "${GREEN}Installation abgeschlossen!${NC}"
echo "======================================"
echo ""
echo "Installierte Software:"
echo "  • alacritty, micro, zsh, git"
echo "  • gnome-extensions, gnome-extension-manager, gnome-tweaks"
echo "  • curl, wget"
echo "  • Neovim (latest) in: $NVIM_DIR"
echo ""
echo "Nächste Schritte:"
echo "  1. Schließe das Terminal und öffne es neu, oder führe aus:"
echo "     source ~/.zshrc"
echo "  2. Teste Neovim mit: nvim --version"
echo "  3. Optional: Wechsle zu zsh mit: chsh -s \$(which zsh)"
echo ""
