# Capstone Project - Operation Midnight Invoice

Full incident investigation of a corporate breach, using everything from sections 1 to 11.

Case: Company XYZ, ticket 9942, severity P1 (critical)

## Scenario

At 02:45 AM the SIEM flagged a finance workstation for outbound malicious traffic, internal scanning and exfiltration signs. A network tap had captured about 50,000 packets. My job was to rebuild the attack chain, extract indicators and write the response plan.

| Item | Value |
|------|-------|
| Compromised host | 10.0.2.15 (FIN-PC-01, finance workstation) |
| Internal server | 10.0.2.50 (file and database server) |
| Gateway | 10.0.2.1 |
| Attacker server | 185.220.101.5 |
| Malicious domain | update-check-cdn.com |

## Short summary

At 02:30 AM the finance workstation downloaded a Windows executable named `invoice_update.exe` over plain HTTP from `update-check-cdn.com`. Within seconds it opened a reverse shell to the attacker on port 4444. The attacker ran `whoami` and `net view /all`, probed SMB on the file server (closed), then logged in over FTP with the admin account and requested `Q3_Financial_Salaries.xlsx`. About a minute later, data started leaving through DNS TXT queries to a subdomain of `update-check-cdn.com`. The whole chain from download to exfiltration took about two minutes.

## Attack timeline

| Time | Packets | What happened |
|------|---------|---------------|
| 02:30:01 | 1-2 | 10.0.2.15 resolves update-check-cdn.com to 185.220.101.5 |
| 02:30:02 | 3-4 | GET /payload/invoice_update.exe, answered 200 with content type `application/x-msdownload`, body starts with `4D 5A` (MZ) |
| 02:30:15 | 5-7 | TCP handshake from the victim to 185.220.101.5 port 4444: reverse shell established |
| 02:30:18 | 8-9 | Attacker runs `whoami`, reply `xyz_corp\finance_user` |
| 02:30:25 | 10 | Attacker runs `net view /all` (network discovery) |
| 02:31:00 | 11-12 | SYN to 10.0.2.50 port 445, server answers RST, ACK (SMB closed or blocked) |
| 02:31:05 | 13-16 | Attacker switches to FTP, USER admin, PASS `AdminPayroll2025!`, reply 230 (logged in) |
| 02:31:10 | 17 | RETR Q3_Financial_Salaries.xlsx |
| 02:32:00 | 18-21 | DNS TXT queries with Base64 subdomains under exfil.update-check-cdn.com, answered "ACK" |

## My investigation answers

These are my answers as I wrote them in the exercise, in simple English. Where I was wrong or incomplete, the correction is under my answer.

### Phase 1 - Initial access and malware delivery

- Patient zero machine IP address is 10.0.2.15.
- The attacker downloaded the malware from the site path `payload/invoice_update.exe` (domain `update-check-cdn.com`).
- The file in the 4th packet starts with `4D 5A`, which is a Windows executable. This is a red flag.

### Phase 2 - Command and control

- The patient zero port is 49152 and the C2 server port is 4444. This is a red flag.
- C2 server IP is 185.220.101.5.
- In the 8th packet the attacker runs a command, `whoami`.
- In the 9th packet the attacker enters the finance folder of the system.

Correction: packet 9 is the victim's reply to `whoami`, which is `xyz_corp\finance_user`. It shows which account the attacker is running as (the finance user). The attacker does not enter a folder here. The next real command is `net view /all` in packet 10, which lists the network.

### Phase 3 - Internal recon and lateral movement

- In the 11th packet the patient zero machine connects to the internal server on port 445.
- Then it requests a login with USER `admin` and PASS `AdminPayroll2025`, and the 230 code shows the login was successful.
- Then it uses RETR to get the Q3 financial salaries file.
- In packets 11 and 12 the attacker only checks whether the port is open, and sends RST so it is not written in the application logs.
- From the internal server the attacker downloads the financial salaries file.

Corrections:

- Port 445 (SMB) and the FTP login are two different steps. Packets 11 and 12 are the SMB attempt. The FTP login is packets 13 to 16, and it is on the FTP port (21), not 445.
- The password is `AdminPayroll2025!` (with the exclamation mark).
- In packet 12 the RST, ACK was sent by the server 10.0.2.50, not by the attacker. Port 445 was closed or blocked, so the connection was refused. The "RST to avoid logs" idea is the SYN scan technique from section 7, but it needs a SYN-ACK first, and there was none here.

### Phase 4 - Data exfiltration

- The attacker used DNS to send the stolen data out, and then sent another set of TXT data with DNS again.
- The subdomains are Base64 encoded.

Addition (decoded with `base64 -d`):

