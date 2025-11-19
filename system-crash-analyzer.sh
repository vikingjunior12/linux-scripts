#!/bin/bash
# System Crash Analyzer
# Sammelt Informationen über Systemabstürze und Hardware-Probleme

OUTPUT_FILE="/home/jonas/system-analysis-$(date +%Y%m%d-%H%M%S).md"

echo "=== System Crash Analysis ===" | tee "$OUTPUT_FILE"
echo "Analysis Date: $(date)" | tee -a "$OUTPUT_FILE"
echo "Hostname: $(hostname)" | tee -a "$OUTPUT_FILE"
echo "" | tee -a "$OUTPUT_FILE"

# Funktion für Sektionen
write_section() {
    echo "" >> "$OUTPUT_FILE"
    echo "## $1" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
}

write_subsection() {
    echo "" >> "$OUTPUT_FILE"
    echo "### $1" >> "$OUTPUT_FILE"
    echo '```' >> "$OUTPUT_FILE"
}

end_subsection() {
    echo '```' >> "$OUTPUT_FILE"
}

echo "Collecting system information..."

# ============ SYSTEM INFO ============
write_section "System Information"
write_subsection "Uptime"
uptime >> "$OUTPUT_FILE"
end_subsection

write_subsection "Kernel Version"
uname -a >> "$OUTPUT_FILE"
end_subsection

write_subsection "OS Release"
cat /etc/os-release >> "$OUTPUT_FILE"
end_subsection

# ============ MEMORY INFO ============
write_section "Memory Information"
write_subsection "Current Memory Usage"
free -h >> "$OUTPUT_FILE"
end_subsection

write_subsection "OOM Killer Activity (Previous Boot)"
journalctl -b -1 --no-pager 2>/dev/null | grep -i "oom\|out of memory\|killed process" | head -20 >> "$OUTPUT_FILE" 2>&1
if [ $? -ne 0 ]; then
    echo "No previous boot logs available or no OOM events found" >> "$OUTPUT_FILE"
fi
end_subsection

# ============ HARDWARE INFO ============
write_section "Hardware Information"
write_subsection "Graphics Hardware"
lspci | grep -i "vga\|3d\|display" >> "$OUTPUT_FILE"
end_subsection

write_subsection "CPU Information"
lscpu | grep -E "Model name|Architecture|CPU\(s\)|Thread|Core" >> "$OUTPUT_FILE"
end_subsection

# ============ CRASH REPORTS ============
write_section "Crash Reports"
write_subsection "Recent Crash Files"
ls -lth /var/crash/ 2>/dev/null | head -15 >> "$OUTPUT_FILE"
if [ $? -ne 0 ]; then
    echo "No crash files found or directory not accessible" >> "$OUTPUT_FILE"
fi
end_subsection

