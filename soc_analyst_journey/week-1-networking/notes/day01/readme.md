#  Day 1 — Network Devices, OSI Model & TCP/IP Model

> **SOC Analyst Journey · Week 1 · Networking Foundations**
> Lab: Kali/Ubuntu (VMware) · Resource: Jeremy's IT Lab (Days 1–3)

[Next: Day 2 →](../day-02/README.md)

---

## 📑 Table of Contents

- [Goal](#-goal)
- [Why it matters](#-why-it-matters)
- [1. Network Devices](#1-network-devices)
- [2. OSI Model](#2-osi-model-7-layers)
- [3. TCP/IP Model](#3-tcpip-model-4-layers)
- [4. Key Terminology](#4-key-terminology)
- [5. Lab 1 — Know Your Own Machine](#5--lab-1--know-your-own-machine)
- [6. Lab 2 — Ping and Think](#6--lab-2--ping-and-think)
- [7. Troubleshooting Challenge](#7--troubleshooting-challenge-apipa)
- [8. Interview Questions](#8--interview-questions)
- [9. Security Mapping](#9--security-mapping)
- [Key Takeaways](#-key-takeaways)

---

## Goal

Understand how a network works — from the **devices** to the **path data takes**, layer by layer — and connect each layer to how it is attacked and detected.

##  Why it matters

- **Network engineer:** can't configure what they don't understand.
- **SOC analyst:** if you don't know which layer data travels on, you don't know where to detect or stop an attack. In Wireshark, you must know *which layer the problem is on*.

Misconfiguration leads to: network downtime, data leaks, unauthorized access.

---

## 1. Network Devices

A network device is any hardware that **sends, receives, or forwards** data.

| Device | Function | OSI Layer | Analogy |
|--------|----------|-----------|---------|
| **Switch** | Connects devices in the *same* network; forwards by **MAC address** | L2 | Local post office |
| **Router** | Connects *different* networks; forwards by **IP address** | L3 | City post office |
| **Firewall** | Allows/blocks traffic based on rules | L3–L7 | Security guard |
| **Access Point (AP)** | Connects wireless clients to the network | L1–L2 | Wireless gate |
| **Modem** | Converts signals to connect to the ISP | L1 | — |
| **Hub** | Repeats traffic to every port (obsolete) | L1 | Shouting in a room |

### Switch vs Router (top interview question)

| Switch | Router |
|--------|--------|
| Works inside the same network | Connects different networks |
| Uses MAC addresses | Uses IP addresses |
| Layer 2 (Data Link) | Layer 3 (Network) |
| e.g. PC1 → PC2 in the same office | e.g. Office → Internet |

###  Attack surface per device

| Device | Common Attacks |
|--------|----------------|
| Switch | MAC flooding, VLAN hopping, ARP spoofing |
| Router | Route poisoning, unauthorized access, DDoS |
| Firewall | Misconfigured rules, bypass attacks |
| Access Point | Rogue AP, Evil Twin, WPA cracking |

---

## 2. OSI Model (7 Layers)

OSI is a **theoretical framework** describing how data travels from one computer's application to another's.

| Layer | Name | Purpose | Examples | PDU |
|-------|------|---------|----------|-----|
| 7 | Application | User-facing services | HTTP, DNS, FTP, SSH | Data |
| 6 | Presentation | Formatting / encryption | SSL/TLS, JPEG, ASCII | Data |
| 5 | Session | Maintains connections | NetBIOS, RPC | Data |
| 4 | Transport | Reliable/fast delivery, ports | TCP, UDP | Segment / Datagram |
| 3 | Network | Addressing & routing | IP, ICMP, routers | Packet |
| 2 | Data Link | Local delivery | MAC, Ethernet, switches | Frame |
| 1 | Physical | Bits on the medium | Cables, Wi-Fi, hubs | Bits |

**Mnemonics**

- Top → bottom: **A**ll **P**eople **S**eem **T**o **N**eed **D**ata **P**rocessing
- Bottom → top: **P**lease **D**o **N**ot **T**hrow **S**ausage **P**izza **A**way

### Encapsulation / Decapsulation

```
SENDER (Encapsulation)             RECEIVER (Decapsulation)

Data                               Bits → Frame → Packet → Segment → Data
 ↓ + TCP/UDP header (Segment)
 ↓ + IP header      (Packet)
 ↓ + MAC header     (Frame)
Bits on the wire
```

*Analogy:* putting a letter in an envelope (encapsulation); the receiver opens it (decapsulation).

### Example: sending a WhatsApp message

```
L7  Application   App creates the message
L6  Presentation  Data encrypted with TLS
L5  Session       Session established with the server
L4  Transport     Data split into segments, sequence numbers added (TCP)
L3  Network       IP addresses added (src: 192.168.1.10 → dst: server IP)
L2  Data Link     MAC addresses added (src: my NIC → dst: my router)
L1  Physical      Converted to bits → Wi-Fi signal / cable
```

###  Attacks & defenses per layer

| Layer | Attack | Defense |
|-------|--------|---------|
| L7 Application | SQL injection, XSS, phishing | WAF, input validation |
| L6 Presentation | Weak encryption | Strong TLS configuration |
| L5 Session | Session hijacking | Secure session tokens |
| L4 Transport | SYN flood, port scan | Firewall, rate limiting |
| L3 Network | IP spoofing, ICMP flood | ACLs, IPS |
| L2 Data Link | ARP spoofing, MAC flood | DAI, port security |
| L1 Physical | Cable tap, Evil Twin | Physical security |

---

## 3. TCP/IP Model (4 Layers)

OSI is theoretical; **TCP/IP is what the Internet actually runs on.**

```
OSI (7 Layers)            TCP/IP (4 Layers)
Application  ─┐
Presentation ─┼────────→  Application
Session      ─┘
Transport    ───────────→ Transport
Network      ───────────→ Internet
Data Link    ─┐
Physical     ─┴─────────→ Network Access
```

| TCP/IP Layer | Protocols / Examples |
|--------------|----------------------|
| Application | HTTP, HTTPS, DNS, SSH, FTP, DHCP, SMTP, SNMP |
| Transport | TCP, UDP, port numbers |
| Internet | IP, ICMP, ARP*, routers |
| Network Access | Ethernet, Wi-Fi, MAC, switches, cables |

\* ARP sits between Layer 2 and Layer 3; depending on context it is placed in either.

---

## 4. Key Terminology

| Term | Meaning |
|------|---------|
| Encapsulation | Adding headers as data moves down the stack |
| Decapsulation | Removing headers as data moves up the stack |
| PDU | Name of the data unit at each layer |
| Header | Control information added by each layer |
| Payload | The actual data being carried |
| MAC address | 48-bit physical address (Layer 2), e.g. `AA:BB:CC:DD:EE:FF` |
| IP address | Logical address (Layer 3), e.g. `192.168.1.10` |
| Port | Application/service identifier (Layer 4), e.g. `80` = HTTP |

---

## 5.  Lab 1 — Know Your Own Machine

**Goal:** Identify the network details of my Kali/Ubuntu VM and map each to an OSI layer.

| Task | Command | OSI Layer |
|------|---------|-----------|
| IP address | `ip addr show` | L3 |
| MAC address | `ip link show` | L2 |
| Interfaces | `ip link` | L1–L2 |
| Routing table / default gateway | `ip route` | L3 |
| DNS server | `cat /etc/resolv.conf` | L7 |
| ARP table (neighbors) | `ip neigh` | L2–L3 |
| Active connections | `ss -tunap` | L4 |





---

## 6.  Lab 2 — Ping and Think

```bash
ping -c 4 8.8.8.8
```

| Question | Answer |
|----------|--------|
| Which protocol does ping use? | **ICMP** (Layer 3 — Network) |
| What happens when the request is sent? | Encapsulation: ICMP message → IP packet → Ethernet frame → bits |
| What happens when the reply arrives? | Decapsulation: bits → frame → packet → ICMP reply processed |

---

## 7.  Troubleshooting Challenge (APIPA)

**Scenario:** User says *"My internet isn't working."* The PC shows:

```
IP Address:      169.254.15.200
Subnet Mask:     255.255.0.0
Default Gateway: (blank)
```

| Question | Answer |
|----------|--------|
| What is 169.254.x.x? | **APIPA** (Automatic Private IP Addressing / link-local). The host failed to get an address from DHCP and assigned itself one. |
| Why is the gateway blank? | APIPA gives local-link connectivity only; no DHCP server means no gateway was offered. |
| Which layer is affected? | Primarily **L7/L3 (DHCP service / addressing)**; also verify L1–L2 (cable, NIC, VLAN) since the host can't reach the DHCP server. |
| What to check first? | 1) Physical link / Wi-Fi association 2) DHCP server reachable and has free leases 3) Correct VLAN/port 4) Renew the lease and re-check `ip addr` |

>  **SOC note:** Many hosts suddenly showing 169.254.x.x can indicate **DHCP starvation** or a failed/rogue DHCP server.

---

## 8.  Interview Questions

<details>
<summary><b>List the 7 OSI layers.</b></summary>

Application, Presentation, Session, Transport, Network, Data Link, Physical.

</details>

<details>
<summary><b>What is the difference between Layer 2 and Layer 3?</b></summary>

Layer 2 handles local delivery using MAC addresses (frames, switches). Layer 3 handles logical addressing and routing between networks using IP addresses (packets, routers).

</details>

<details>
<summary><b>Which layer does a switch work on, and a router? Why?</b></summary>

A switch works at Layer 2 because it forwards frames using MAC addresses within one network. A router works at Layer 3 because it forwards packets between networks using IP addresses and a routing table.

</details>

<details>
<summary><b>What is the PDU at Layer 3?</b></summary>

Packet.

</details>

---

## 9. 🔐 Security Mapping

| Concept | Network engineer thinks | SOC analyst thinks |
|---------|-------------------------|--------------------|
| MAC address | Identify a device | MAC spoofing is possible |
| IP address | Routing | IP spoofing, reconnaissance |
| Port number | Identify a service | Port scan = attacker recon |
| OSI layers | Where to troubleshoot | Which layer is the attack on? |
| Encapsulation | How data travels | Where could a malicious payload hide? |

---

## ✅ Key Takeaways

- Switch = L2/MAC, Router = L3/IP.
- PDUs: Data → Segment → Packet → Frame → Bits.
- Ping = ICMP (L3).
- 169.254.x.x = DHCP failure (APIPA).
- Knowing the layer tells you where to troubleshoot *and* where to detect an attack.

[Next: Day 2 — TCP vs UDP & Subnetting →](../day-02/README.md)
