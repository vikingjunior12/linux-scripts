#!/bin/bash

# Farben für die Ausgabe
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== IP Scanner ===${NC}"
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

OUTPUT_FILE="scan_results_$(date +%Y%m%d_%H%M%S).txt"

echo ""
echo -e "${BLUE}Scanne: $subnets${NC}"
echo "Ausgabe wird gespeichert in: $OUTPUT_FILE"
echo ""

nmap -sn -n $subnets -oG - #| awk '/Up$/{print $2}' | tee "$OUTPUT_FILE"

echo ""
echo -e "${GREEN}Scan abgeschlossen!${NC}"
echo "Ergebnisse in: $OUTPUT_FILE"
