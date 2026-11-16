# Section 1 - Wireshark Fundamentals

## Goal

Understand what Wireshark is used for, how the window is laid out, and how to read a simple capture as a story instead of a list of lines.

## Where it is used

- SOC analyst: check if an alert is real or a false positive
- Incident response: rebuild what happened, for example at 3 AM
- Network engineer / DevOps: find why something is slow
- Malware analyst: see where malware calls home
- Forensics: keep packet evidence that can be shown to others

Examples I noted:

- A bank breach where the logs were deleted but the packet capture still showed the attacker session.
- A slow shopping site where most packets were retransmissions, which pointed to a faulty load balancer.
- A ransomware case where the capture showed the first infected machine and the C2 address.

## Why AI does not replace this

AI tools are good at triage and finding patterns. They give probabilities. A packet capture gives exact bytes, which is what is needed for proof, for new attacks that no model has seen, and for custom protocols. In practice the AI tool says where to look and I use Wireshark to confirm.

## Core terms

| Term | Meaning |
|------|---------|
| Packet / Frame | One unit of data on the network (frame includes the Ethernet layer) |
| pcap / pcapng | Saved capture file formats |
| Interface | The network card being captured |
| Promiscuous mode | Capture all packets seen on the link, not only mine |
| Dissector | Decoder that turns raw bytes into readable fields |
| Stream | One full conversation between two endpoints |
| Capture filter | Limits what is captured (set before capture) |
| Display filter | Hides packets after capture |

## The three panes

1. Packet list: one line per packet (time, source, destination, protocol, info)
2. Packet details: the selected packet split by layer. I spend most of my time here.
3. Packet bytes: raw hex and ASCII, the ground truth

## Shortcuts

```
Ctrl+E              start / stop capture
Ctrl+F              find packet
Ctrl+G              go to packet number
Ctrl+/              jump to filter bar
Ctrl+Alt+Shift+T    follow TCP stream
```

## Sample capture: Ahmed opens google.com

1. ARP request and reply to find the router MAC
2. DNS query and response for google.com
3. TCP SYN, SYN-ACK, ACK on port 443
4. TLS Client Hello, then Server Hello and certificate
5. Encrypted application data

Things to check in the DNS query: correct source IP, destination port 53, a normal domain, query type A (many TXT queries would be suspicious), and a matching transaction ID in the reply.

## Practice 1 (medium): "Internet is slow"

Capture summary: DNS reply after 2.3 seconds, SYN sent three times (packets 3, 4, 5), SYN-ACK only at 8.5 seconds, another retransmission at packet 9.

My answers:

1. Reason for slowness: packet loss. Packets 4, 5 and 9 are retransmissions, so the sender kept resending.
2. DNS took 2.345 seconds. Normal is under about 50 ms, so this is very slow.
3. The handshake took 6.1 seconds (SYN at 2.400, SYN-ACK at 8.500). Normally it is a few milliseconds.
4. Looks like a network problem (loss or congestion on the path) because the packets themselves are being dropped.
5. Performance issue, not a security issue. No strange IPs or behaviour. Escalate to the network team.

## Practice 2 (hard): HR workstation at 3 AM

Capture summary: DNS lookup of `update-service.net`, TLS to 185.220.101.42 with a self-signed certificate (CN Fake-CA), 120-byte packets every 60 seconds, then one 5,000,000 byte upload.

My answers:

1. Malicious. Red flags: odd hour for an HR machine, fake-looking domain, self-signed certificate, exact 60 second interval, sudden 5 MB upload.
2. Packet 7: a self-signed certificate from "Fake-CA". Real sites use certificates from trusted CAs.
3. Packets 8 to 12: C2 beaconing. A human does not send identical packets every 60 seconds.
4. Packet 13: data exfiltration. The jump from 120 bytes to 5 MB is the stolen data leaving.
5. Check the IP in VirusTotal, AbuseIPDB and Talos Intelligence.
6. MITRE ATT&CK: Command and Control (TA0011), Exfiltration Over C2 Channel (T1041).
7. Response: isolate the host, block the IP at the firewall, then scan the host and find the process that made the connection.

## What I learned

- Read the Time and Info columns together. The story is in the pattern, not in one packet.
- Fixed interval plus fixed size is the classic beaconing sign. This is a common interview question.
- Retransmissions and slow handshakes are a performance problem, not automatically an attack.

## Still to practise

- Correlating packets into a timeline without being told what to look for
