# Section 8 - ICMP and ARP Analysis

## Goal

Detect ARP poisoning and ICMP tunneling, two attacks that live below the TCP and UDP layer.

## Why they matter

ARP and ICMP have no authentication. Attackers use them for:

- ARP poisoning: tell victims that the gateway IP belongs to the attacker's MAC, giving a man-in-the-middle position
- ICMP tunneling: hide files or commands inside ping payloads to get past firewalls that allow ping
- Ping sweeps: find live hosts in a subnet

## ARP

- Opcode 1 request (broadcast): "Who has 192.168.1.1?"
- Opcode 2 reply: "192.168.1.1 is at aa:bb:cc:dd:ee:ff"
- Gratuitous ARP: a reply nobody asked for. Normal for failover (VRRP/HSRP), malicious in ARP spoofing.

## ICMP types

| Type | Name | Note |
|------|------|------|
| 8 | Echo request | Ping, or a ping sweep |
| 0 | Echo reply | Ping answer |
| 3 | Destination unreachable | Host or port down, or blocked |
| 11 | Time exceeded | Traceroute |

A normal Windows ping carries 32 bytes of `abcdefgh...`. Linux uses 56 bytes. An echo request with hundreds or thousands of bytes of encoded data is a tunneling red flag.

## Filters

```
arp
arp.opcode == 1
arp.opcode == 2
arp.duplicate-address-detected
icmp
icmp.type == 8
icmp.type == 0
icmp && data.len > 100
```

## Practice 1 (medium): SSL warnings and duplicate IP-to-MAC alert

Many unsolicited ARP replies, all saying `10.0.0.1 is at 00:0c:29:88:99:aa`. The real router MAC is `aa:bb:cc:00:00:01`.

1. Attack: ARP poisoning / spoofing, leading to man-in-the-middle.
2. Attacker MAC: `00:0c:29:88:99:aa` (the 00:0c:29 prefix is VMware, so likely a virtual machine). It is pretending to be 10.0.0.1, the gateway.
3. Goal: pull the victim's traffic through the attacker to read passwords and cookies. The SSL warnings fit this, because the attacker's fake certificates are not trusted.
4. Filter. My answer: `arp.opcode==2`. Correct.

I only gave the filter in my own answer for this scenario. The rest I am recording from the walkthrough, so I should re-do it myself without looking.

## Practice 2 (hard): high bandwidth on workstation 172.16.8.20

ICMP echo requests of 1200 bytes to 203.0.113.50. The data starts with `4D5A9000...` in one packet and `504B0304...` in another.

1. Technique: ICMP tunneling used for data exfiltration or file transfer.
2. File types from magic bytes: `4D 5A` ("MZ") is a Windows executable. `50 4B 03 04` ("PK") is a ZIP or Office file. `25 50 44 46` ("%PDF") is a PDF.
3. Why firewalls missed it: they filter by TCP/UDP port, ICMP has no ports, and ping is usually allowed. Only deep packet inspection or payload size checks would catch it.
4. Filter:

```
icmp && data.len > 100
```

## What I learned

- Repeated unsolicited ARP replies for the gateway IP is poisoning.
- Compare the MAC to the real one, and check the vendor prefix.
- Ping payload size and content tell me whether it is a normal ping.
- Magic bytes (MZ, PK, %PDF) tell me the file type without the file name.

## Still to practise

- ICMP tunneling and magic byte recognition
- Telling gratuitous ARP from failover and from an attack
