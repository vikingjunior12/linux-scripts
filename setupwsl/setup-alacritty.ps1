# ============================================================================
# Alacritty Setup Script für Windows
# ============================================================================
# Dieses Script richtet Alacritty mit WSL und Nerd Fonts ein
# Erstellt: 2025-11-14
# ============================================================================

$ErrorActionPreference = "Stop"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  Alacritty Setup für Windows mit WSL" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# Config-Verzeichnis erstellen
Write-Host "[1/2] " -NoNewline -ForegroundColor Blue
Write-Host "Erstelle Config-Verzeichnis..."

$configPath = "$env:APPDATA\alacritty"
if (!(Test-Path $configPath)) {
    New-Item -ItemType Directory -Path $configPath -Force | Out-Null
    Write-Host "✓ Verzeichnis erstellt: $configPath" -ForegroundColor Green
} else {
    Write-Host "✓ Verzeichnis existiert bereits: $configPath" -ForegroundColor Yellow
}
Write-Host ""

# Config-Datei erstellen
Write-Host "[2/2] " -NoNewline -ForegroundColor Blue
Write-Host "Erstelle alacritty.toml..."

$configContent = @'
# ============================================================================
# Alacritty Configuration für Windows
# ============================================================================
# Erstellt für Jonas mit WSL und Nerd Fonts Support
# Datum: 2025-11-14
# ============================================================================

# Import zusätzlicher Config-Dateien (optional)
# import = [
#     "~/.config/alacritty/themes/tokyo-night.toml"
# ]

[env]
TERM = "xterm-256color"

# ============================================================================
# Shell - WSL direkt starten
# ============================================================================
[shell]
program = "wsl.exe"
args = ["~"]

# Für eine spezifische WSL-Distribution:
# program = "wsl.exe"
# args = ["-d", "Ubuntu", "~"]

# ============================================================================
# Fenster-Einstellungen
# ============================================================================
[window]
# Dimensionen (in Spalten x Zeilen)
# dimensions = { columns = 120, lines = 30 }

# Padding (Innenabstand)
padding = { x = 8, y = 8 }

# Dynamisches Padding für gleichmäßige Abstände
dynamic_padding = true

# Dekorationen: "Full", "None", "Transparent", "Buttonless"
decorations = "Full"

# Opacity (Transparenz): 0.0 (transparent) bis 1.0 (opak)
opacity = 0.95

# Startup Mode: "Windowed", "Maximized", "Fullscreen"
startup_mode = "Windowed"

# Titel des Fensters
title = "Alacritty"

# Dynamischer Titel (zeigt den laufenden Befehl)
dynamic_title = true

# ============================================================================
# Scrolling
# ============================================================================
[scrolling]
# Anzahl der Zeilen im Scrollback Buffer
history = 10000

# Anzahl der Zeilen beim Scrollen
multiplier = 3

# ============================================================================
# Font-Konfiguration
# ============================================================================
[font]
# Schriftgröße
size = 11.0

# Normal (Regular) Font
normal = { family = "MesloLGS Nerd Font Mono", style = "Regular" }

# Bold Font
bold = { family = "MesloLGS Nerd Font Mono", style = "Bold" }

# Italic Font
italic = { family = "MesloLGS Nerd Font Mono", style = "Italic" }

# Bold Italic Font
bold_italic = { family = "MesloLGS Nerd Font Mono", style = "Bold Italic" }

# Offset für bessere Darstellung
offset = { x = 0, y = 0 }

# Glyph Offset (für Icon-Fonts)
glyph_offset = { x = 0, y = 0 }

# Alternative Nerd Fonts (zum Testen):
# Ersetze "FiraCode Nerd Font" mit einer dieser Optionen:
#   - "Hack Nerd Font"
#   - "JetBrainsMono Nerd Font"
#   - "MesloLGS NF"
#   - "CascadiaCode Nerd Font"

# ============================================================================
# Farben - Tokyo Night Theme
# ============================================================================
[colors.primary]
background = "#1a1b26"
foreground = "#c0caf5"

[colors.normal]
black   = "#15161e"
red     = "#f7768e"
green   = "#9ece6a"
yellow  = "#e0af68"
blue    = "#7aa2f7"
magenta = "#bb9af7"
cyan    = "#7dcfff"
white   = "#a9b1d6"

[colors.bright]
black   = "#414868"
red     = "#f7768e"
green   = "#9ece6a"
yellow  = "#e0af68"
blue    = "#7aa2f7"
magenta = "#bb9af7"
cyan    = "#7dcfff"
white   = "#c0caf5"

# ============================================================================
# Cursor-Einstellungen
# ============================================================================
[cursor]
# Cursor-Style: "Block", "Underline", "Beam"
style = { shape = "Block", blinking = "On" }

# Blink-Intervall in Millisekunden
blink_interval = 750

# Blink-Timeout in Sekunden (0 = nie)
blink_timeout = 0

# Unfocused Hollow: false (normal), true (hohler Cursor wenn unfokussiert)
unfocused_hollow = true

# ============================================================================
# Auswahl
# ============================================================================
[selection]
# Speichert Auswahl in Clipboard
save_to_clipboard = true

