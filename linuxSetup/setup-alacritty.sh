#!/bin/bash
# ============================================================================
# Alacritty Setup Script
# ============================================================================
# Dieses Script richtet Alacritty mit Nerd Fonts ein
# Erstellt: 2025-11-07
# ============================================================================

set -e # Bei Fehler abbrechen

echo "=================================================="
echo "  Alacritty Setup mit Nerd Fonts"
echo "=================================================="
echo ""

# Farben für Output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Config-Verzeichnis erstellen
echo -e "${BLUE}[1/3]${NC} Erstelle Config-Verzeichnis..."
mkdir -p ~/.config/alacritty
echo -e "${GREEN}✓${NC} Verzeichnis erstellt: ~/.config/alacritty"
echo ""

# Config-Datei erstellen
echo -e "${BLUE}[2/3]${NC} Erstelle alacritty.yml..."
cat >~/.config/alacritty/alacritty.yml <<'EOF'
# ============================================================================
# Alacritty Configuration
# ============================================================================
# Erstellt für Jonas mit Nerd Fonts Support
# Datum: 2025-11-07
# ============================================================================

# Fenster-Einstellungen
window:
  # Padding (Innenabstand)
  padding:
    x: 8
    y: 8

  # Dynamisches Padding für gleichmäßige Abstände
  dynamic_padding: true

  # Dekorationen: full, none, transparent, buttonless
  decorations: full

  # Titel des Fensters
  title: Alacritty

  # Opacity (Transparenz): 0.0 (transparent) bis 1.0 (opak)
  opacity: 0.95

  # Klasse für X11
  class:
    instance: Alacritty
    general: Alacritty

# Scrolling
scrolling:
  # Anzahl der Zeilen im Scrollback Buffer
  history: 10000

  # Anzahl der Zeilen beim Scrollen
  multiplier: 3

# Font-Konfiguration
font:
  # Normal (Regular) Font
  normal:
    family: "FiraCode Nerd Font"
    style: Regular

  # Bold Font
  bold:
    family: "FiraCode Nerd Font"
    style: Bold

  # Italic Font
  italic:
    family: "FiraCode Nerd Font"
    style: Italic

  # Bold Italic Font
  bold_italic:
    family: "FiraCode Nerd Font"
    style: Bold Italic

  # Schriftgröße
  size: 12.0

  # Offset für bessere Darstellung
  offset:
    x: 0
    y: 0

  # Glyph Offset (für Icon-Fonts)
  glyph_offset:
    x: 0
    y: 0

# Alternative Nerd Fonts (zum Testen):
# Ersetze "FiraCode Nerd Font Mono" mit einer dieser Optionen:
#   - "Hack Nerd Font Mono"
#   - "JetBrainsMono Nerd Font Mono"
#   - "MesloLGS NF"

# Farben - Tokyo Night Theme
colors:
  # Standard-Farben
  primary:
    background: '#1a1b26'
    foreground: '#c0caf5'

  # Normal colors
  normal:
    black:   '#15161e'
    red:     '#f7768e'
    green:   '#9ece6a'
    yellow:  '#e0af68'
    blue:    '#7aa2f7'
    magenta: '#bb9af7'
    cyan:    '#7dcfff'
    white:   '#a9b1d6'

  # Bright colors
  bright:
    black:   '#414868'
    red:     '#f7768e'
    green:   '#9ece6a'
    yellow:  '#e0af68'
    blue:    '#7aa2f7'
    magenta: '#bb9af7'
    cyan:    '#7dcfff'
    white:   '#c0caf5'

# Cursor-Einstellungen
cursor:
  # Cursor-Style: Block, Underline, Beam
  style:
    shape: Block
    blinking: On

  # Blink-Intervall in Millisekunden
  blink_interval: 750

  # Unfocused Hollow: false (normal), true (hohler Cursor wenn unfokussiert)
  unfocused_hollow: true

# Auswahl
selection:
  # Speichert Auswahl in Clipboard
  save_to_clipboard: true

