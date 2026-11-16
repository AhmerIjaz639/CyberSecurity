# Wireshark for SOC Analysts - Day 06

My hands-on learning log for packet analysis with Wireshark, written from a SOC analyst point of view. The course had 12 sections, ending with a full incident investigation project. Each section has its own folder with notes, the filters I learned, and my answers to the practice scenarios, including the mistakes.

Status: complete (all 12 sections)
Capstone project: [Operation Midnight Invoice](section-12-capstone-operation-midnight-invoice/README.md)

## Why I am learning this

Alerts from a SIEM or an AI tool tell me where to look. A packet capture tells me what actually happened. Wireshark is how I check an alert, prove an attack, and write down evidence that someone else can verify. Encrypted traffic, custom protocols and legal evidence are all cases where I still need to read the packets myself.

## Progress and scores

Scores are the ratings I got in my practice reviews, rounded. They show where I am strong and where I need more practice. They are not an official exam result.

| # | Section | Score | Status |
|---|---------|-------|--------|
| 1 | [Wireshark Fundamentals](section-01-fundamentals/README.md) | 90 | Done |
| 2 | [Capture and Display Filters](section-02-filters/README.md) | 85 | Done |
| 3 | [DNS Analysis](section-03-dns/README.md) | 75 | Done |
| 4 | [HTTP Analysis](section-04-http/README.md) | 83 | Done |
| 5 | [HTTPS / TLS Analysis](section-05-tls/README.md) | 85 | Done |
| 6 | [DHCP Analysis](section-06-dhcp/README.md) | 85 | Done |
| 7 | [TCP Deep Dive](section-07-tcp/README.md) | 91 | Done |
| 8 | [ICMP and ARP Analysis](section-08-icmp-arp/README.md) | 80 | Done |
| 9 | [SMB and FTP Analysis](section-09-smb-ftp/README.md) | 96 | Done |
| 10 | [Malicious Traffic Analysis](section-10-malicious-traffic/README.md) | 90 | Done |
| 11 | [Statistics and Expert Info](section-11-statistics/README.md) | 70 | Done |
| 12 | [Capstone: Operation Midnight Invoice](section-12-capstone-operation-midnight-invoice/README.md) | 80 | Done |

Average of the scored sections (2 to 12): about 84 percent.

## Bootcamp progress tracker

```
Theory:             ███████░░░ 70%
Practical:          ███████░░░ 70%
Troubleshooting:    ██████░░░░ 60%
Interview:          ██████░░░░ 60%
Cybersecurity:      ███████░░░ 70%
Scripting (SOC):    ██░░░░░░░░ 20%

Wireshark Packet Analysis Skill: 80% (SOC Ready!)
```

## Performance summary

Strong areas:

- TCP flags, handshakes and flow control (zero window analysis)
- FTP and SMB analysis, brute force and lateral movement
- Reverse shell and C2 recognition
- Writing a practical containment plan (isolate, block, kill, then investigate)
- Rogue DHCP and ARP poisoning concepts

Areas I need to improve:

- DNS: naming DGA and telling Base64 from hashing, and decoding Base64 myself
- Web shells and remote code execution
- Domain fronting, SNI and certificate mismatch, and JA3
- Layer 2 defences such as DHCP snooping
- Nmap scan types (SYN scan) and how they look in a capture
- Statistics tools: Protocol Hierarchy, Conversations and Expert Information
- Cryptomining and the Stratum protocol
- Filter syntax: `==` instead of `=`, correct field names, using `ip.src` or `ip.dst`

Things I did not know on my first attempt, now written up:

- DGA, Base64 vs hashing, web shell upload chain, domain fronting, JA3, DHCP snooping, Nmap half-open scan, ICMP magic bytes, Stratum mining traffic, Protocol Hierarchy and Expert Information

## Capstone project: Operation Midnight Invoice

A full investigation of a simulated breach at Company XYZ. A finance workstation downloaded a fake invoice update, opened a reverse shell, probed an internal server, stole a salary spreadsheet over FTP and sent data out through DNS. I rebuilt the attack chain from the timeline, extracted the indicators, mapped the techniques to MITRE ATT&CK and wrote the containment plan.

Result: 80 percent (grade B+). Full write-up in [the project folder](section-12-capstone-operation-midnight-invoice/README.md).

## How each section is organised

1. Real world context: where the topic shows up in SOC work
2. Core concepts and filters
3. A sample capture walked through packet by packet
4. Practice scenarios (medium and hard) with my answers and corrections

