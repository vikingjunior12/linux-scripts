#!/bin/bash

# Skript zum Installieren des Linux Surface-Kernels auf Ubuntu
# Basierend auf: https://github.com/linux-surface/linux-surface/wiki/Installation-and-Setup

# Prüfen, ob das Skript mit Root-Rechten ausgeführt wird
if [ "$EUID" -ne 0 ]; then
  echo "Dieses Skript muss mit Root-Rechten ausgeführt werden. Bitte mit sudo ausführen."
  exit 1
fi

echo "Importiere die Schlüssel für die Linux Surface-Pakete..."
wget -qO - https://raw.githubusercontent.com/linux-surface/linux-surface/master/pkg/keys/surface.asc \
    | gpg --dearmor | dd of=/etc/apt/trusted.gpg.d/linux-surface.gpg

if [ $? -ne 0 ]; then
    echo "Fehler beim Importieren des Schlüssels. Überprüfe deine Internetverbindung und versuche es erneut."
    exit 1
fi

echo "Füge das Linux Surface-Repository zur APT-Konfiguration hinzu..."
echo "deb [arch=amd64] https://pkg.surfacelinux.com/debian release main" \
    | tee /etc/apt/sources.list.d/linux-surface.list

echo "Aktualisiere die Repository-Metadaten..."
apt update

if [ $? -ne 0 ]; then
    echo "Fehler beim Aktualisieren der Paketlisten. Möglicherweise gibt es ein Problem mit dem Repository."
    echo "Falls du einen 'Error 401 Unauthorized' siehst, überprüfe bitte die Dokumentation auf GitHub."
    exit 1
fi

echo "Installiere den Linux Surface-Kernel und seine Abhängigkeiten..."
apt install -y linux-image-surface linux-headers-surface libwacom-surface iptsd

if [ $? -ne 0 ]; then
    echo "Fehler bei der Installation der Surface-Pakete."
    echo "Hinweis: Wenn du eine ältere Ubuntu-Version als 22.04 verwendest, entferne 'iptsd' aus der Paketliste und versuche es erneut."
    exit 1
fi

echo "Installiere den Secure Boot-Schlüssel..."
apt install -y linux-surface-secureboot-mok

echo "Aktualisiere die GRUB-Konfiguration..."
update-grub

echo "Installation abgeschlossen!"
echo "Bitte starte dein System neu. Bei der nächsten Anmeldung solltest du in den Linux Surface-Kernel booten."
echo ""
echo "WICHTIG: Nach dem Neustart erscheint möglicherweise ein blaues Menü (MokManager)."
echo "Wähle dort 'Enroll MOK' und bestätige mit 'Yes'/'Continue'."
echo "Wenn nach einem Passwort gefragt wird, gib 'surface' ein."
echo "Beachte, dass MokManager eine QWERTY-Tastaturlayout erwartet."
echo ""
echo "Nach dem Neustart kannst du mit 'uname -a' überprüfen, ob der Surface-Kernel läuft."
echo "Die Ausgabe sollte den String 'surface' enthalten."
