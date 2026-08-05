# Sentinel Linux Security Audit

A lightweight Bash-based Linux security auditing tool that performs basic system security checks and generates a structured audit report. This project was built as part of my **Cyber Security Learning Journey – Module 2 (Linux Security & Bash Scripting)**.

## Overview

Sentinel Linux Security Audit automates common Linux security checks to help identify potential security risks and provide a quick overview of the system's security posture.

The script scans critical areas such as privileged users, network services, persistence mechanisms, SUID binaries, and insecure file permissions, then saves the findings into a readable report.

---

## Features

- Detects all users with **UID 0 (Root Privileges)**
- Lists all active **listening network ports**
- Checks suspicious **enabled system services**
- Displays scheduled **Cron jobs**
- Identifies **SUID binaries** (Potential Privilege Escalation vectors)
- Searches for **world-writable files** in `/tmp`
- Generates a complete security report automatically

---

## Project Structure

```text
Sentinel-Linux-Security-Audit/
│── sentinel_audit.sh
│── audit_report.txt      # Generated after execution
└── README.md
```

---

## Requirements

- Linux Distribution (Ubuntu, Kali Linux, Debian, etc.)
- Bash Shell
- Root or sudo privileges (recommended)

### Required Utilities

- awk
- ss
- systemctl
- find
- grep
- ls

---

## Installation

### Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/Sentinel-Linux-Security-Audit.git
cd Sentinel-Linux-Security-Audit
```

### Make the Script Executable

```bash
chmod +x sentinel_audit.sh
```

### Run the Script

```bash
sudo ./sentinel_audit.sh
```

---

## Sample Output

```text
==========================================
      SENTINEL LINUX SECURITY AUDIT
      Date: Wed Aug 5
==========================================

[!] Checking for UID 0 users...
root

[!] Checking for listening ports...
LISTEN ...

[!] Checking Cron Jobs...
...

[!] Top 10 SUID binaries...
/usr/bin/passwd
/usr/bin/sudo
...
```

The report is automatically saved as:

```text
audit_report.txt
```

---

## Security Checks Performed

### User Audit

- Detects accounts with UID 0 (root privileges).

### Network Audit

- Displays all listening TCP/UDP ports.

### Persistence Audit

- Checks enabled services for suspicious names.
- Lists cron jobs from system cron directories.

### Privilege Escalation Audit

- Enumerates the first 10 SUID binaries.

### File Permission Audit

- Searches for world-writable files in `/tmp`.

---

## Learning Outcomes

This project helped me practice:

- Bash Scripting
- Linux Commands
- User & Permission Management
- Linux Networking
- Systemd Services
- Cron Jobs
- SUID Enumeration
- Basic Security Auditing
- Report Generation

---

## Disclaimer

This project is created for **educational and defensive security purposes only**. Always obtain proper authorization before auditing any system.

---

## Cyber Security Bootcamp Progress

- Module 1 – Linux Fundamentals
- Module 2 – Linux Security & Bash Scripting
- Module 3 – Networking & Packet Analysis (Next)

---

## Author

**Ahmer Ijaz**

BS Computer Science Student  
Cyber Security Enthusiast | Linux Learner | Open Source Contributor

If you found this project useful, consider giving it a star.
```
