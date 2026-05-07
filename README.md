# FOG Ambulance

A fully self-contained bootable Ubuntu 24.04 USB recovery system for diagnosing and repairing Linux servers and Windows workstations — especially those deployed via FOG imaging. Launches directly into [OpenCode](https://github.com/anomalyco/opencode), an AI-powered interactive shell, on boot.

## The Problem

FOG-imaged machines inherit the exact partition layout of the source machine. When a 256GB SSD is imaged onto a 2TB drive, `/boot` balloons to 700GB+. This causes:

- **Kernel panics** — "VFS: Unable to mount root fs on unknown-block"
- **GRUB failures** — bootloader references wrong disks/UUIDs
- **Broken fstabs** — UUIDs don't match after image deployment
- **Boot partition overflow** — no space for kernel updates

Meanwhile, Windows workstations suffer from boot sector corruption, registry issues, and missing boot config data (BCD) after imaging. Technicians in the field need a single USB stick that can fix any of these problems without network access.

## The Solution

FOG Ambulance is a custom Ubuntu 24.04 live ISO that:

1. **Boots on any x86_64 machine** from a USB stick
2. **Auto-launches OpenCode** — the AI-powered interactive CLI
3. **Provides targeted repair scripts** for the most common FOG deployment failures
4. **Works fully offline** — everything is self-contained

## Features

### Linux Repair (`scripts/linux-repair/`)

| Script | Fixes |
|---|---|
| `scan.sh` | Detects all partitions, filesystems, installed OSes, LVM volumes, EFI entries |
| `fix-boot.sh` | Shrinks oversized /boot partitions back to 1GB, regenerates initramfs, updates GRUB |
| `fix-fstab.sh` | Detects broken UUID references in /etc/fstab and auto-repairs them |
| `fix-grub.sh` | Reinstalls GRUB to the correct disk in both UEFI and BIOS/MBR modes |
| `fix-kernel-panic.sh` | Regenerates initramfs + GRUB for "VFS: Unable to mount root fs" errors |

### Windows Repair (`scripts/windows-repair/`)

Planned:
- BCD/boot sector repair
- Registry hive analysis
- Disk/partition fixup after image deployment

### Log File Analysis

Boot into the live environment, mount the target disk, and use OpenCode's AI-assisted analysis to examine:
- `/var/log/syslog`, `/var/log/kern.log` — kernel panics and driver failures
- `/var/log/boot.log` — boot process failures
- `/var/log/cloud-init-output.log` — cloud-init provisioning errors
- `Windows/System32/winevt/Logs/` — Windows Event Logs (.evtx)
- `dmesg` output — hardware detection issues

OpenCode can read these logs, identify failure patterns, and suggest remediation steps interactively.

### FOG Server Validation

The companion scripts `fog-hardware-validate.sh` and `fog-hospital-validate.sh` are deployed on FOG servers (not the USB) to validate hardware configuration matches the FOG database. They are included for reference and are not part of the bootable ISO.

## Build

```bash
# Prerequisites
sudo apt install xorriso squashfs-tools wget

# Full build (download ISO, extract, customize, repack)
sudo ./build-iso.sh --build

# Write to USB
sudo ./build-iso.sh --write /dev/sdX

# Clean up build artifacts
sudo ./build-iso.sh --clean
```

Build steps in detail:
1. **Download** — fetches Ubuntu 24.04 LTS Server ISO
2. **Extract** — mounts and copies ISO contents
3. **Unsquash** — extracts the root filesystem
4. **Customize** — installs repair scripts, pre-installs tools (parted, testdisk, ntfs-3g, etc.), configures auto-launch of OpenCode
5. **Resquash** — recompresses the modified rootfs
6. **Repack** — builds a bootable ISO with both BIOS and UEFI support

## Usage

1. Boot the USB on the target machine
2. The system boots into Ubuntu live and auto-launches OpenCode
3. Use the main menu to run targeted repairs, or drop to a root shell for manual work
4. To run a specific repair script directly: `ambulance`

### Workflow for Common Scenarios

**Kernel panic after FOG deploy:**
```
→ Boot FOG Ambulance USB
→ Select "Fix kernel panic" (fix-kernel-panic.sh)
  → Regenerates initramfs
  → Updates GRUB
→ Reboot
```

**Oversized /boot partition:**
```
→ Boot FOG Ambulance USB
→ Select "Fix /boot partition" (fix-boot.sh)
  → Resizes /boot to 1GB
  → Preserves all kernels/initrds
  → Updates fstab if UUID changed
→ Reboot
```

**Broken fstab after deploy:**
```
→ Boot FOG Ambulance USB
→ Select "Fix /etc/fstab" (fix-fstab.sh)
  → Scans all partitions
  → Matches broken UUIDs to real devices
  → Writes corrected fstab
→ Reboot
```

**Log analysis with OpenCode:**
```
→ Boot FOG Ambulance USB
→ Mount target partition: mount /dev/sda2 /mnt
→ In OpenCode: "Analyze /mnt/var/log/syslog for boot errors"
→ OpenCode reads the logs and identifies the root cause
```

## Directory Layout

```
fog-ambulance/
├── build-iso.sh              # Full ISO build pipeline
├── menu.sh                   # Interactive TUI menu
├── scripts/
│   ├── linux-repair/
│   │   ├── scan.sh           # Partition/OS scanner
│   │   ├── fix-boot.sh       # Shrink oversized /boot
│   │   ├── fix-fstab.sh      # Repair broken fstab
│   │   ├── fix-grub.sh       # Reinstall GRUB
│   │   └── fix-kernel-panic.sh  # Initramfs + GRUB regeneration
│   └── windows-repair/       # Windows repair (placeholder)
├── iso-work/                  # Build artifacts (gitignored)
│   └── ubuntu-24.04.3-live-server-amd64.iso  # Downloaded base ISO
├── fog-hardware-validate.sh   # FOG server hardware validation
├── fog-hospital-validate.sh   # FOG server deploy-time validation
└── .gitignore
```

## Requirements

- **Build machine**: Linux, 10GB+ free space, xorriso, squashfs-tools
- **Target machine**: x86_64, 2GB+ RAM, USB boot capable (UEFI or BIOS)
- **USB stick**: 4GB+ minimum
