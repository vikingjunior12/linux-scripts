#!/bin/bash

# Arch Linux Application Install Script
# Einfach erweiterbar durch Hinzufügen von Programmen zu den Arrays

set -e # Exit bei Fehler

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging Funktionen
log_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

# ============================================
# PACMAN PROGRAMME
# Hier neue pacman-Programme hinzufügen
# ============================================
PACMAN_APPS=(
  "neovim"
  "speedtest-cli"
  "alacritty"
  "micro"
  "bitwarden"
  "zsh"
  "geany"
  "nextcloud-client"
  "firefox"
  "tmux"
  "lsd"
  "eza"
  "chromium"
  "git"
  "zoxide"
  "base-devel" # Benötigt für yay
  "npm"        # Benötigt für CLI-Agents
  "noto-fonts"
  "noto-fonts-cjk"
  "noto-fonts-emoji"
  "ttf-dejavu"
  "ttf-liberation"
  "inter-font"
  "fastfetch"
  "curl"

)

# ============================================
# YAY/AUR PROGRAMME
# Hier neue AUR-Programme hinzufügen
# ============================================
YAY_APPS=(
  # Beispiel: "visual-studio-code-bin"
  "powershell-bin"
  "visual-studio-code-bin"
  "nordvpn-bin"
)

# ============================================
# NPM GLOBALE PAKETE
# Hier neue npm-Pakete hinzufügen
# ============================================
NPM_PACKAGES=(
  "@anthropic-ai/claude-code"
  "@openai/codex"
)

# ============================================
# YAY Installation Check und Installation
# ============================================
install_yay() {
  log_info "Prüfe ob yay installiert ist..."

  if command -v yay &>/dev/null; then
    log_success "yay ist bereits installiert"
    return 0
  fi

  log_warning "yay ist nicht installiert. Installiere yay..."

  # Temporäres Verzeichnis für yay Installation
  TMP_DIR=$(mktemp -d)
  cd "$TMP_DIR"

  # base-devel und git werden für yay benötigt
  log_info "Installiere Abhängigkeiten für yay (base-devel, git)..."
  sudo pacman -S --needed --noconfirm base-devel git

  # yay klonen und installieren
  log_info "Clone yay Repository..."
  git clone https://aur.archlinux.org/yay.git
  cd yay

  log_info "Baue und installiere yay..."
  makepkg -si --noconfirm

  # Aufräumen
  cd ~
  rm -rf "$TMP_DIR"

  if command -v yay &>/dev/null; then
    log_success "yay wurde erfolgreich installiert"
  else
    log_error "yay Installation fehlgeschlagen"
    exit 1
  fi
}

# ============================================
# PACMAN Programme installieren
# ============================================
install_pacman_apps() {
  log_info "Starte Installation von pacman-Programmen..."
  echo ""

  # System Update
  log_info "Aktualisiere System..."
  sudo pacman -Syu --noconfirm

  # Durchlaufe alle pacman apps
  for app in "${PACMAN_APPS[@]}"; do
    if pacman -Qi "$app" &>/dev/null; then
      log_success "$app ist bereits installiert"
    else
      log_info "Installiere $app..."
      sudo pacman -S --needed --noconfirm "$app"
      log_success "$app wurde installiert"
    fi
  done

  echo ""
  log_success "Alle pacman-Programme wurden verarbeitet"
}

# ============================================
# YAY/AUR Programme installieren
# ============================================
install_yay_apps() {
  if [ ${#YAY_APPS[@]} -eq 0 ]; then
    log_info "Keine AUR-Programme in der Liste"
    return 0
  fi

  log_info "Starte Installation von AUR-Programmen..."
  echo ""

  # Durchlaufe alle yay apps
  for app in "${YAY_APPS[@]}"; do
    if yay -Qi "$app" &>/dev/null; then
      log_success "$app ist bereits installiert"
    else
      log_info "Installiere $app..."
      yay -S --needed --noconfirm "$app"
      log_success "$app wurde installiert"
    fi
  done

  echo ""
  log_success "Alle AUR-Programme wurden verarbeitet"
}

# ============================================
# NPM Pakete global installieren
# ============================================
install_npm_packages() {
  if [ ${#NPM_PACKAGES[@]} -eq 0 ]; then
    log_info "Keine npm-Pakete in der Liste"
    return 0
  fi

  # Prüfe ob npm installiert ist
  if ! command -v npm &>/dev/null; then
    log_error "npm ist nicht installiert. Bitte installiere npm zuerst."
    return 1
  fi

  log_info "Starte Installation von npm-Paketen (global)..."
  echo ""

  # Durchlaufe alle npm packages
  for package in "${NPM_PACKAGES[@]}"; do
    # Prüfe ob Paket bereits installiert ist
    if npm list -g "$package" &>/dev/null; then
      log_success "$package ist bereits installiert"
    else
      log_info "Installiere $package..."
      sudo npm install -g "$package"
      log_success "$package wurde installiert"
    fi
  done

  echo ""
  log_success "Alle npm-Pakete wurden verarbeitet"
}

# ============================================
# Zusammenfassung anzeigen
# ============================================
show_summary() {
  echo ""
  echo "============================================"
  log_success "Installation abgeschlossen!"
  echo "============================================"
  echo ""
  echo "Installierte Programme:"
  echo ""
  echo "PACMAN:"
  for app in "${PACMAN_APPS[@]}"; do
    echo "  - $app"
  done

  if [ ${#NPM_PACKAGES[@]} -gt 0 ]; then
    echo ""
    echo "NPM (global):"
    for package in "${NPM_PACKAGES[@]}"; do
      echo "  - $package"
    done
  fi

  if [ ${#YAY_APPS[@]} -gt 0 ]; then
    echo ""
    echo "AUR (yay):"
    for app in "${YAY_APPS[@]}"; do
      echo "  - $app"
    done
  fi
  echo ""
}

# ============================================
# MAIN
# ============================================
main() {
  echo ""
  echo "============================================"
  echo "  Arch Linux Application Install Script"
  echo "============================================"
  echo ""

  # Prüfe ob Script als root läuft
  if [ "$EUID" -eq 0 ]; then
    log_error "Bitte führe dieses Script NICHT als root aus!"
    log_info "Das Script wird sudo verwenden wenn nötig."
    exit 1
  fi

  # yay installieren falls nötig
  install_yay
  echo ""

  # pacman Programme installieren
  install_pacman_apps
  echo ""

  # npm Pakete installieren
  install_npm_packages
  echo ""

  # yay/AUR Programme installieren
  install_yay_apps

  # Zusammenfassung
  show_summary

  log_info "Tipp: Vergiss nicht 'chsh -s \$(which zsh)' auszuführen um zsh als Standard-Shell zu setzen"
}

# Script starten
main
