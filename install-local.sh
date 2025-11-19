#!/bin/bash

# Helfer-Script zum Installieren von tar.gz Paketen nach ~/.local/

set -e  # Bei Fehler abbrechen

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Funktion für Fehler
error() {
    echo -e "${RED}Fehler: $1${NC}" >&2
    exit 1
}

# Funktion für Info
info() {
    echo -e "${GREEN}➜${NC} $1"
}

# Funktion für Warnung
warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Hilfe anzeigen
show_help() {
    cat << EOF
Verwendung: $(basename "$0") [OPTIONEN] DATEI.tar.gz [PROGRAMMNAME]

Entpackt und installiert tar.gz Pakete nach ~/.local/

Optionen:
    -h, --help          Diese Hilfe anzeigen
    -f, --force         Überschreibe existierende Installation
    -s, --system        Installation nach /opt (benötigt sudo)

Argumente:
    DATEI.tar.gz        Die zu installierende tar.gz Datei
    PROGRAMMNAME        Optional: Name für die Installation (Standard: aus Dateinamen)

Beispiele:
    $(basename "$0") neovim-0.9.0-linux64.tar.gz
    $(basename "$0") neovim-0.9.0-linux64.tar.gz nvim
    $(basename "$0") -s neovim-0.9.0-linux64.tar.gz  # Systemweit
EOF
}

# Optionen parsen
FORCE=false
SYSTEM=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        -s|--system)
            SYSTEM=true
            shift
            ;;
        -*)
            error "Unbekannte Option: $1"
            ;;
        *)
            break
            ;;
    esac
done

# Argumente prüfen
if [ $# -lt 1 ]; then
    error "Keine tar.gz Datei angegeben. Verwende -h für Hilfe."
fi

ARCHIVE="$1"
CUSTOM_NAME="${2:-}"

# Prüfe ob Datei existiert
if [ ! -f "$ARCHIVE" ]; then
    error "Datei nicht gefunden: $ARCHIVE"
fi

# Prüfe ob es eine tar.gz Datei ist
if [[ ! "$ARCHIVE" =~ \.(tar\.gz|tgz)$ ]]; then
    error "Datei muss .tar.gz oder .tgz Format haben"
fi

# Programmname bestimmen
if [ -n "$CUSTOM_NAME" ]; then
    PROG_NAME="$CUSTOM_NAME"
else
    # Extrahiere Namen aus Dateiname (entferne .tar.gz und Versionsnummern)
    PROG_NAME=$(basename "$ARCHIVE" .tar.gz | sed 's/-linux.*//' | sed 's/-[0-9].*//')
fi

info "Installiere: $PROG_NAME"

# Zielverzeichnisse festlegen
if [ "$SYSTEM" = true ]; then
    if [ "$EUID" -ne 0 ]; then
        error "Systemweite Installation benötigt sudo/root Rechte"
    fi
    INSTALL_BASE="/opt"
    BIN_DIR="/usr/local/bin"
else
    INSTALL_BASE="$HOME/.local/share"
    BIN_DIR="$HOME/.local/bin"
fi

INSTALL_DIR="$INSTALL_BASE/$PROG_NAME"

# Prüfe ob bereits installiert
if [ -d "$INSTALL_DIR" ]; then
    if [ "$FORCE" = false ]; then
        error "Installation existiert bereits: $INSTALL_DIR (verwende -f zum Überschreiben)"
    fi
    warn "Überschreibe existierende Installation"
    rm -rf "$INSTALL_DIR"
fi

# Temporäres Verzeichnis erstellen
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

info "Entpacke Archiv..."
tar -xzf "$ARCHIVE" -C "$TEMP_DIR"

# Finde das extrahierte Verzeichnis
EXTRACTED_DIR=$(find "$TEMP_DIR" -mindepth 1 -maxdepth 1 -type d | head -n1)

if [ -z "$EXTRACTED_DIR" ]; then
    # Falls direkt Dateien entpackt wurden
    EXTRACTED_DIR="$TEMP_DIR"
fi

# Prüfe ob bin/ Verzeichnis existiert
if [ ! -d "$EXTRACTED_DIR/bin" ]; then
    warn "Kein bin/ Verzeichnis gefunden. Installiere trotzdem..."
fi

# Erstelle Zielverzeichnisse
info "Erstelle Verzeichnisse..."
mkdir -p "$INSTALL_BASE"
mkdir -p "$BIN_DIR"

# Verschiebe Dateien
info "Installiere nach $INSTALL_DIR..."
mv "$EXTRACTED_DIR" "$INSTALL_DIR"

# Erstelle Symlinks für alle Binaries
if [ -d "$INSTALL_DIR/bin" ]; then
    info "Erstelle Symlinks..."
    for binary in "$INSTALL_DIR/bin"/*; do
        if [ -f "$binary" ] && [ -x "$binary" ]; then
            binary_name=$(basename "$binary")
            link_path="$BIN_DIR/$binary_name"

            if [ -L "$link_path" ] || [ -f "$link_path" ]; then
                if [ "$FORCE" = false ]; then
                    warn "Überspringe $binary_name (existiert bereits)"
                    continue
                fi
                rm -f "$link_path"
            fi

            ln -sf "$binary" "$link_path"
            info "  ✓ $binary_name -> $link_path"
        fi
    done
fi

# Prüfe PATH
if [ "$SYSTEM" = false ]; then
    if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
        warn "$BIN_DIR ist nicht im PATH!"
        echo ""
        echo "Füge folgendes zu deiner ~/.bashrc oder ~/.zshrc hinzu:"
        echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
    fi
fi

echo ""
info "Installation abgeschlossen! ✓"

# Zeige installierte Binaries
if [ -d "$INSTALL_DIR/bin" ]; then
    echo ""
    echo "Installierte Programme:"
    for binary in "$INSTALL_DIR/bin"/*; do
        if [ -f "$binary" ] && [ -x "$binary" ]; then
            echo "  • $(basename "$binary")"
        fi
    done
fi
