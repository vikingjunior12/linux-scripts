#!/bin/bash

# Nmap Scanning Script
# This script performs network scanning with Nmap

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to display usage
usage() {
    echo -e "${BLUE}Usage:${NC} $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -i, --ip <IP>           Target IP address or range (e.g., 192.168.1.1 or 192.168.1.0/24)"
    echo "  -s, --scan-type <TYPE>  Scan type: quick, full, stealth, udp, service (default: quick)"
    echo "  -o, --output <FILE>     Save output to file"
    echo "  -h, --help              Display this help message"
    echo ""
    echo "Examples:"
    echo "  $0 -i 192.168.1.1"
    echo "  $0 -i 192.168.1.0/24 -s full"
    echo "  $0 -i 10.0.0.1 -s stealth -o scan_results.txt"
}

# Check if nmap is installed
if ! command -v nmap &> /dev/null; then
    echo -e "${RED}Error: nmap is not installed${NC}"
    echo "Install it with: pkg install nmap (Termux) or apt-get install nmap (Debian/Ubuntu)"
    exit 1
fi

# Default values
SCAN_TYPE="quick"
OUTPUT_FILE=""
TARGET_IP=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--ip)
            TARGET_IP="$2"
            shift 2
            ;;
        -s|--scan-type)
            SCAN_TYPE="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            usage
            exit 1
            ;;
    esac
done

# Check if IP is provided
if [ -z "$TARGET_IP" ]; then
    echo -e "${RED}Error: Target IP is required${NC}"
    usage
    exit 1
fi

# Display scan information
echo -e "${GREEN}=== Nmap Scanning Tool ===${NC}"
echo -e "${BLUE}Target:${NC} $TARGET_IP"
echo -e "${BLUE}Scan Type:${NC} $SCAN_TYPE"
echo ""

# Prepare nmap command based on scan type
NMAP_CMD="nmap"

case $SCAN_TYPE in
    quick)
        echo -e "${YELLOW}Performing quick scan...${NC}"
        NMAP_CMD="$NMAP_CMD -T4 -F"
        ;;
    full)
        echo -e "${YELLOW}Performing full port scan (this may take a while)...${NC}"
        NMAP_CMD="$NMAP_CMD -p- -T4 -A"
        ;;
    stealth)
        echo -e "${YELLOW}Performing stealth SYN scan...${NC}"
        NMAP_CMD="$NMAP_CMD -sS -T2"
        ;;
    udp)
        echo -e "${YELLOW}Performing UDP scan...${NC}"
        NMAP_CMD="$NMAP_CMD -sU --top-ports 100"
        ;;
    service)
        echo -e "${YELLOW}Performing service/version detection...${NC}"
        NMAP_CMD="$NMAP_CMD -sV -T4"
        ;;
    *)
        echo -e "${RED}Invalid scan type: $SCAN_TYPE${NC}"
        usage
        exit 1
        ;;
esac

# Add target IP
NMAP_CMD="$NMAP_CMD $TARGET_IP"

# Add output file if specified
if [ -n "$OUTPUT_FILE" ]; then
    NMAP_CMD="$NMAP_CMD -oN $OUTPUT_FILE"
    echo -e "${BLUE}Output will be saved to:${NC} $OUTPUT_FILE"
fi

echo ""
echo -e "${YELLOW}Executing:${NC} $NMAP_CMD"
echo ""

# Execute nmap command
eval $NMAP_CMD

# Check if scan was successful
if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}Scan completed successfully!${NC}"
    if [ -n "$OUTPUT_FILE" ]; then
        echo -e "${GREEN}Results saved to: $OUTPUT_FILE${NC}"
    fi
else
    echo ""
    echo -e "${RED}Scan failed or was interrupted${NC}"
    exit 1
fi