## Quick detection table

What I should think of when I see a pattern in a capture.

| What I see | What it may mean | Section |
|------------|------------------|---------|
| Same-size packets at exact intervals, then one huge upload | C2 beaconing then exfiltration | 1, 10 |
| Many NXDOMAIN replies for random-looking domains | DGA malware looking for its C2 server | 3 |
| Long Base64-looking subdomains, many TXT queries | DNS tunneling / data exfiltration | 3, 12 |
| `'` or `UNION SELECT` in a URL, then 500 then 200 | SQL injection that worked | 4 |
| POST of a `.php` file, then `shell.php?cmd=` | Web shell and remote code execution | 4 |
| TLS with no SNI and a self-signed certificate | Malware talking straight to an IP | 5 |
| SNI and certificate name do not match | Spoofed SNI or fronting-style C2 | 5 |
| Two DHCP offers, client picks the unknown server | Rogue DHCP server (MITM) | 6 |
| Hundreds of Discovers with different MACs | DHCP starvation | 6 |
| SYN then RST-ACK / SYN-ACK then RST / SYN with no reply | Closed / open (SYN scan) / filtered port | 7 |
| Window size 0, then RST later | Receiver out of buffer, not a network fault | 7 |
| Repeated unsolicited ARP replies for the gateway IP | ARP poisoning (MITM) | 8 |
| Large ICMP echo requests with `MZ` or `PK` in the data | ICMP tunneling | 8 |
| Many 530 replies, then 230, then RETR | FTP brute force then data theft | 9, 12 |
| Tree connect to `ADMIN$`, then `psexecsvc.exe` written | PsExec lateral movement | 9 |
| Readable commands (`whoami`) on port 4444 | Reverse shell | 10, 12 |
| `mining.submit` / `xmrig` on port 3333 | Cryptojacking | 10 |
| DNS is most of the traffic in Protocol Hierarchy | DNS tunneling or DGA flood | 11 |
| One host with most of the bytes in Conversations | Exfiltration top talker | 11 |

## Display filter cheat sheet

```
# General
ip.addr == 10.0.0.5
ip.src == 10.0.0.5 && ip.dst == 8.8.8.8
tcp.port == 443 || tcp.port == 80
!arp
(tcp.port == 4444 || tcp.port == 8080) && ip.addr == 185.10.50.20

# DNS
dns.flags.response == 0
dns.flags.rcode == 3
dns.qry.type == 16
dns.qry.name contains "xyz"

# HTTP
http.request.method == "POST"
http.response.code == 200
http.request.uri contains "UNION"
http.user_agent contains "sqlmap"

# TLS
tls.handshake.type == 1
tls.handshake.extensions_server_name
tls.handshake.type == 1 && tcp.port == 443

# DHCP
dhcp.option.dhcp == 1      (Discover)
dhcp.option.dhcp == 2      (Offer)
dhcp.option.dhcp == 5      (ACK)

# TCP
tcp.flags.syn == 1 && tcp.flags.ack == 0
tcp.flags.reset == 1
tcp.analysis.retransmission
tcp.analysis.zero_window

# ARP / ICMP
arp.opcode == 2
arp.duplicate-address-detected
icmp.type == 8
icmp && data.len > 100

# FTP / SMB
ftp.request.command == "RETR"
ftp.response.code == 530
smb2.cmd == 3
smb2.filename contains "exe"

# Malicious traffic
tcp.port == 4444
tcp.payload contains "mining.submit"
http.user_agent contains "Python"
```

## Useful Wireshark actions

- Follow a stream: right click a packet, Follow, TCP / HTTP Stream
- Extract files: File, Export Objects, HTTP
- Triage a big capture: Statistics, Protocol Hierarchy, then Statistics, Conversations
- Problems list: Analyze, Expert Information
- Shortcuts: Ctrl+F find, Ctrl+G go to packet, Ctrl+/ jump to filter bar

## Mistakes I keep making

- Using `=` instead of `==` in filters
- Typos in field names (`rcode`, `UNION`, `dhcp`)
- Forgetting direction: `ip.src` or `ip.dst` is often better than `ip.addr`
- Mixing up hashing and encoding (Base64 can be decoded, a hash cannot)
- Getting the sender of a packet wrong (the SMB reset in the capstone)
- Not knowing the switch-level defences (DHCP snooping)

