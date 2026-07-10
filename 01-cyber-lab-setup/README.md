# 🖥️ Project 01 — Personal Cybersecurity Lab Setup

## Overview
Built a personal cybersecurity lab environment for 
learning offensive and defensive security techniques.

## Lab Architecture
┌─────────────────────────────────────┐
│ Windows 11 (Host) │
│ Lenovo ThinkPad E590 │
│ RAM: 12GB | SSD: 256GB │
│ │
│ ┌─────────────────────────────┐ │
│ │ VMware Workstation Player │ │
│ │ (Type 2 Hypervisor) │ │
│ │ │ │
│ │ ┌───────────────────────┐ │ │
│ │ │ Kali Linux VM │ │ │
│ │ │ RAM: 4GB │ │ │
│ │ │ Storage: 60GB │ │ │
│ │ └───────────────────────┘ │ │
│ └─────────────────────────────┘ │
└─────────────────────────────────────┘




## Tools Available

| Tool | Purpose |
|------|---------|
| Nmap | Network scanning |
| Wireshark | Packet analysis |
| Metasploit | Exploitation framework |
| Burp Suite | Web app testing |
| John the Ripper | Password cracking |
| Aircrack-ng | Wireless testing |

## Skills Demonstrated

- Hypervisor installation and configuration
- Virtual Machine creation and management  
- Kali Linux installation and setup
- VMware troubleshooting and optimization
- Windows Defender exclusion configuration
- VM snapshot management

## Challenges & Solutions

| Challenge | Solution | Learning |
|-----------|----------|----------|
| VirtualBox dependency errors | Switched to VMware Player | Software compatibility |
| VM performance issues | Optimized RAM/CPU allocation | Resource management |
| Windows Defender blocking VM | Added exclusion for VM folder | AV/EDR behavior |

## Key Concepts Learned

1. **Virtualization** — Type 1 vs Type 2 hypervisors
2. **CPU Rings** — Ring 0 (kernel) vs Ring 3 (user)
3. **File Systems** — NTFS, ext4, FAT32 security differences
4. **Linux Permissions** — rwx system and SUID bits
5. **Boot Process** — BIOS → MBR → Bootloader → Kernel
6. **Critical Files** — /etc/shadow, /etc/passwd security

## System Info

| Component | Details |
|-----------|---------|
| Host OS | Windows 11 |
| VM Software | VMware Workstation Player (Free) |
| Guest OS | Kali Linux (Latest) |
| VM Storage | D:\VMs\ |

## Status
✅ Complete — Lab fully operational
