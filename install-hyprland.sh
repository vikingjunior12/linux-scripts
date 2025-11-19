#!/bin/bash
#
# ============================================
# Hyprland Installation Skript
# ============================================
# Installiert Hyprland, Waybar, Walker und
# alle notwendigen Komponenten
# ============================================

set -euo pipefail

# ============================================
# FARBEN FÜR OUTPUT
# ============================================
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# ============================================
# HILFSFUNKTIONEN FÜR AUSGABEN
# ============================================
print_header() {
    echo ""
    echo -e "${BOLD}${CYAN}============================================${NC}"
    echo -e "${BOLD}${CYAN}$1${NC}"
    echo -e "${BOLD}${CYAN}============================================${NC}"
}

print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[ℹ]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Funktion für Ja/Nein Fragen
ask_yes_no() {
    local question="$1"
    local response
    while true; do
        read -rp "$(echo -e "${BLUE}[?]${NC} $question [y/N]: ")" response
        case "$response" in
            [Yy]|[Yy][Ee][Ss])
                return 0
                ;;
            [Nn]|[Nn][Oo]|"")
                return 1
                ;;
            *)
                print_warning "Bitte antworte mit 'y' (ja) oder 'n' (nein)"
                ;;
        esac
    done
}

# ============================================
# INITIALISIERUNG
# ============================================
print_header "HYPRLAND INSTALLATION"

# Prüfen ob als Root ausgeführt
if [ "$EUID" -eq 0 ]; then
    print_error "Bitte nicht als Root ausführen!"
    exit 1
fi

# Funktion um benötigte Kommandos zu prüfen
require_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        print_error "Benötigtes Kommando '$1' wurde nicht gefunden. Bitte installiere es und starte das Skript erneut."
        exit 1
    fi
}

# Prüfe ob alle benötigten Tools vorhanden sind
print_info "Prüfe benötigte Kommandos..."
require_command sudo
require_command pacman
require_command yay
require_command git
print_status "Alle benötigten Kommandos sind verfügbar"

# ============================================
# SYSTEM AKTUALISIEREN
# ============================================
print_header "SYSTEM AKTUALISIEREN"
print_info "System wird aktualisiert..."
sudo pacman -Syu --noconfirm
print_status "System erfolgreich aktualisiert"

# ============================================
# HYPRLAND KERN-KOMPONENTEN
# ============================================
print_header "HYPRLAND KERN-KOMPONENTEN"
print_info "Installiere Hyprland, Waybar und Walker..."
sudo pacman -S --needed --noconfirm hyprland waybar hyprpaper
yay -S --needed --noconfirm walker
print_status "Hyprland Kern-Komponenten installiert"

# ============================================
# ENERGIEVERWALTUNG & BILDSCHIRMSPERRE
# ============================================
print_header "ENERGIEVERWALTUNG & BILDSCHIRMSPERRE"
print_info "Installiere hyprlock, hypridle und Portal-Komponenten..."
sudo pacman -S --needed --noconfirm hyprlock hypridle swayidle xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
print_status "Energieverwaltungs-Tools installiert"

# ============================================
# AUDIO-STACK (PIPEWIRE)
# ============================================
print_header "AUDIO-STACK (PIPEWIRE)"
print_info "Installiere PipeWire und zugehörige Komponenten..."
sudo pacman -S --needed --noconfirm pipewire pipewire-audio pipewire-pulse pipewire-alsa pipewire-jack wireplumber rtkit gst-plugin-pipewire brightnessctl
print_status "PipeWire Audio-Stack installiert"

# ============================================
# SCHRIFTARTEN (NERD FONTS)
# ============================================
print_header "SCHRIFTARTEN (NERD FONTS)"
print_info "Installiere Nerd Fonts für Icons und Symbole..."
sudo pacman -S --needed --noconfirm ttf-jetbrains-mono-nerd ttf-nerd-fonts-symbols-mono ttf-font-awesome
print_status "Nerd Fonts aus pacman installiert"

print_info "Installiere CaskaydiaMono Nerd Font..."
yay -S --needed --noconfirm nerd-fonts-cascadia-code
sudo pacman -S --needed --noconfirm ttf-cascadia-code
print_status "CaskaydiaMono Nerd Font installiert"

# ============================================
# HYPRIDLE KONFIGURATION
# ============================================
print_header "HYPRIDLE KONFIGURATION"

HYPR_CONFIG_DIR="$HOME/.config/hypr"
mkdir -p "$HYPR_CONFIG_DIR"

# Prüfe ob hypridle.conf bereits existiert
if [ -f "$HYPR_CONFIG_DIR/hypridle.conf" ]; then
    print_warning "Hypridle-Konfiguration existiert bereits"
    print_info "Überspringe Erstellung der hypridle.conf"
else
    print_info "Erstelle Standard-Konfiguration für hypridle..."

    # Erstelle hypridle.conf mit Standard-Einstellungen
    cat <<'EOF' > "$HYPR_CONFIG_DIR/hypridle.conf"
general {
    lock_cmd = hyprlock
    before_sleep_cmd = loginctl lock-session
    after_sleep_cmd = hyprctl dispatch dpms on
}

