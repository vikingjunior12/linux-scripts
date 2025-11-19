#!/bin/bash

# Linux Surface Kernel Installation Script for Arch Linux
# Based on: https://github.com/linux-surface/linux-surface/wiki/Installation-and-Setup

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_root() {
    if [ "$EUID" -eq 0 ]; then
        print_error "Bitte führe dieses Script NICHT als root aus. sudo wird intern verwendet."
        exit 1
    fi
}

check_arch() {
    if [ ! -f /etc/arch-release ]; then
        print_error "Dieses Script ist nur für Arch Linux gedacht."
        exit 1
    fi
}

# Main installation steps
import_keys() {
    print_info "Importiere Linux Surface Signing Keys..."
    curl -s https://raw.githubusercontent.com/linux-surface/linux-surface/master/pkg/keys/surface.asc \
        | sudo pacman-key --add -
    print_success "Keys importiert"
}

verify_fingerprint() {
    print_info "Überprüfe Key-Fingerprint..."
    echo -e "\n${YELLOW}Bitte verifiziere den folgenden Fingerprint:${NC}"
    echo -e "${YELLOW}Erwartet: 56C4 64BA AC42 1453${NC}\n"
    sudo pacman-key --finger 56C464BAAC421453

    echo -e "\n"
    read -p "Stimmt der Fingerprint überein? (j/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Jj]$ ]]; then
        print_error "Fingerprint-Überprüfung fehlgeschlagen. Abbruch."
        exit 1
    fi
    print_success "Fingerprint verifiziert"
}

sign_key() {
    print_info "Signiere den importierten Key lokal..."
    sudo pacman-key --lsign-key 56C464BAAC421453
    print_success "Key signiert"
}

add_repository() {
    print_info "Füge Linux Surface Repository zu /etc/pacman.conf hinzu..."

    # Check if repository already exists
    if grep -q "\[linux-surface\]" /etc/pacman.conf; then
        print_warning "Repository bereits in /etc/pacman.conf vorhanden"
        return
    fi

    # Backup pacman.conf
    sudo cp /etc/pacman.conf /etc/pacman.conf.backup
    print_info "Backup erstellt: /etc/pacman.conf.backup"

    # Add repository
    echo "" | sudo tee -a /etc/pacman.conf > /dev/null
    echo "[linux-surface]" | sudo tee -a /etc/pacman.conf > /dev/null
    echo "Server = https://pkg.surfacelinux.com/arch/" | sudo tee -a /etc/pacman.conf > /dev/null

    print_success "Repository hinzugefügt"
}

refresh_and_install() {
    print_info "Aktualisiere Repository-Metadaten..."
    sudo pacman -Syu

    print_info "Installiere Linux Surface Kernel und Dependencies..."
    sudo pacman -S --needed linux-surface linux-surface-headers iptsd

    print_success "Kernel und Dependencies installiert"
}

install_firmware() {
    echo -e "\n${YELLOW}Firmware-Pakete:${NC}"
    echo "1) Surface Pro 4, 5, 6 / Book 1, 2 / Laptop 1, 2 benötigen Marvell WiFi Firmware"
    echo "2) Intel Geräte benötigen Intel Camera Firmware"
    echo ""

    read -p "Marvell WiFi Firmware installieren? (j/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Jj]$ ]]; then
        print_info "Installiere Marvell WiFi Firmware..."
        sudo pacman -S --needed linux-firmware-marvell
        print_success "Marvell Firmware installiert"
    fi

    read -p "Intel Camera Firmware installieren? (j/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Jj]$ ]]; then
        print_info "Installiere Intel Camera Firmware..."
        sudo pacman -S --needed linux-firmware-intel
        print_success "Intel Firmware installiert"
    fi
}

setup_secureboot() {
    echo -e "\n${YELLOW}Secure Boot Setup:${NC}"
    print_warning "WICHTIG: Dies funktioniert nur, wenn Secure Boot bereits mit SHIM für Arch eingerichtet ist!"
    print_warning "Installiere dies NICHT, wenn du noch kein funktionierendes Secure Boot Setup hast."
    echo ""

    read -p "Secure Boot MOK für linux-surface installieren? (j/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Jj]$ ]]; then
        print_info "Installiere Secure Boot MOK..."
        sudo pacman -S --needed linux-surface-secureboot-mok
        echo -e "\n${GREEN}Nach dem Reboot:${NC}"
        echo "1) Ein blaues Menu erscheint"
        echo "2) Wähle 'Enroll MOK'"
        echo "3) Bestätige mit OK/Yes"
        echo "4) Passwort: ${YELLOW}surface${NC}"
        print_success "Secure Boot MOK installiert"
    fi
}

update_grub() {
    print_info "Überprüfe Bootloader..."

    if [ -f /boot/grub/grub.cfg ]; then
        print_info "GRUB erkannt. Aktualisiere Konfiguration..."
        sudo grub-mkconfig -o /boot/grub/grub.cfg
        print_success "GRUB-Konfiguration aktualisiert"
    else
        print_warning "GRUB nicht gefunden. Bitte aktualisiere deinen Bootloader manuell!"
    fi
}

final_instructions() {
    echo -e "\n${GREEN}========================================${NC}"
    echo -e "${GREEN}Installation abgeschlossen!${NC}"
    echo -e "${GREEN}========================================${NC}\n"

    echo -e "${YELLOW}Nächste Schritte:${NC}"
    echo "1) Reboote dein System: sudo reboot"
    echo "2) Nach dem Reboot, überprüfe den Kernel mit: uname -a"
    echo "3) Die Ausgabe sollte 'surface' enthalten"
    echo ""
    echo -e "${YELLOW}Wenn du NICHT den Surface-Kernel verwendest:${NC}"
    echo "- Überprüfe deine Bootloader-Konfiguration"
    echo "- Bei GRUB wähle den 'linux-surface' Eintrag beim Booten"
    echo ""

    read -p "Jetzt neu starten? (j/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Jj]$ ]]; then
        print_info "System wird neu gestartet..."
        sudo reboot
    fi
}

# Main execution
main() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}Linux Surface Kernel Installer${NC}"
    echo -e "${BLUE}für Arch Linux${NC}"
    echo -e "${BLUE}========================================${NC}\n"

    check_root
    check_arch

    import_keys
    verify_fingerprint
    sign_key
    add_repository
    refresh_and_install
    install_firmware
    setup_secureboot
    update_grub
    final_instructions
}

# Trap errors
trap 'print_error "Ein Fehler ist aufgetreten. Installation abgebrochen."; exit 1' ERR

# Run main function
main
