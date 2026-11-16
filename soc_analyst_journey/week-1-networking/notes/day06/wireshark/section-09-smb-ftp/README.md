# Section 9 - SMB and FTP Analysis

## Goal

Spot credential theft, brute force and lateral movement over FTP and SMB.

## Why they matter

- FTP sends the username and password in plain text, so anyone sniffing can read them.
- SMB (port 445) is how ransomware and attackers move from one Windows machine to another. Admin shares such as `C$`, `ADMIN$` and `IPC$` are common targets.
- EternalBlue (MS17-010) is an old SMBv1 exploit that gave SYSTEM access without a password. WannaCry and NotPetya used it.

## FTP commands and codes

| Item | Meaning |
|------|---------|
| USER / PASS | Login, sent in plain text |
| RETR | Download a file |
| STOR | Upload a file |
| 230 | Login successful |
| 530 | Login failed |

Control is on port 21, data on port 20 (or a negotiated port in passive mode).

## SMB shares to watch

| Share | What it is |
|-------|------------|
| C$ | Whole C: drive, admin only |
| ADMIN$ | The Windows folder, used for lateral movement |
| IPC$ | Inter-process communication, used for recon and RPC |

## Filters

```
ftp
ftp.request.command == "USER"
ftp.request.command == "PASS"
ftp.request.command == "RETR"
ftp.response.code == 530
smb || smb2
smb2.cmd == 3
smb2.cmd == 5
smb2.filename contains "exe"
```

## Sample: plain text FTP login

```
USER hr_admin
PASS Payroll2025!Secret
230 User logged in, proceed.
```

Follow, TCP Stream shows the whole session in readable text.

## Practice 1 (medium): FTP login attempts on 10.0.0.20

Three logins for `root` from 192.168.1.99: 123456 (530), admin (530), Winter2024! (230). Then `RETR customer_db.sql`.

1. Attack: FTP brute force. Correct.
2. Success: yes, password `Winter2024!` with response code 230. Correct.
3. Packet 10: the attacker tried to download the customer database backup. Correct.
4. Filter: `ftp.request.command=="RETR"`. Correct.

## Practice 2 (hard): SMB2 from 10.0.1.15 to 10.0.1.50

Session setup as `CorporateDomain\Administrator`, tree connect to `\\10.0.1.50\ADMIN$`, create and write `psexecsvc.exe` (45056 bytes).

1. Technique: PsExec remote execution over SMB (lateral movement). I was not asked to name the tool in my own answer, this one is from the walkthrough.
2. Share: `ADMIN$`. It points at `C:\Windows`. With write access an attacker can run a service as SYSTEM.
3. Packets 5 to 7: the attacker created and wrote an executable (`psexecsvc.exe`) on the target. My answer: an exe file that may act as malware. Correct, it is the PsExec service binary.
4. Filter: `smb2.cmd==3`. Correct.
5. Containment: isolate both 10.0.1.15 (source) and 10.0.1.50 (target). My answer: disconnect both systems. Correct. Next steps would be to reset the Administrator credentials, check other hosts the account touched, and hunt for the same activity elsewhere.

## What I learned

- Failed logins followed by a success, then a file download, is a complete brute force story.
- A tree connect to `ADMIN$` followed by an exe being written is PsExec style lateral movement.
- The account used (here a domain Administrator) tells me how far the attacker may already have got.

## Still to practise

- NTLM authentication in SMB captures
- EternalBlue patterns in SMBv1 traffic
