#!/bin/bash
set -e

SWAPFILE="/swapfile"
SWAP_SIZE_GB=8
SWAP_SIZE_MB=$((SWAP_SIZE_GB * 1024))
MIN_FREE_GB=20  # Mindestens 20GB sollten nach Swap-Erstellung frei bleiben

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# Root-Check
if [[ $EUID -ne 0 ]]; then
    error "Dieses Script muss mit sudo ausgeführt werden: sudo $0"
fi

echo "========================================="
echo "  Swap-Datei Erstellung (${SWAP_SIZE_GB}GB)"
echo "========================================="
echo

# Prüfe ob Swapfile bereits existiert
if [[ -f "$SWAPFILE" ]]; then
    warn "Swap-Datei $SWAPFILE existiert bereits!"
    swapon --show
    read -p "Möchtest du sie ersetzen? (j/N): " replace
    if [[ ! "$replace" =~ ^[jJyY]$ ]]; then
        info "Abgebrochen."
        exit 0
    fi
    info "Deaktiviere bestehende Swap-Datei..."
    swapoff "$SWAPFILE" 2>/dev/null || true
    rm -f "$SWAPFILE"
fi

# Prüfe verfügbaren Speicherplatz
FREE_KB=$(df / | tail -1 | awk '{print $4}')
FREE_GB=$((FREE_KB / 1024 / 1024))
NEEDED_GB=$((SWAP_SIZE_GB + MIN_FREE_GB))

info "Verfügbarer Speicherplatz: ${FREE_GB}GB"
info "Benötigt (Swap + Reserve): ${NEEDED_GB}GB"

if [[ $FREE_GB -lt $NEEDED_GB ]]; then
    error "Nicht genug Speicherplatz! Benötigt: ${NEEDED_GB}GB, Verfügbar: ${FREE_GB}GB"
fi

# Prüfe aktuellen Swap
info "Aktueller Swap-Status:"
swapon --show
echo
free -h | grep -i swap
echo

# Prüfe ob bereits genug Swap vorhanden
CURRENT_SWAP_MB=$(free -m | awk '/Swap:/ {print $2}')
if [[ $CURRENT_SWAP_MB -ge 8192 ]]; then
    warn "Du hast bereits ${CURRENT_SWAP_MB}MB Swap. Möglicherweise nicht nötig."
    read -p "Trotzdem fortfahren? (j/N): " cont
    if [[ ! "$cont" =~ ^[jJyY]$ ]]; then
        info "Abgebrochen."
        exit 0
    fi
fi

# RAM-Check - bei wenig RAM macht Swap Sinn
TOTAL_RAM_MB=$(free -m | awk '/Mem:/ {print $2}')
info "System RAM: ${TOTAL_RAM_MB}MB"

if [[ $TOTAL_RAM_MB -gt 16384 ]]; then
    warn "Du hast mehr als 16GB RAM - Swap ist eventuell weniger wichtig."
else
    info "Bei ${TOTAL_RAM_MB}MB RAM ist zusätzlicher Swap sinnvoll!"
fi

echo
read -p "Swap-Datei mit ${SWAP_SIZE_GB}GB erstellen? (j/N): " confirm
if [[ ! "$confirm" =~ ^[jJyY]$ ]]; then
    info "Abgebrochen."
    exit 0
fi

# Dateisystem erkennen
FS_TYPE=$(df -T / | tail -1 | awk '{print $2}')
info "Dateisystem: $FS_TYPE"

# Swap-Datei erstellen
echo
if [[ "$FS_TYPE" == "btrfs" ]]; then
    info "Btrfs erkannt - verwende spezielle Methode (COW deaktivieren)"
    info "Erstelle ${SWAP_SIZE_GB}GB Swap-Datei..."

    # Für Btrfs: Erst leere Datei, dann COW deaktivieren, dann füllen
    truncate -s 0 "$SWAPFILE"
    chattr +C "$SWAPFILE"
    fallocate -l "${SWAP_SIZE_GB}G" "$SWAPFILE"
else
    info "Erstelle ${SWAP_SIZE_GB}GB Swap-Datei... (kann etwas dauern)"
    dd if=/dev/zero of="$SWAPFILE" bs=1M count="$SWAP_SIZE_MB" status=progress
fi

info "Setze Berechtigungen..."
chmod 600 "$SWAPFILE"

info "Formatiere als Swap..."
mkswap "$SWAPFILE"

info "Aktiviere Swap..."
swapon "$SWAPFILE"

# Prüfe ob bereits in fstab
if grep -q "$SWAPFILE" /etc/fstab; then
    info "Eintrag in /etc/fstab bereits vorhanden."
else
    info "Füge Eintrag zu /etc/fstab hinzu..."
    echo "$SWAPFILE none swap defaults 0 0" >> /etc/fstab
fi

echo
echo "========================================="
info "Swap-Datei erfolgreich erstellt!"
echo "========================================="
echo
info "Neuer Swap-Status:"
swapon --show
echo
free -h