# Bell (Piepston)
bell:
  # Animation: Ease, EaseOut, EaseOutSine, EaseOutQuad, EaseOutCubic, EaseOutQuart, EaseOutQuint, EaseOutExpo, EaseOutCirc, Linear
  animation: EaseOutExpo
  duration: 0

# Live Config Reload (lädt Änderungen automatisch)
live_config_reload: true

# Shell - ZSH
shell:
  program: /bin/zsh
  args:
    - --login

# Key bindings
key_bindings:
  # Copy/Paste
  - { key: V,         mods: Control|Shift, action: Paste            }
  - { key: C,         mods: Control|Shift, action: Copy             }
  - { key: Insert,    mods: Shift,         action: PasteSelection   }

  # Scrolling
  - { key: PageUp,    mods: Shift,         action: ScrollPageUp     }
  - { key: PageDown,  mods: Shift,         action: ScrollPageDown   }
  - { key: Home,      mods: Shift,         action: ScrollToTop      }
  - { key: End,       mods: Shift,         action: ScrollToBottom   }

  # Font size
  - { key: Plus,      mods: Control,       action: IncreaseFontSize }
  - { key: Minus,     mods: Control,       action: DecreaseFontSize }
  - { key: Key0,      mods: Control,       action: ResetFontSize    }

  # New window
  - { key: Return,    mods: Control|Shift, action: SpawnNewInstance }

# ============================================================================
# Weitere Themes zum Ausprobieren
# ============================================================================
#
# Gruvbox Dark:
# colors:
#   primary:
#     background: '#282828'
#     foreground: '#ebdbb2'
#   normal:
#     black:   '#282828'
#     red:     '#cc241d'
#     green:   '#98971a'
#     yellow:  '#d79921'
#     blue:    '#458588'
#     magenta: '#b16286'
#     cyan:    '#689d6a'
#     white:   '#a89984'
#   bright:
#     black:   '#928374'
#     red:     '#fb4934'
#     green:   '#b8bb26'
#     yellow:  '#fabd2f'
#     blue:    '#83a598'
#     magenta: '#d3869b'
#     cyan:    '#8ec07c'
#     white:   '#ebdbb2'
#
# Nord Theme:
# colors:
#   primary:
#     background: '#2e3440'
#     foreground: '#d8dee9'
#   normal:
#     black:   '#3b4252'
#     red:     '#bf616a'
#     green:   '#a3be8c'
#     yellow:  '#ebcb8b'
#     blue:    '#81a1c1'
#     magenta: '#b48ead'
#     cyan:    '#88c0d0'
#     white:   '#e5e9f0'
#   bright:
#     black:   '#4c566a'
#     red:     '#bf616a'
#     green:   '#a3be8c'
#     yellow:  '#ebcb8b'
#     blue:    '#81a1c1'
#     magenta: '#b48ead'
#     cyan:    '#8ecfd0'
#     white:   '#eceff4'
EOF

echo -e "${GREEN}✓${NC} Config-Datei erstellt: ~/.config/alacritty/alacritty.yml"
echo ""

# Zusammenfassung
echo -e "${BLUE}[3/3]${NC} Setup abgeschlossen!"
echo ""
echo -e "${GREEN}✓ Alacritty erfolgreich eingerichtet!${NC}"
echo ""
echo "=================================================="
echo "  Konfiguration Details:"
echo "=================================================="
echo -e "  ${YELLOW}Font:${NC}        FiraCode Nerd Font Mono (Größe 12)"
echo -e "  ${YELLOW}Theme:${NC}       Tokyo Night"
echo -e "  ${YELLOW}Shell:${NC}       zsh"
echo -e "  ${YELLOW}Transparenz:${NC} 95%"
echo ""
echo "=================================================="
echo "  Nützliche Shortcuts:"
echo "=================================================="
echo "  Ctrl+Shift+C/V   - Copy/Paste"
echo "  Ctrl +/-/0       - Schriftgröße anpassen"
echo "  Shift+PageUp/Dn  - Scrollen"
echo ""
echo "Starte Alacritty mit: ${GREEN}alacritty${NC}"
echo ""
