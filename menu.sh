#!/usr/bin/env bash
# FOG Ambulance - Main Menu
# Interactive recovery system for offline Linux and Windows clients

VERSION="0.1.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPAIR_DIR="${SCRIPT_DIR}/linux-repair"
WIN_DIR="${SCRIPT_DIR}/windows-repair"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

##############################################################################

banner() {
    echo -e "${CYAN}"
    echo ' ███████╗ ██████╗██╗     ██████╗ ██╗   ██╗'
    echo ' ██╔════╝██╔════╝██║     ██╔══██╗╚██╗ ██╔╝'
    echo ' █████╗  ██║     ██║     ██████╔╝ ╚████╔╝ '
    echo ' ██╔══╝  ██║     ██║     ██╔═══╝   ╚██╔╝  '
    echo ' ███████╗╚██████╗███████╗██║        ██║   '
    echo ' ╚══════╝ ╚═════╝╚══════╝╚═╝        ╚═╝   '
    echo -e "  Ambulance Recovery System v${VERSION}${NC}"
    echo ""
}

header() {
    echo -e "\n${BLUE}${BOLD}══════════════════════════════════════${NC}"
    echo -e "${BLUE}${BOLD}  $1${NC}"
    echo -e "${BLUE}${BOLD}══════════════════════════════════════${NC}"
}

wait_key() {
    echo -ne "\n  ${YELLOW}Press ENTER to continue...${NC}"
    read -r
}

##############################################################################

menu_scan() {
    header "SCAN - Detect All Partitions & OS"
    if [ -x "${REPAIR_DIR}/scan.sh" ]; then
        sudo bash "${REPAIR_DIR}/scan.sh"
    else
        echo "  Scan script not found"
    fi
    wait_key
}

menu_fix_boot() {
    header "FIX /BOOT - Shrink Oversized Boot Partition"
    echo -e "  ${YELLOW}This will resize an oversized /boot partition to 1GB${NC}"
    echo -e "  and preserve all kernel/initrd files."
    echo -ne "\n  Proceed? [y/N] "
    read -r ans
    case "$ans" in
        [Yy]*)
            if [ -x "${REPAIR_DIR}/fix-boot.sh" ]; then
                sudo bash "${REPAIR_DIR}/fix-boot.sh"
            else
                echo "  Fix script not found"
            fi
            ;;
        *) echo "  Cancelled" ;;
    esac
    wait_key
}

menu_fix_fstab() {
    header "FIX /ETC/FSTAB"
    echo -e "  ${YELLOW}Detect and repair broken fstab entries${NC}"
    echo -ne "\n  Proceed? [y/N] "
    read -r ans
    case "$ans" in
        [Yy]*)
            if [ -x "${REPAIR_DIR}/fix-fstab.sh" ]; then
                sudo bash "${REPAIR_DIR}/fix-fstab.sh"
            else
                echo "  Fix script not found"
            fi
            ;;
        *) echo "  Cancelled" ;;
    esac
    wait_key
}

menu_fix_grub() {
    header "FIX GRUB - Reinstall Bootloader"
    echo -e "  ${YELLOW}Reinstall GRUB to the correct disk${NC}"
    echo -ne "\n  Proceed? [y/N] "
    read -r ans
    case "$ans" in
        [Yy]*)
            if [ -x "${REPAIR_DIR}/fix-grub.sh" ]; then
                sudo bash "${REPAIR_DIR}/fix-grub.sh"
            else
                echo "  Fix script not found"
            fi
            ;;
        *) echo "  Cancelled" ;;
    esac
    wait_key
}

menu_shell() {
    header "DROPS TO ROOT SHELL"
    echo -e "  ${YELLOW}Dropping to root shell for manual repair...${NC}"
    echo -e "  Type ${BOLD}exit${NC} to return to menu."
    echo ""
    sudo bash
    wait_key
}

menu_reboot() {
    header "REBOOT"
    echo -ne "  ${RED}Reboot now?${NC} [y/N] "
    read -r ans
    case "$ans" in
        [Yy]*) sudo reboot ;;
        *) echo "  Cancelled" ;;
    esac
}

##############################################################################

main() {
    while true; do
        clear
        banner
        echo -e "  ${BOLD}Main Menu${NC}"
        echo -e "  ─────────────────────────────"
        echo -e "  ${GREEN}1)${NC} Scan all partitions & OS"
        echo -e "  ${GREEN}2)${NC} Fix oversized /boot partition"
        echo -e "  ${GREEN}3)${NC} Fix /etc/fstab"
        echo -e "  ${GREEN}4)${NC} Reinstall GRUB"
        echo -e "  ${GREEN}5)${NC} Root shell (manual repair)"
        echo -e "  ─────────────────────────────"
        echo -e "  ${RED}9)${NC} Reboot"
        echo -e ""
        echo -ne "  Select: "
        read -r choice
        case "$choice" in
            1) menu_scan ;;
            2) menu_fix_boot ;;
            3) menu_fix_fstab ;;
            4) menu_fix_grub ;;
            5) menu_shell ;;
            9) menu_reboot ;;
            *) echo "  Invalid choice" ; sleep 1 ;;
        esac
    done
}

main "$@"