# ============================================================================
# Bell (Piepston)
# ============================================================================
[bell]
# Animation: "Ease", "EaseOut", "EaseOutSine", "EaseOutQuad", "EaseOutCubic",
#            "EaseOutQuart", "EaseOutQuint", "EaseOutExpo", "EaseOutCirc", "Linear"
animation = "EaseOutExpo"
duration = 0
color = "#ffffff"

# ============================================================================
# Tastenkombinationen
# ============================================================================
[[keyboard.bindings]]
key = "V"
mods = "Control|Shift"
action = "Paste"

[[keyboard.bindings]]
key = "C"
mods = "Control|Shift"
action = "Copy"

[[keyboard.bindings]]
key = "Insert"
mods = "Shift"
action = "PasteSelection"

# Scrolling
[[keyboard.bindings]]
key = "PageUp"
mods = "Shift"
action = "ScrollPageUp"

[[keyboard.bindings]]
key = "PageDown"
mods = "Shift"
action = "ScrollPageDown"

[[keyboard.bindings]]
key = "Home"
mods = "Shift"
action = "ScrollToTop"

[[keyboard.bindings]]
key = "End"
mods = "Shift"
action = "ScrollToBottom"

# Font size
[[keyboard.bindings]]
key = "Plus"
mods = "Control"
action = "IncreaseFontSize"

[[keyboard.bindings]]
key = "Minus"
mods = "Control"
action = "DecreaseFontSize"

[[keyboard.bindings]]
key = "Key0"
mods = "Control"
action = "ResetFontSize"

# New window
[[keyboard.bindings]]
key = "Return"
mods = "Control|Shift"
action = "SpawnNewInstance"

# ============================================================================
# Weitere Themes zum Ausprobieren
# ============================================================================
#
# Gruvbox Dark:
# [colors.primary]
# background = "#282828"
# foreground = "#ebdbb2"
#
# [colors.normal]
# black   = "#282828"
# red     = "#cc241d"
# green   = "#98971a"
# yellow  = "#d79921"
# blue    = "#458588"
# magenta = "#b16286"
# cyan    = "#689d6a"
# white   = "#a89984"
#
# [colors.bright]
# black   = "#928374"
# red     = "#fb4934"
# green   = "#b8bb26"
# yellow  = "#fabd2f"
# blue    = "#83a598"
# magenta = "#d3869b"
# cyan    = "#8ec07c"
# white   = "#ebdbb2"
#
# Nord Theme:
# [colors.primary]
# background = "#2e3440"
# foreground = "#d8dee9"
#
# [colors.normal]
# black   = "#3b4252"
# red     = "#bf616a"
# green   = "#a3be8c"
# yellow  = "#ebcb8b"
# blue    = "#81a1c1"
# magenta = "#b48ead"
# cyan    = "#88c0d0"
# white   = "#e5e9f0"
#
# [colors.bright]
# black   = "#4c566a"
# red     = "#bf616a"
# green   = "#a3be8c"
# yellow  = "#ebcb8b"
# blue    = "#81a1c1"
# magenta = "#b48ead"
# cyan    = "#8ec0d0"
# white   = "#eceff4"
'@

$configFile = Join-Path $configPath "alacritty.toml"
Set-Content -Path $configFile -Value $configContent -Encoding UTF8

Write-Host "✓ Config-Datei erstellt: $configFile" -ForegroundColor Green
Write-Host ""

# Zusammenfassung
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  Setup abgeschlossen!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Konfiguration Details:" -ForegroundColor Yellow
Write-Host "  Font:        MesloLGS Nerd Font Mono (Größe 11)"
Write-Host "  Theme:       Tokyo Night"
Write-Host "  Shell:       WSL (Linux)"
Write-Host "  Transparenz: 95%"
Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  Nützliche Shortcuts:" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  Ctrl+Shift+C/V   - Copy/Paste"
Write-Host "  Ctrl +/-/0       - Schriftgröße anpassen"
Write-Host "  Shift+PageUp/Dn  - Scrollen"
Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  Nächste Schritte:" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "1. Installiere MesloLGS Nerd Font Mono von:"
Write-Host "   https://www.nerdfonts.com/font-downloads" -ForegroundColor Blue
Write-Host ""
Write-Host "2. Oder mit winget:" -ForegroundColor Yellow
Write-Host "   winget install Gyan.FFmpeg" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Starte Alacritty neu, um die Konfiguration zu laden"
Write-Host ""
Write-Host "Hinweis: " -NoNewline -ForegroundColor Yellow
Write-Host "Wenn du eine spezifische WSL-Distribution verwenden möchtest,"
Write-Host "         bearbeite die Config und ersetze:" -ForegroundColor Gray
Write-Host "         program = " -NoNewline -ForegroundColor Gray
Write-Host '"wsl.exe"' -ForegroundColor White
Write-Host "         args = [" -NoNewline -ForegroundColor Gray
Write-Host '"-d", "Ubuntu", "~"' -NoNewline -ForegroundColor White
Write-Host "]" -ForegroundColor Gray
Write-Host ""