# Nach 5 Minuten Inaktivität: Bildschirm sperren
listener {
    timeout = 300
    on-timeout = hyprlock
}

# Nach 10 Minuten Inaktivität: Display ausschalten
listener {
    timeout = 600
    on-timeout = hyprctl dispatch dpms off
    on-resume = hyprctl dispatch dpms on
}

# Nach 30 Minuten Inaktivität: System in Suspend
listener {
    timeout = 1800
    on-timeout = systemctl suspend
}
EOF
    print_status "Hypridle-Konfiguration erstellt: $HYPR_CONFIG_DIR/hypridle.conf"
fi

# ============================================
# WAYBAR KONFIGURATION (OPTIONAL)
# ============================================
print_header "WAYBAR KONFIGURATION"

# Frage den User ob er die Waybar-Config von GitHub herunterladen möchte
echo ""
print_info "Es gibt eine fertige Waybar-Konfiguration auf GitHub:"
print_info "Repository: https://github.com/Prateek7071/dotfiles.git"
echo ""

if ask_yes_no "Möchtest du die Waybar-Konfiguration von diesem Repository installieren?"; then
    # User hat JA gewählt - Waybar-Config herunterladen
    print_info "Starte Download der Waybar-Konfiguration..."

    # Erstelle temporäres Verzeichnis für den Download
    TEMP_DIR=$(mktemp -d)
    trap 'rm -rf "$TEMP_DIR"' EXIT

    # Clone das Repository
    print_info "Lade Repository herunter..."
    if git clone --depth 1 https://github.com/Prateek7071/dotfiles.git "$TEMP_DIR/dotfiles" 2>/dev/null; then
        print_status "Repository erfolgreich heruntergeladen"

        # Pfade definieren
        SOURCE_WAYBAR_DIR="$TEMP_DIR/dotfiles/.config/waybar"
        TARGET_WAYBAR_DIR="$HOME/.config/waybar"

        # Prüfe ob waybar-Ordner im Repository existiert
        if [ ! -d "$SOURCE_WAYBAR_DIR" ]; then
            print_error "Waybar-Ordner wurde im Repository nicht gefunden (.config/waybar)"
            print_warning "Waybar-Installation wird übersprungen"
        else
            # Erstelle .config Verzeichnis falls nicht vorhanden
            mkdir -p "$HOME/.config"

            # Prüfe ob bereits eine Waybar-Config existiert
            if [ -d "$TARGET_WAYBAR_DIR" ]; then
                print_warning "Waybar-Konfiguration existiert bereits: $TARGET_WAYBAR_DIR"

                if ask_yes_no "Möchtest du die bestehende Konfiguration überschreiben?"; then
                    # Backup der alten Config erstellen
                    BACKUP_DIR="$TARGET_WAYBAR_DIR.backup.$(date +%Y%m%d_%H%M%S)"
                    print_info "Erstelle Backup der alten Konfiguration: $BACKUP_DIR"
                    mv "$TARGET_WAYBAR_DIR" "$BACKUP_DIR"

                    # Kopiere neue Config
                    cp -rf "$SOURCE_WAYBAR_DIR" "$TARGET_WAYBAR_DIR"
                    print_status "Waybar-Konfiguration wurde aktualisiert"
                    print_info "Backup der alten Config: $BACKUP_DIR"
                else
                    print_warning "Waybar-Konfiguration wurde NICHT überschrieben"
                    print_info "Deine bestehende Konfiguration bleibt erhalten"
                fi
            else
                # Keine existierende Config - einfach kopieren
                cp -rf "$SOURCE_WAYBAR_DIR" "$TARGET_WAYBAR_DIR"
                print_status "Waybar-Konfiguration wurde installiert: $TARGET_WAYBAR_DIR"
            fi
        fi

        # Temporäres Verzeichnis wird durch trap automatisch gelöscht
    else
        print_error "Fehler beim Herunterladen des Repositories"
        print_warning "Waybar-Installation wird übersprungen"
    fi
else
    # User hat NEIN gewählt - Waybar-Config überspringen
    print_info "Waybar-Konfiguration wird übersprungen"
    print_info "Du kannst später manuell eine Config erstellen oder das Skript erneut ausführen"
fi

# ============================================
# INSTALLATION ABGESCHLOSSEN
# ============================================
print_header "INSTALLATION ABGESCHLOSSEN"
echo ""
print_status "Hyprland wurde erfolgreich installiert!"
echo ""
echo -e "${BOLD}Nächste Schritte:${NC}"
echo "  1. Starte Hyprland mit dem Kommando: ${BOLD}Hyprland${NC}"
echo "  2. Oder logge dich aus und wähle Hyprland im Display Manager"
echo ""
echo -e "${BOLD}Installierte Komponenten:${NC}"
echo "  • Hyprland (Wayland Compositor)"
echo "  • Waybar (Status-Bar)"
echo "  • Walker (Application Launcher)"
echo "  • Hyprlock & Hypridle (Bildschirmsperre & Energieverwaltung)"
echo "  • PipeWire (Audio-Stack)"
echo "  • Nerd Fonts (Icons & Symbole)"
echo ""
print_warning "Tipp: Bei Problemen mit Icons, stelle sicher dass eine Nerd Font in Waybar konfiguriert ist"
echo ""
