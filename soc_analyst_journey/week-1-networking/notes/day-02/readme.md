#  Day 2 — TCP vs UDP, Subnetting & Router/Switch Logic

> **SOC Analyst Journey · Week 1 · Networking Foundations**
> Lab: Kali/Ubuntu (VMware) 



---

## 📑 Table of Contents

- [Goal](#-goal)
- [Quick Recap from Day 1](#-quick-recap-from-day-1)
- [Part A — TCP vs UDP](#part-a--tcp-vs-udp-layer-4)
- [Part B — Subnetting](#part-b--subnetting)
- [Part C — Router vs Switch: Who Can Talk to Whom](#part-c--router-vs-switch-who-can-talk-to-whom)
- [Troubleshooting Challenge](#️-troubleshooting-challenge)
- [Interview Questions](#-interview-questions)
- [Security Mapping](#-security-mapping)
- [Key Takeaways](#-key-takeaways)

---

##  Goal

Understand how TCP and UDP behave at Layer 4 (and how attackers abuse them), and master subnetting well enough to reason about segmentation, ACLs and connectivity problems.

## Quick Recap from Day 1

- Encapsulation: **Data → Segment → Packet → Frame → Bits**
- Ping uses **ICMP**, Layer 3 (Network)

---

# Part A — TCP vs UDP (Layer 4)

## Overview

| Feature | TCP | UDP |
|---------|-----|-----|
| Connection | Connection-oriented | Connectionless |
| Reliability | Guaranteed delivery | Best effort |
| Ordering | In order | No guarantee |
| Speed | Slower | Faster |
| Header size | 20 bytes | 8 bytes |
| Flow control | Yes | No |
| Error recovery | Retransmission | None |
| Typical use | HTTP(S), SSH, FTP, SMTP | DNS, DHCP, VoIP, streaming, gaming |

> **Analogy:** TCP = a phone call (connect, confirm, retransmit, hang up). UDP = a voice note (send and hope).

## TCP 3-Way Handshake

```
Client                               Server
  │──────── SYN (seq=x) ───────────→ │   "I want to connect"
  │←─────── SYN-ACK (seq=y, ack=x+1)─│   "OK, I'm ready"
  │──────── ACK (ack=y+1) ─────────→ │   "Connection established"
  │◄═════════ DATA TRANSFER ════════►│
```

## TCP Flags

| Flag | Meaning | What a SOC analyst looks for |
|------|---------|-----------------------------|
| SYN | Start a connection | Many SYNs with no ACK → **SYN flood** |
| ACK | Acknowledge receipt | Normal traffic |
| FIN | Graceful close | Normal traffic |
| RST | Abort connection | Many RSTs → **port scan** or rejected connections |
| PSH | Push data immediately | PSH+ACK is common in normal transfers |
| URG | Urgent data | Rare; worth investigating |

## UDP — Fire and Forget

```
Client                               Server
  │──────── DATA ──────────────────→ │
  │  (no handshake, no ACK, no order)│
  │──────── DATA ──────────────────→ │
```

## Common Ports (must memorize)

| Port | Service | Protocol |
|------|---------|----------|
| 20 / 21 | FTP (data / control) | TCP |
| 22 | SSH | TCP |
| 23 | Telnet (insecure) | TCP |
| 25 | SMTP | TCP |
| 53 | DNS | TCP + UDP |
| 67 / 68 | DHCP (server / client) | UDP |
| 80 | HTTP | TCP |
| 110 | POP3 | TCP |
| 143 | IMAP | TCP |
| 161 | SNMP | UDP |
| 443 | HTTPS | TCP |
| 514 | Syslog | UDP |
| 3389 | RDP | TCP |

## Commands

```bash
ss -t                # active TCP connections
ss -u                # active UDP connections
ss -tunap            # TCP + UDP with ports and processes
ss -tlnp             # listening ports (what services are exposed)
ss -tunap | grep :22 # check a specific port
```





##  Security angle

| Concept | Relevance |
|---------|-----------|
| SYN flood | Attacker sends many SYNs without completing the handshake → exhausts the server's connection table (DoS) |
| RST patterns | Port-scan detection, connection reset attacks |
| TCP flags in Wireshark | Quickly identify suspicious traffic |
| UDP | Amplification attacks (DNS, NTP) |
| Open ports | Each open port = attack surface (visible with Nmap) |

---

# Part B — Subnetting

## IP and Subnet Mask Basics

```
IPv4 = 32 bits = 4 octets

192.168.66.128
11000000.10101000.01000010.10000000
```

The subnet mask separates the **network portion** from the **host portion**.

```
IP:    192.168.66.128
Mask:  255.255.255.0
→ Network = 192.168.66   Host = .128
```

## CIDR Notation

```
/24 = 11111111.11111111.11111111.00000000 = 255.255.255.0
/26 = 11111111.11111111.11111111.11000000 = 255.255.255.192
```

## The Magic Table

| Host bits | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|-----------|---|---|---|---|---|---|---|---|---|
| **CIDR** | /24 | /25 | /26 | /27 | /28 | /29 | /30 | /31 | /32 |
| **Mask (last octet)** | 0 | 128 | 192 | 224 | 240 | 248 | 252 | 254 | 255 |
| **Total IPs / Block size** | 256 | 128 | 64 | 32 | 16 | 8 | 4 | 2 | 1 |
| **Usable hosts** | 254 | 126 | 62 | 30 | 14 | 6 | 2 | 0* | 0* |

\* /31 is used for point-to-point links (RFC 3021); /32 is a single-host route.

## Quick Formula

```
Given /X:
1. Host bits         = 32 − X
2. Total IPs         = 2^(host bits)
3. Usable hosts      = Total IPs − 2
4. Block size        = Total IPs
5. Mask (last octet) = 256 − block size
```

**Example — /28:** host bits = 4 → total = 16 → usable = 14 → mask = 256 − 16 = 240 → `255.255.255.240`

## Worked Example — 192.168.10.0/26

Block size = 64, so subnets start at `.0`, `.64`, `.128`, `.192`.

| Subnet | Network | First usable | Last usable | Broadcast |
|--------|---------|--------------|-------------|-----------|
| 1 | 192.168.10.0 | .1 | .62 | .63 |
| 2 | 192.168.10.64 | .65 | .126 | .127 |
| 3 | 192.168.10.128 | .129 | .190 | .191 |
| 4 | 192.168.10.192 | .193 | .254 | .255 |

Mask: `255.255.255.192` · Usable hosts per subnet: **62**

##  Subnetting Drill

| # | Network | Network Addr | First | Last | Broadcast | Mask | Usable |
|---|---------|--------------|-------|------|-----------|------|--------|
| 1 | 10.0.0.0/27 | 10.0.0.0 | 10.0.0.1 | 10.0.0.30 | 10.0.0.31 | 255.255.255.224 | 30 |
| 2 | 172.16.5.0/28 | 172.16.5.0 | 172.16.5.1 | 172.16.5.14 | 172.16.5.15 | 255.255.255.240 | 14 |
| 3 | 192.168.1.128/25 | 192.168.1.128 | 192.168.1.129 | 192.168.1.254 | 192.168.1.255 | 255.255.255.128 | 126 |
| 4 | 10.10.10.0/30 | 10.10.10.0 | 10.10.10.1 | 10.10.10.2 | 10.10.10.3 | 255.255.255.252 | 2 |
| 5 | 192.168.100.0/26 | 192.168.100.0 | 192.168.100.1 | 192.168.100.62 | 192.168.100.63 | 255.255.255.192 | 62 |

##  Verify on Linux

```bash
ip -br addr
```

Work out: network address, broadcast address, number of usable hosts, and whether the gateway is in the same subnet.

**Example (my Kali VM):** `192.168.66.128/24` → Network `192.168.66.0` · Broadcast `192.168.66.255` · Usable `254` · Gateway in the same subnet ✅



##  Security angle

| Concept | Relevance |
|---------|-----------|
| Subnetting | Network segmentation limits an attacker's lateral movement |
| ACLs / firewall rules | Can't be written correctly without subnet knowledge |
| /30 links | Point-to-point, minimal attack surface |

---

# Part C — Router vs Switch: Who Can Talk to Whom

## Golden Rule

```
SAME subnet       → Switch is enough   (Layer 2)
DIFFERENT subnet  → Router is required (Layer 3)
```

The **subnet mask** decides who is "same" and who is "different."

## Decision Flow (what a host does before sending)

```
Is the destination IP in my subnet? (IP + mask)
        │
   ┌────┴────┐
  YES        NO
   │          │
ARP for the   Send to default gateway
host's MAC       │
   │         Gateway configured?
   │         ┌───┴───┐
   │        YES      NO →  fail ("no route to host")
   │         │
   │      Router forwards
   ▼         ▼
  ✅        ✅
```

## Scenarios

| # | Scenario | PC1 | PC2 | Router | Result |
|---|----------|-----|-----|--------|--------|
| 1 | Same subnet, same switch | 192.168.1.10/24 | 192.168.1.20/24 | No |  Works |
| 2 | Different subnet, no router | 192.168.1.10/24 | 10.0.0.5/24 | No |  PC1 refuses to send (no gateway) |
| 3 | Different subnet, with router | 192.168.1.10/24 (GW .1.1) | 192.168.2.10/24 (GW .2.1) | Yes |  Works via router |
| 4 | Mismatched mask | 192.168.1.10/24 | 192.168.1.200/25 | No |  One-way problem |
| 5 | /30 point-to-point | 10.0.0.1/30 | 10.0.0.2/30 | N/A |  Works (directly connected) |

### Scenario 3 — step by step

1. PC1 pings 192.168.2.10
2. PC1 checks: is it in 192.168.1.0/24? **No**
3. PC1 sends the packet to its gateway 192.168.1.1
4. R1 checks its routing table: `192.168.2.0/24 → Interface 2`
5. R1 forwards the packet to PC2 via SW2
6. The reply follows the same path in reverse

### Scenario 4 — mismatched mask

```
PC1 (/24): thinks 192.168.1.200 is local     → sends ARP + frame directly
PC2 (/25): network 192.168.1.128; thinks .10 is NOT local → tries a gateway
```

PC1's request reaches PC2, but PC2 believes PC1 is on a different subnet and tries to reply through a gateway. With no usable gateway the reply never returns → **asymmetric / one-way communication**, a classic real-world misconfiguration.

##  Practice Question

**Topology:** R1 has only **Interface 1 = 192.168.1.1/24**. PC1 (192.168.1.10) and PC2 (192.168.1.50) are in 192.168.1.0/24 with gateway 192.168.1.1. PC3 is 192.168.2.10/24 with gateway 192.168.2.1. All connected to SW1.

| # | Question | Answer | Reason |
|---|----------|--------|--------|
| 1 | PC1 → PC2 |  Works | Same subnet, switched at Layer 2 |
| 2 | PC1 → PC3 |  Fails | Different subnet; R1 has no interface/route for 192.168.2.0/24 |
| 3 | PC3 → PC1 |  Fails | PC3's gateway 192.168.2.1 doesn't exist anywhere, so ARP for it fails |
| 4 | PC3 → Internet |  Fails | Same reason — its gateway is unreachable |

**Fix:** configure `Interface 2: 192.168.2.1/24` on R1 (or move PC3 into 192.168.1.0/24).

---

## 🛠️ Troubleshooting Challenge

**Scenario:** Two PCs on the same switch can't ping each other.

```
PC1: 192.168.1.10/25
PC2: 192.168.1.200/25
Gateway: 192.168.1.1/25
```

| Host | Subnet (/25, block 128) | Usable range |
|------|-------------------------|--------------|
| PC1 (.10) | 192.168.1.0/25 | .1 – .126 (broadcast .127) |
| PC2 (.200) | 192.168.1.128/25 | .129 – .254 (broadcast .255) |

- **Same subnet?** No. /25 splits the 256 addresses at **.128**, so the hosts are in different subnets.
- **Problem:** Same switch, different subnets, no router between them. The gateway `.1` exists only in PC1's subnet.
- **Fix:** Put both in the same subnet (e.g. /24), or add a router with an interface in each subnet.

---

##  Interview Questions

<details>
<summary><b>Give 3 differences between TCP and UDP.</b></summary>

TCP is connection-oriented, reliable and ordered (retransmission + flow control); UDP is connectionless, best-effort and faster with a smaller header (8 vs 20 bytes).

</details>

<details>
<summary><b>Explain the TCP 3-way handshake.</b></summary>

Client sends **SYN**, server replies **SYN-ACK**, client sends **ACK** — connection established, data transfer begins.

</details>

<details>
<summary><b>What is a SYN flood and which TCP flag is abused?</b></summary>

An attacker sends many **SYN** packets and never completes the handshake with the final ACK. The server's half-open connection table fills up, and legitimate users can't connect (DoS).

</details>

<details>
<summary><b>Does DNS use TCP or UDP? Why?</b></summary>

Both. **UDP 53** for normal small queries (fast, low overhead). **TCP 53** for large responses such as zone transfers or responses exceeding the UDP size limit.

</details>

<details>
<summary><b>How many usable hosts are in 192.168.1.0/28? Network and broadcast?</b></summary>

14 usable hosts. Network: `192.168.1.0`, broadcast: `192.168.1.15`.

</details>

---

##  Security Mapping

| Concept | Cybersecurity Relevance |
|---------|------------------------|
| TCP SYN | SYN flood DDoS |
| TCP RST | Connection reset attacks, port-scan detection |
| TCP flags | Spotting suspicious traffic in Wireshark |
| UDP | Amplification attacks (DNS, NTP) |
| Port numbers | Nmap scans — open ports = attack surface |
| Subnetting | Segmentation — limits lateral movement |
| Wrong subnet mask | Possible segmentation bypass; "why is this host talking to another subnet?" |
| No gateway | Host can't reach the Internet but can still move laterally on the local network |
| Rogue router | Traffic redirection / MITM |

---

##  Key Takeaways

- TCP = reliable (3-way handshake); UDP = fast (fire and forget).
- Know the common ports — DNS is **53 on TCP and UDP**.
- Subnetting formula: block size = 2^(host bits); usable = block − 2; mask = 256 − block.
- Same subnet → switch; different subnet → router.
- A mask mismatch can cause one-way connectivity.

