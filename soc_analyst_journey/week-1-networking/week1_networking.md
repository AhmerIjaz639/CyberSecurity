# Week 1 — Networking for SOC Analysts

A 7-day intensive sprint covering networking fundamentals from a SOC analyst perspective. The focus is not on configuring enterprise networks but on understanding how traffic flows, how protocols behave, and how attacks manifest at the network layer.

## Objectives

- Understand TCP/IP and OSI models well enough to classify alerts by layer
- Analyze TCP handshakes, flags, and common port numbers
- Perform subnetting to determine network scope during investigations
- Understand DNS, DHCP, and HTTP/HTTPS at the packet level
- Capture and analyze traffic using Wireshark
- Configure basic ACLs and understand firewall logic
- Troubleshoot network issues using a systematic Layer 1-7 approach

## Daily Breakdown

| Day | Topic | Key Skills | Lab |
|-----|-------|-----------|-----|
| 1 | OSI Model, TCP/IP, Network Devices | Layer identification, device roles | Linux network commands, interface analysis |
| 2 | TCP vs UDP, Subnetting, Ports | 3-way handshake, TCP flags, CIDR math | Subnetting drill, `ss` analysis |
| 3 | DNS, DHCP, HTTP/HTTPS | DORA process, DNS resolution, TLS basics | Wireshark DNS/HTTP capture |
| 4 | Switching, VLANs, Routing, NAT | VLAN segmentation, ARP, NAT translation | Packet Tracer VLAN and NAT lab |
| 5 | Firewalls, ACLs, VPNs | ACL logic, stateful inspection, IPsec/SSL | Extended ACL configuration |
| 6 | Wireshark Mastery | Packet filtering, stream follow, protocol analysis | 3 PCAP investigation exercises |
| 7 | Troubleshooting Marathon | Systematic diagnosis, Layer 1-7 approach | 5 broken network scenarios |

## SOC Relevance

Every topic in this week maps directly to SOC daily operations:

- **TCP Flags** — SYN flood detection, port scan identification
- **DNS** — DNS tunneling, suspicious query patterns, C2 communication
- **DHCP** — Rogue DHCP detection, IP conflict analysis
- **HTTP/HTTPS** — Web attack indicators, certificate anomalies
- **VLANs** — Lateral movement detection, segmentation violations
- **ACLs** — Firewall log interpretation, blocked traffic analysis
- **Wireshark** — PCAP triage, evidence extraction, timeline building

## Prerequisites

- Basic networking knowledge (CCNA level or equivalent)
- Kali Linux or Ubuntu VM with Wireshark installed
- Cisco Packet Tracer (Day 4-5 labs)

## Key Commands Reference

```bash
# Network interfaces and IPs
ip addr show
ip -br addr

# Routing table
ip route

# ARP table
ip neigh

# Active connections
ss -tunap
ss -tlnp

# DNS lookup
nslookup example.com
dig example.com

# Packet capture (CLI)
sudo tcpdump -i eth0 -w capture.pcap

# Port scan
nmap -sV 192.168.1.0/24
