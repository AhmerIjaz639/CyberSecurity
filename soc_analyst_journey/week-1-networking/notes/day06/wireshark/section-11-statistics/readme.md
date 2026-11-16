# Section 11 - Statistics and Expert Information

## Goal

Find the problem in a very large capture quickly, using Wireshark's built-in summaries before reading packets one by one.

## Why it matters

A 5 GB capture cannot be read packet by packet. The Statistics menu and Expert Information can point at the cause in under a minute, and then I go to those packets.

## The four tools

| Menu path | What it tells me |
|-----------|------------------|
| Statistics, Protocol Hierarchy | Share of each protocol. DNS or ICMP taking a large share is suspicious |
| Statistics, Conversations (IPv4 tab) | Top talkers. Sort by Bytes to find who sent the most data |
| Statistics, I/O Graphs | Traffic over time. Spikes can be DDoS or exfiltration, regular peaks can be beaconing |
| Analyze, Expert Information | Wireshark's own warnings: retransmissions, resets, malformed packets |

## Sample: finding the exfiltration host

In a 500 MB capture, I open Statistics, Conversations, IPv4, and sort by Bytes. One pair stands out: 10.0.0.45 to 185.220.101.5 with 480 MB of the 500 MB total. That is the host to investigate, found in seconds instead of reading 200,000 packets.

## Practice 1 (medium): Protocol Hierarchy of a branch office capture

UDP is 88.5 percent and DNS is 88.5 percent (44 MB of 50 MB). TCP is 11.5 percent.

I did not know this one. The answers:

1. Anomaly: DNS is normally a very small share of traffic, usually under a few percent. 88.5 percent is far too much.
2. Likely cause: DNS tunneling or data exfiltration, or a DGA malware flood.
3. Next step: Statistics, Conversations, IPv4 (or UDP), sort by bytes, and find which internal host is generating the DNS volume. Then filter that host's DNS queries and look at the names.

## Practice 2 (hard): Expert Information during an outage

| Group | Severity | Summary | Count |
|-------|----------|---------|-------|
| Sequence | Note | TCP Retransmission | 14,200 |
| Sequence | Warning | TCP Fast Retransmission | 8,500 |
| Response | Error | Connection establish request (SYN) failed | 3,100 |
| Warn | Warning | Suspected Zero-Window Probe | 420 |

I did not know this one. The answers:

1. Issues: heavy packet loss or congestion on the network (retransmissions), and servers that are down, blocked or too busy to accept connections (failed SYNs). The zero-window probes also show some receivers running out of buffer space.
2. 3,100 failed SYNs: clients send SYN and never get a SYN-ACK back, so the server is down, overloaded or a firewall is dropping the connections.
3. Filter:

```
tcp.analysis.retransmission
```

## What I learned

- Start with Protocol Hierarchy and Conversations, then read packets.
- A protocol with a share far above normal (DNS, ICMP) points to tunneling.
- Expert Information gives me a list of problems to chase, not the final answer.

## Still to practise

- Using Protocol Hierarchy, Conversations and Expert Information on a real capture
- Reading I/O Graphs for beaconing