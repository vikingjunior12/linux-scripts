#!/data/data/com.termux/files/usr/bin/bash
# Wrapper script to run nmap_scanner.py with root privileges

PYTHON="/data/data/com.termux/files/usr/bin/python3"
SCRIPT="/data/data/com.termux/files/home/coding_termux/ipscan/nmap_scanner.py"

# Pass all arguments to the Python script
su -c "$PYTHON $SCRIPT $*"