write_subsection "Most Recent Crash Details"
LATEST_CRASH=$(ls -t /var/crash/*.crash 2>/dev/null | head -1)
if [ -n "$LATEST_CRASH" ]; then
    echo "File: $LATEST_CRASH" >> "$OUTPUT_FILE"
    head -100 "$LATEST_CRASH" 2>/dev/null >> "$OUTPUT_FILE"
else
    echo "No crash reports found" >> "$OUTPUT_FILE"
fi
end_subsection

# ============ CURRENT BOOT ERRORS ============
write_section "Current Boot - Critical Errors"
write_subsection "Error and Critical Messages"
journalctl -b -0 --no-pager -p 3 2>/dev/null | tail -50 >> "$OUTPUT_FILE"
end_subsection

write_subsection "Kernel Errors (with sudo)"
if command -v sudo &> /dev/null; then
    sudo dmesg -T -l err,crit,alert,emerg 2>/dev/null | tail -50 >> "$OUTPUT_FILE"
    if [ $? -ne 0 ]; then
        echo "Could not read kernel messages (requires sudo)" >> "$OUTPUT_FILE"
    fi
else
    echo "sudo not available" >> "$OUTPUT_FILE"
fi
end_subsection

# ============ PREVIOUS BOOT ANALYSIS ============
write_section "Previous Boot Analysis"
write_subsection "Last 100 Lines of Previous Boot"
journalctl -b -1 --no-pager 2>/dev/null | tail -100 >> "$OUTPUT_FILE"
if [ $? -ne 0 ]; then
    echo "No previous boot logs available" >> "$OUTPUT_FILE"
fi
end_subsection

write_subsection "Shutdown/Crash Indicators (Previous Boot)"
journalctl -b -1 --no-pager 2>/dev/null | grep -E "Shutting down|Stopping|Reached target.*Shutdown|panic|crash|segfault" | tail -30 >> "$OUTPUT_FILE"
if [ $? -ne 0 ]; then
    echo "No previous boot logs available" >> "$OUTPUT_FILE"
fi
end_subsection

write_subsection "Previous Boot - Errors Only"
journalctl -b -1 -p 3 --no-pager 2>/dev/null | tail -50 >> "$OUTPUT_FILE"
if [ $? -ne 0 ]; then
    echo "No previous boot error logs available" >> "$OUTPUT_FILE"
fi
end_subsection

# ============ GPU/GRAPHICS ISSUES ============
write_section "GPU and Graphics Driver Issues"
write_subsection "i915/GPU/DRM Errors (Previous Boot)"
journalctl -b -1 --no-pager 2>/dev/null | grep -i "i915\|gpu\|drm" | grep -i "error\|fail\|warn" | tail -30 >> "$OUTPUT_FILE"
if [ $? -ne 0 ]; then
    echo "No GPU-related errors found or no previous boot logs" >> "$OUTPUT_FILE"
fi
end_subsection

write_subsection "Current Graphics Driver Status"
journalctl -b -0 --no-pager 2>/dev/null | grep -i "i915\|drm" | tail -20 >> "$OUTPUT_FILE"
end_subsection

# ============ HARDWARE ERRORS ============
write_section "Hardware Errors"
write_subsection "Machine Check Exceptions and Hardware Errors"
if [ -f /var/log/kern.log ]; then
    grep -i "hardware error\|mce\|machine check" /var/log/kern.log 2>/dev/null | tail -20 >> "$OUTPUT_FILE"
    if [ $? -ne 0 ]; then
        echo "No hardware errors found in kern.log" >> "$OUTPUT_FILE"
    fi
else
    echo "/var/log/kern.log not found" >> "$OUTPUT_FILE"
fi
end_subsection

write_subsection "ACPI and Hardware Initialization Errors"
journalctl -b -0 --no-pager 2>/dev/null | grep -i "acpi.*error\|hardware.*fail" | head -30 >> "$OUTPUT_FILE"
end_subsection

# ============ SYSTEM DIAGNOSTICS ============
write_section "System Diagnostics"
write_subsection "Critical System Messages (Search Pattern)"
journalctl -b -0 --no-pager 2>/dev/null | grep -i "kernel panic\|oops\|watchdog\|mce\|critical" | head -30 >> "$OUTPUT_FILE"
if [ $(journalctl -b -0 --no-pager 2>/dev/null | grep -i "kernel panic\|oops\|watchdog\|mce\|critical" | wc -l) -eq 0 ]; then
    echo "No critical system messages found in current boot" >> "$OUTPUT_FILE"
fi
end_subsection

write_subsection "Temperature Sensors (if available)"
if command -v sensors &> /dev/null; then
    sensors >> "$OUTPUT_FILE" 2>&1
else
    echo "lm-sensors not installed. Install with: sudo apt install lm-sensors" >> "$OUTPUT_FILE"
fi
end_subsection

# ============ DISK HEALTH ============
write_section "Disk Information"
write_subsection "Disk Space Usage"
df -h >> "$OUTPUT_FILE"
end_subsection

write_subsection "Disk I/O Statistics"
if command -v iostat &> /dev/null; then
    iostat -x 1 2 >> "$OUTPUT_FILE" 2>&1
else
    echo "iostat not installed. Install with: sudo apt install sysstat" >> "$OUTPUT_FILE"
fi
end_subsection

# ============ SUMMARY ============
write_section "Quick Summary"
echo '```' >> "$OUTPUT_FILE"
echo "Analysis completed at: $(date)" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "Key findings:" >> "$OUTPUT_FILE"
echo "- System uptime: $(uptime -p)" >> "$OUTPUT_FILE"
echo "- Crash files found: $(ls /var/crash/*.crash 2>/dev/null | wc -l)" >> "$OUTPUT_FILE"
echo "- Previous boot available: $(journalctl -b -1 --no-pager &>/dev/null && echo 'Yes' || echo 'No')" >> "$OUTPUT_FILE"
echo "- Graphics: $(lspci | grep -i vga | cut -d: -f3-)" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "For AI analysis, provide this file along with specific symptoms." >> "$OUTPUT_FILE"
echo '```' >> "$OUTPUT_FILE"

echo ""
echo "✅ Analysis complete!"
echo "📄 Report saved to: $OUTPUT_FILE"
echo ""
echo "You can view it with: cat $OUTPUT_FILE"
echo "Or open in an editor: nano $OUTPUT_FILE"
echo ""
