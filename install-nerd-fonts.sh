#!/bin/bash

# ============================================================================
# Nerd Fonts Installer
# ============================================================================
# Lädt Nerd Fonts herunter, installiert sie und macht sie im System verfügbar
# Autor: Jonas
# Datum: 2025-11-06
# ============================================================================

set -e  # Bei Fehlern abbrechen

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================================================
# Konfiguration
# ============================================================================
NERD_FONTS_VERSION="v3.1.1"
FONTS_DIR="$HOME/.local/share/fonts"
DOWNLOAD_DIR="/tmp/nerd-fonts-install"

# Liste der zu installierenden Fonts (kann erweitert werden)
FONTS=(
    "FiraCode"
    "Hack"
    "JetBrainsMono"
    "Meslo"
)

# ============================================================================
# Funktionen
# ============================================================================

print_header() {
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${YELLOW}→${NC} $1"
}

# Prüfe ob benötigte Tools installiert sind
check_dependencies() {
    print_header "Prüfe Abhängigkeiten"

    local missing_deps=()

    for cmd in wget unzip fc-cache; do
        if ! command -v $cmd &> /dev/null; then
            missing_deps+=($cmd)
            print_error "$cmd ist nicht installiert"
        else
            print_success "$cmd gefunden"
        fi
    done

    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo ""
        print_error "Fehlende Abhängigkeiten. Bitte installieren mit:"
        echo "sudo apt install wget unzip fontconfig"
        exit 1
    fi
}

# Erstelle notwendige Verzeichnisse
create_directories() {
    print_header "Erstelle Verzeichnisse"

    mkdir -p "$FONTS_DIR"
    print_success "Font-Verzeichnis erstellt: $FONTS_DIR"

    mkdir -p "$DOWNLOAD_DIR"
    print_success "Download-Verzeichnis erstellt: $DOWNLOAD_DIR"
}

# Lade und installiere einen Font
install_font() {
    local font_name=$1
    local url="https://github.com/ryanoasis/nerd-fonts/releases/download/${NERD_FONTS_VERSION}/${font_name}.zip"

    print_info "Lade ${font_name} herunter..."

    # Font herunterladen
    if wget -q --show-progress -O "${DOWNLOAD_DIR}/${font_name}.zip" "$url"; then
        print_success "${font_name} heruntergeladen"
    else
        print_error "Fehler beim Herunterladen von ${font_name}"
        return 1
    fi

    # Font entpacken
    print_info "Entpacke ${font_name}..."
    if unzip -q -o "${DOWNLOAD_DIR}/${font_name}.zip" -d "${FONTS_DIR}/${font_name}" 2>/dev/null; then
        # Verschiebe .ttf Dateien eine Ebene höher und lösche Ordner
        find "${FONTS_DIR}/${font_name}" -name "*.ttf" -exec mv {} "${FONTS_DIR}/" \;
        rm -rf "${FONTS_DIR}/${font_name}"
        print_success "${font_name} entpackt und installiert"
    else
        print_error "Fehler beim Entpacken von ${font_name}"
        return 1
    fi

    # Lösche ZIP-Datei
    rm -f "${DOWNLOAD_DIR}/${font_name}.zip"
}

# Installiere alle Fonts
install_all_fonts() {
    print_header "Installiere Nerd Fonts"

    for font in "${FONTS[@]}"; do
        echo ""
        install_font "$font"
    done
}

# Aktualisiere Font-Cache
update_font_cache() {
    print_header "Aktualisiere Font-Cache"

    print_info "Führe fc-cache aus..."
    if fc-cache -fv "$FONTS_DIR" > /dev/null 2>&1; then
        print_success "Font-Cache erfolgreich aktualisiert"
    else
        print_error "Fehler beim Aktualisieren des Font-Cache"
        exit 1
    fi
}

# Bereinige temporäre Dateien
cleanup() {
    print_header "Räume auf"

    rm -rf "$DOWNLOAD_DIR"
    print_success "Temporäre Dateien gelöscht"
}

# Zeige installierte Nerd Fonts
show_installed_fonts() {
    print_header "Installierte Nerd Fonts"

    echo ""
    fc-list | grep "Nerd Font" | cut -d: -f2 | cut -d, -f1 | sort -u | while read font; do
        echo -e "  ${GREEN}•${NC} $font"
    done
}

# Zeige Konfigurations-Hinweise
show_terminal_config() {
    print_header "Terminal-Konfiguration"

    echo ""
    echo -e "${YELLOW}Um die Nerd Fonts in deinem Terminal zu nutzen:${NC}"
    echo ""

    echo -e "${BLUE}GNOME Terminal:${NC}"
    echo "  1. Öffne Einstellungen (Preferences)"
    echo "  2. Wähle dein Profil → Text"
    echo "  3. Aktiviere 'Benutzerdefinierte Schriftart'"
    echo "  4. Wähle z.B. 'FiraCode Nerd Font Mono' oder 'Hack Nerd Font Mono'"
    echo "  5. Starte Terminal neu"
    echo ""

    echo -e "${BLUE}Alacritty:${NC}"
    echo "  Füge in ~/.config/alacritty/alacritty.yml hinzu:"
    echo -e "  ${GREEN}font:${NC}"
    echo -e "  ${GREEN}  normal:${NC}"
    echo -e "  ${GREEN}    family: \"FiraCode Nerd Font Mono\"${NC}"
    echo -e "  ${GREEN}    style: Regular${NC}"
    echo ""

    echo -e "${BLUE}Kitty:${NC}"
    echo "  Füge in ~/.config/kitty/kitty.conf hinzu:"
    echo -e "  ${GREEN}font_family FiraCode Nerd Font Mono${NC}"
    echo -e "  ${GREEN}bold_font auto${NC}"
    echo -e "  ${GREEN}italic_font auto${NC}"
    echo -e "  ${GREEN}bold_italic_font auto${NC}"
    echo ""

    echo -e "${YELLOW}Teste die Installation mit:${NC}"
    echo "  lsd -l"
    echo "  echo -e '\\ue5fb \\uf15b \\uf016'"
    echo ""
}

# ============================================================================
# Haupt-Programm
# ============================================================================

main() {
    clear
    print_header "Nerd Fonts Installer für Linux"
    echo ""
    echo "Installiert: ${FONTS[*]}"
    echo "Version: ${NERD_FONTS_VERSION}"
    echo ""

    # Prüfungen und Installation
    check_dependencies
    echo ""

    create_directories
    echo ""

    install_all_fonts
    echo ""

    update_font_cache
    echo ""

    cleanup
    echo ""

    show_installed_fonts
    echo ""

    show_terminal_config

    print_success "Installation abgeschlossen!"
}

# Skript ausführen
main
