# Section 7 - TCP Deep Dive

## Goal

Read TCP flags, handshakes and error conditions, and tell the difference between a security event and a performance problem.

## Why it matters

- Detect port scans and SYN floods
- Show whether a firewall or the server caused a failure
- Spot killed connections from RST packets
- Reconstruct attacker sessions

## Flags

| Flag | Meaning |
|------|---------|
| SYN | Start a connection |
| ACK | Acknowledge received data |
| FIN | Close politely |
| RST | Abort the connection immediately |
| PSH | Push data to the application now |
| URG | Urgent data |

## Handshake

```
Client -> Server : SYN       (Seq 0)
Server -> Client : SYN, ACK  (Seq 0, Ack 1)
Client -> Server : ACK       (Seq 1, Ack 1)
```

Wireshark shows relative sequence numbers by default.

## Port states from the handshake

| Pattern | Meaning |
|---------|---------|
| SYN, SYN-ACK, ACK | Open, connected |
| SYN, RST-ACK | Closed (host alive, nothing listening) |
| SYN, no reply | Filtered (firewall dropping) |

## TCP problems in Wireshark

- Retransmission: sender did not get an ACK and resent
- Dup ACK: receiver is missing an earlier packet
- Out-of-order: packets arrived in a different order
- Zero window: receiver buffer is full, sender must wait

## Filters

```
tcp.flags.syn == 1 && tcp.flags.ack == 0
tcp.flags.syn == 1 && tcp.flags.ack == 1
tcp.flags.reset == 1
tcp.flags.fin == 1
tcp.analysis.retransmission
tcp.analysis.zero_window
tcp.window_size_value == 0
tcp.analysis.flags
```

## Practice 1 (medium): scan from 192.168.1.200 against 10.0.0.50

- Port 21: SYN, RST-ACK
- Port 22: SYN, SYN-ACK, then RST from the scanner
- Port 23: SYN, no answer

1. Port states: 21 closed, 22 open, 23 filtered. My answers: 21 "killed with RST" (closed), 22 "almost connected" (open), 23 "timeout, firewall blocking" (filtered). Right idea, I need to use the standard words.
2. Why the scanner sent RST on port 22: it is an Nmap SYN scan (`nmap -sS`), also called half-open or stealth scan. The SYN-ACK already proves the port is open, so the scanner resets instead of finishing the handshake. This avoids many application logs because the connection never fully completes. I did not know this one.
3. Filter. My answer: `tcp.flags.syn==0 && tcp.flags.syn==1 !ack`. That contradicts itself (syn cannot be both 0 and 1). Correct:

```
tcp.flags.syn == 1 && tcp.flags.ack == 0
```

## Practice 2 (hard): database connection drops at 2 AM

The database server (10.0.0.100) advertises window 1024, then window 0 twice, then sends RST 12 seconds later.

1. Root cause: the database server's receive buffer was full, so it is a server resource problem, not the network or firewall. Correct.
2. Window size 0: the receiver tells the sender to stop sending until space frees up (TCP flow control). Correct.
3. RST after 12 seconds: the server stayed full too long, so the connection timed out and was reset. Correct.
4. Filter. My answer: `tcp.flags.tc_zero_window`, which is not a real field. Correct:

```
tcp.analysis.zero_window
```

## What I learned

- Open, closed and filtered can be read straight from the first two packets.
- Zero window points at the receiver, not the network.
- A half-open scan is a SYN, SYN-ACK, RST pattern.

## Still to practise

- Nmap scan types and how each looks in a capture
- Checking TTL and window values to spot injected RST packets
