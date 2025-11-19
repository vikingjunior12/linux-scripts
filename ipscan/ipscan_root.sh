#!/bin/bash

# Farben für die Ausgabe
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Prüfe ob Termux oder normale Linux-Distro
if [[ "$PREFIX" == *"com.termux"* ]] || [[ -d "/data/data/com.termux" ]]; then
    IS_TERMUX=true
    NMAP_PATH="/data/data/com.termux/files/usr/bin/nmap"
else
    IS_TERMUX=false
    NMAP_PATH="nmap"
fi

echo -e "${BLUE}=== IP Scanner (Root) ===${NC}"
echo ""
echo "Welche Subnetze möchtest du scannen?"
echo "Format: 192.168.1.0/24"
echo "Mehrere Subnetze mit Leerzeichen trennen"
echo "Eingabe beenden mit Enter:"
echo ""

read -e -p "> " subnets

if [ -z "$subnets" ]; then
    echo "Keine Subnetze angegeben. Abbruch."
    exit 1
fi

# Root-Check für OS-Detection
echo ""
echo -e "${YELLOW}OS-Detection mit -O benötigt root.${NC}"
read -e -p "Mit root und OS-Detection scannen? (j/n): " use_root

OUTPUT_FILE="scan_results_$(date +%Y%m%d_%H%M%S).txt"

echo ""
echo -e "${BLUE}Scanne: $subnets${NC}"
echo "Ausgabe wird gespeichert in: $OUTPUT_FILE"
echo ""

if [[ "$use_root" =~ ^[jJyY]$ ]]; then
    echo -e "${YELLOW}Führe Scan mit root aus...${NC}"
    if [ "$IS_TERMUX" = true ]; then
        # Termux: nutze su -c mit vollem Pfad
        su -c "$NMAP_PATH -sS -O -n $subnets" | tee "$OUTPUT_FILE"
    else
        # Normale Linux-Distro: nutze sudo
        sudo nmap -sS -O -n $subnets | tee "$OUTPUT_FILE"
    fi
else
    nmap -sn -n $subnets -oG - | awk '/Up$/{print $2}' | tee "$OUTPUT_FILE"
fi

echo ""
echo -e "${GREEN}Scan abgeschlossen!${NC}"
echo "Ergebnisse in: $OUTPUT_FILE"