- `T25lVGhpcmRQYXNzd29yZDEyMw==` decodes to `OneThirdPassword123`
- `Q29uZmlkZW50aWFsX1NhbGFyaWVzX0RhdGE=` decodes to `Confidential_Salaries_Data`

Decoding the strings was the part I missed at first. The record type is TXT, over DNS on UDP.

### Attack chain in my words

First the attacker gets initial access to the system, then the malware is installed, then the C2 server connection is made, then the attacker gets access to files, then moves to the internal server, then takes the important files, and then sends the data out.

### Phase 5 - Threat intel and MITRE ATT&CK

My three indicators:

1. Malware from a red flag site (`update-check-cdn.com`)
2. Malicious IP 185.220.101.5
3. Stolen file `Q3_Financial_Salaries.xlsx`

Full indicator list after review:

| Type | Value |
|------|-------|
| IP address | 185.220.101.5 |
| Domain | update-check-cdn.com |
| Subdomain used for exfiltration | exfil.update-check-cdn.com |
| File (malware) | invoice_update.exe |
| File (stolen) | Q3_Financial_Salaries.xlsx |
| Port | TCP 4444 |
| Compromised account | FTP admin (password crossed the network in plain text) |

MITRE ATT&CK mapping:

| ID | Technique | Where |
|----|-----------|-------|
| T1204.002 | User Execution: Malicious File | invoice_update.exe |
| T1095 | Non-Application Layer Protocol | Reverse shell on port 4444 |
| T1071.004 | Application Layer Protocol: DNS | DNS TXT traffic |

Techniques I would add after review: T1105 Ingress Tool Transfer (download of the exe), T1135 Network Share Discovery (`net view /all`), T1078 Valid Accounts (FTP admin login) and T1048.003 Exfiltration Over Alternative Protocol (data sent inside DNS queries, a better fit for the exfiltration step than T1071.004).

### Phase 6 - Containment

My plan:

1. Block the malicious IP.
2. Try to kill the malware.
3. Block the ports the malware uses to reach the C2 server.
4. Isolate the PC immediately.

Note: isolating the PC should come first, because blocking and cleaning take time and the attacker still has a live shell. After that I would also: block the domain `update-check-cdn.com`, reset the FTP admin password and check the FTP server logs, check 10.0.2.50 for other activity, search other hosts for the same IP, domain and file, move FTP to SFTP or disable it, and keep the host and the pcap for forensics before reimaging.

## Gaps in the evidence

- The excerpt shows the RETR request but not the end of the transfer (code 226) or the data channel, so I cannot prove the file was fully downloaded without the full pcap.
- The capture does not show how the attacker got the FTP password. It may have been in the full capture, on the host, or guessed. This needs checking.
- How the user was sent to download the file (phishing email, link) is not in this capture. Email and proxy logs are needed.

## Wireshark steps I would use on the full 50,000 packet capture

```
Statistics, Protocol Hierarchy          (is DNS or another protocol too large?)
Statistics, Conversations, IPv4         (top talkers, who sent the most bytes?)
ip.addr == 10.0.2.15                    (everything from the patient zero host)
http.request.uri contains ".exe"        (find the malware download)
File, Export Objects, HTTP              (save invoice_update.exe for hashing)
tcp.port == 4444                        (reverse shell, then Follow TCP Stream)
ftp.request.command == "PASS"           (plain text credentials)
ftp.request.command == "RETR"           (files taken)
dns.qry.type == 16                      (TXT queries, possible tunneling)
dns.qry.name contains "exfil"           (exfiltration domain)
```

## Score

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                   CAPSTONE FINAL SCORE: 80% (GRADE: B+)                      ║
╠══════════════════════════════════════════════════════════════════════════════╣
║                                                                              ║
║  Phase 1 (Initial Access):       █████████░ 90%                              ║
║  Phase 2 (C2 Establishment):     ████████░░ 85%                              ║
║  Phase 3 (Lateral Movement):     ███████░░░ 75%                              ║
║  Phase 4 (Exfiltration):         ██████░░░░ 65%                              ║
║  Phase 5 (Threat Intel & MITRE): ████████░░ 80%                              ║
║  Phase 6 (Incident Response):    ████████░░ 85%                              ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

Strongest: spotting patient zero, the malware download and the C2 channel, and writing a practical containment plan.
Weakest: decoding the Base64 myself, mixing up the SMB and FTP steps, and being exact about who sent a packet (the SMB reset).

## What I learned

- A capture tells a story: DNS lookup, download, reverse shell, recon, lateral move, exfiltration. Each step sets up the next.
- The same attacker used HTTP, raw TCP, FTP and DNS in one incident, so one filter is never enough.
- Always say which side sent a packet. Direction changes the meaning.
- Decode encoded data and write down what it contains, because that is the evidence.