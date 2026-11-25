# Day 5 — Linux Internals and Security for SOC

## Overview

Day 5 focuses on Linux artifacts and command-line techniques that help a SOC analyst inspect a host, investigate suspicious activity and identify possible persistence or privilege escalation.

The main topics are:

1. Linux filesystem hierarchy and forensic paths
2. File permissions, SUID/SGID and privilege-escalation risks
3. Process and socket inspection
4. Command-line log analysis
5. Bash scripts for basic security auditing

The commands are intended for authorized systems and lab environments. Some commands require root privileges to show complete results.

---

## 1. Linux Filesystem Hierarchy and Forensic Artifacts

Linux uses a hierarchical filesystem that begins at the root directory `/`. Important security evidence can be found in configuration directories, log directories, temporary filesystems and process information.

| Path | Purpose | SOC / forensic relevance |
|---|---|---|
| `/var/log/` | System and application logs | Authentication, service and web-server activity |
| `/etc/` | System-wide configuration | User, service, SSH, sudo and scheduled-task configuration |
| `/etc/passwd` | User account information | Account inventory; does not normally contain password hashes |
| `/etc/shadow` | Password-hash and aging information | Sensitive authentication data; access should be restricted |
| `/etc/sudoers` and `/etc/sudoers.d/` | Sudo authorization rules | Investigate unexpected privilege grants |
| `/tmp/` | Temporary files | Possible staging location for suspicious files |
| `/dev/shm/` | Shared-memory filesystem, commonly tmpfs | May contain temporary or suspicious executable content |
| `/proc/` | Kernel-provided process and system information | Process metadata, command lines, file descriptors and executable links |
| `/home/<user>/.ssh/` | User SSH configuration and keys | Check for unauthorized `authorized_keys` changes |
| `/var/spool/cron/` | User cron spool on some distributions | Investigate scheduled-task persistence |
| `/etc/crontab`, `/etc/cron.d/` | System-wide scheduled tasks | Check for unexpected recurring commands |
| `/etc/systemd/system/` | Systemd unit configuration | Investigate suspicious or unauthorized services |

### 1.1 Authentication and system logs

Common locations vary by distribution:

- Debian/Ubuntu: `/var/log/auth.log`
- RHEL-family systems: `/var/log/secure`
- General system messages may appear in `/var/log/syslog` or `/var/log/messages`.
- Modern systems may also use the systemd journal.

Useful commands:

```bash
# Show recent authentication log entries (Debian/Ubuntu)
sudo tail -n 50 /var/log/auth.log

# Follow new log entries
sudo tail -f /var/log/auth.log

# Search for failed password events
sudo grep -i "Failed password" /var/log/auth.log

# Search for sudo command records
sudo grep -E "sudo:.*COMMAND" /var/log/auth.log
```

If a file does not exist, check the distribution and logging configuration rather than assuming that logging is disabled.

### 1.2 Inspecting SSH persistence locations

```bash
# List SSH files for a user
ls -la /home/<username>/.ssh/

# Inspect authorized keys (read only)
sudo cat /home/<username>/.ssh/authorized_keys

# Check root's SSH configuration
sudo ls -la /root/.ssh/
```

Investigate unexpected keys, unfamiliar comments, modified timestamps and changes that do not match approved administration activity. Preserve evidence before making changes.

---

## 2. Linux Permissions, SUID and Privilege Escalation

### 2.1 Basic permissions

Linux file permissions are assigned to three classes:

- **User (u):** The file owner
- **Group (g):** Members of the file's group
- **Others (o):** Everyone else

Each class can have read, write and execute permissions:

| Permission | Symbol | Numeric value |
|---|---|---:|
| Read | `r` | 4 |
| Write | `w` | 2 |
| Execute | `x` | 1 |

The values are added for each class.

Examples:

```bash
chmod 755 script.sh
chmod 644 notes.txt
```

- `755` = owner `rwx`, group `r-x`, others `r-x`
- `644` = owner `rw-`, group `r--`, others `r--`

Inspect permissions and ownership:

```bash
ls -l /path/to/file
stat /path/to/file
```

### 2.2 Special permission bits

Linux has special permission bits in addition to the ordinary read/write/execute bits.

| Special bit | Numeric prefix | Purpose |
|---|---:|---|
| SUID | 4 | Executable runs with the file owner's effective user ID |
| SGID | 2 | Executable runs with the file group's effective group ID; on directories, new entries commonly inherit the directory group |
| Sticky bit | 1 | On shared directories, restricts deletion/renaming of entries to the file owner, directory owner or root |

### 2.3 SUID

When an executable has SUID enabled, it runs with the effective user ID of the file owner. A legitimate example is `passwd`, which needs controlled access to update authentication information.

Example permission:

```text
-rwsr-xr-x
```

The `s` in the owner's execute position indicates SUID is set. The numeric mode is commonly `4755`.

Find SUID files:

```bash
find / -type f -perm -4000 -print 2>/dev/null
```

Not every SUID binary is malicious. The analyst should compare results with the operating system's expected baseline, package ownership and approved software inventory.

### 2.4 Why unusual SUID files matter

A dangerous or incorrectly configured SUID executable can allow a user to perform actions with privileges they should not have. Some general-purpose programs can be abused when configured with elevated privileges.

For defensive investigation:

1. Identify the binary and its owner.
2. Record its permissions and file metadata.
3. Determine which package installed it.
4. Compare it with a known-good host or package baseline.
5. Check recent changes and execution evidence.
6. Remove or correct the configuration only through an approved response process.

GTFOBins is a reference that documents how Unix binaries may be abused in particular configurations. Use it to understand risk and validate defensive findings in an isolated lab; do not assume that the presence of a listed binary is itself proof of compromise.

### 2.5 Sticky bit

The `/tmp` directory commonly uses mode `1777`:

```text
drwxrwxrwt
```

The sticky bit helps prevent one ordinary user from deleting or renaming another user's files in a shared writable directory.

Compare:

- `777`: Everyone has write permission; there is no sticky-bit restriction on deleting other users' entries.
- `1777`: Everyone can create entries, but the sticky bit restricts who may delete or rename an entry.

Check:

```bash
ls -ld /tmp
```

---

## 3. Process and Network Socket Inspection

A SOC analyst needs to connect a process to its executable, user, parent process, open files and network connections.

### 3.1 Process inspection with `ps`

```bash
# Show processes in a parent-child tree
ps aux --forest

# Show selected fields, sorted by CPU use
ps -eo pid,ppid,user,cmd,%mem,%cpu --sort=-%cpu | head -n 10
```

Important fields:

- `PID`: Process ID
- `PPID`: Parent process ID
- `USER`: Account running the process
- `CMD`: Command line
- `%CPU` and `%MEM`: Resource usage

A process name alone is not enough to establish whether a process is legitimate. Check its executable path, parent, user, command line, start time and expected role.

### 3.2 The `/proc` filesystem

Linux exposes process details under `/proc/<PID>/`.

For a process with PID `4125`:

```bash
# Inspect the executable link
ls -l /proc/4125/exe

# Resolve the executable path
readlink /proc/4125/exe

# Inspect the command line
tr '\0' ' ' < /proc/4125/cmdline
```

The `/proc/<PID>/exe` symbolic link points to the executable associated with the running process. If the underlying file has been deleted while the process is still running, the link may show a `(deleted)` suffix.

This can be useful during investigations, but access may be restricted and process details can change while the system is running.

### 3.3 Network sockets with `ss`

```bash
# Show TCP/UDP listening sockets and process details
sudo ss -tulpn

# Show established TCP connections
sudo ss -tnp state established
```

Common states:

| State | Meaning |
|---|---|
| `LISTEN` | A service is waiting for incoming connections |
| `ESTAB` | A TCP connection has been established |
| `TIME-WAIT` | A connection has closed and is waiting through the TCP time-wait period |

A listening port is not automatically malicious. Compare it with the host's role and approved service inventory.

### 3.4 Open files and sockets with `lsof`

```bash
# Show processes associated with TCP/UDP port 4444
sudo lsof -i :4444

# Show files and sockets opened by a process
sudo lsof -p <PID>

# Show network-related open files
sudo lsof -i
```

For an unfamiliar connection, record the process name, PID, user, local endpoint, remote endpoint and connection state. Do not terminate a process solely because it uses an unusual port; validate the evidence first.

---

## 4. SOC Log Analysis with Command-Line Tools

Linux command-line utilities can filter and summarize large log files without requiring a full SIEM.

Core tools:

| Tool | Main purpose |
|---|---|
| `grep` | Select lines matching a pattern |
| `awk` | Extract and process fields |
| `sed` | Transform text streams |
| `cut` | Extract delimited columns |
| `sort` | Sort lines |
| `uniq` | Collapse adjacent duplicate lines and optionally count them |
| `head` | Display the first lines |
| `tail` | Display the last lines |

### 4.1 Find frequent SSH failed-login source IPs

Example for a Debian/Ubuntu-style `auth.log`:

```bash
grep "Failed password" /var/log/auth.log \
  | awk '{print $(NF-3)}' \
  | sort \
  | uniq -c \
  | sort -nr \
  | head -n 5
```

Pipeline explanation:

1. `grep "Failed password"` selects failed-password records.
2. `awk '{print $(NF-3)}'` extracts the field expected to contain the source IP in the common log format shown in the lab.
3. `sort` places identical IP addresses together.
4. `uniq -c` counts adjacent repeated values.
5. `sort -nr` sorts counts numerically, highest first.
6. `head -n 5` displays the five most frequent results.

**Log-format warning:** Authentication log formats differ. Always inspect sample lines and validate the field position before using a parser in production.

### 4.2 Find the top 10 client IPs generating HTTP 404 responses

For a common Nginx combined access-log format where the client IP is the first field:

```bash
grep " 404 " /var/log/nginx/access.log \
  | awk '{print $1}' \
  | sort \
  | uniq -c \
  | sort -nr \
  | head -n 10
```

Repeated 404 responses can be generated by normal browsing, broken links, vulnerability scanners or automated content discovery. Treat the output as an investigative lead, not proof of an attack.

### 4.3 Useful `sed` and `cut` examples

```bash
# Print lines containing a term (grep is often simpler for this)
grep -i "error" /var/log/syslog

# Extract the first colon-separated field
cut -d: -f1 /etc/passwd

# Replace a string in displayed output (does not modify the file)
sed 's/Failed password/SSH authentication failure/g' /var/log/auth.log
```

---

## 5. Bash Security-Audit Scripts

The following scripts are simple defensive learning tools. Review them, test them on sample data and adapt them to your distribution before using them operationally.

### 5.1 `log-analyzer.sh` — SSH failed-login summary

Purpose: Read a Debian/Ubuntu-style authentication log, count failed-password events by source IP and report IPs that meet a configurable threshold.

```bash
#!/usr/bin/env bash

# SSH failed-login summary for a Debian/Ubuntu-style auth.log.
# Usage: ./log-analyzer.sh [log_file] [threshold]

LOG_FILE="${1:-/var/log/auth.log}"
THRESHOLD="${2:-5}"

if [[ ! -f "$LOG_FILE" ]]; then
    echo "[ERROR] Log file not found: $LOG_FILE" >&2
    exit 1
fi

if ! [[ "$THRESHOLD" =~ ^[0-9]+$ ]] || (( THRESHOLD < 1 )); then
    echo "[ERROR] Threshold must be a positive integer." >&2
    exit 1
fi

echo "SSH FAILED-LOGIN SUMMARY"
echo "Log file: $LOG_FILE"
echo "Alert threshold: $THRESHOLD"
echo

grep "Failed password" "$LOG_FILE" \
    | awk '{print $(NF-3)}' \
    | sort \
    | uniq -c \
    | sort -nr \
    | while read -r count ip; do
        if (( count >= THRESHOLD )); then
            printf "ALERT: %s attempts from %s\n" "$count" "$ip"
        fi
    done
```

Run:

```bash
chmod +x log-analyzer.sh
./log-analyzer.sh
./log-analyzer.sh ./sample-auth.log 3
```

Notes:

- The default log path is distribution-specific.
- The `awk` field selection assumes the common log format used in this exercise.
- For production use, validate parsing against real samples and handle rotated/compressed logs.
- A high failed-login count may indicate brute force, password spraying or simply a misconfigured client.

### 5.2 `suid-finder.sh` — SUID inventory and review

Purpose: List SUID files and flag names that are not in a small example allowlist. This is a starting point for review, not a definitive malware detector.

```bash
#!/usr/bin/env bash

OUTPUT_FILE="${1:-./suid-audit-$(date +%F).txt}"

KNOWN_GOOD=(
    passwd sudo su chfn chsh gpasswd newgrp
    mount umount pkexec
)

is_known_name() {
    local candidate="$1"
    local item

    for item in "${KNOWN_GOOD[@]}"; do
        [[ "$candidate" == "$item" ]] && return 0
    done

    return 1
}

echo "SUID inventory started: $(date)"
echo "Output file: $OUTPUT_FILE"
echo

find / -type f -perm -4000 -print 2>/dev/null |
while IFS= read -r binary; do
    name="$(basename "$binary")"

    if ! is_known_name "$name"; then
        permissions="$(stat -c '%a' -- "$binary" 2>/dev/null)"
        owner="$(stat -c '%U' -- "$binary" 2>/dev/null)"

        printf '[REVIEW] %s | permissions=%s | owner=%s\n' \
            "$binary" "$permissions" "$owner" \
            | tee -a "$OUTPUT_FILE"
    fi
done

echo
echo "SUID inventory complete."
echo "Review flagged entries against the host baseline and installed packages."
```

Run:

```bash
chmod +x suid-finder.sh
sudo ./suid-finder.sh
```

Notes:

- The allowlist is intentionally small and is not universal.
- Different distributions and installed packages legitimately have different SUID binaries.
- A filename-based allowlist can produce false positives and false negatives.
- Validate package ownership, file hashes, permissions and change history before deciding that a file is malicious.

---

## 6. Day 5 Investigation Workflow

When investigating a suspicious Linux host, use a repeatable workflow:

1. **Establish context:** Hostname, distribution, time, timezone, logged-in users and incident time window.
2. **Review authentication:** Failed logins, successful logins, sudo activity and SSH key changes.
3. **Inspect processes:** PID, PPID, user, executable path, command line and start time.
4. **Inspect network activity:** Listening ports, established connections and process-to-socket mapping.
5. **Check persistence:** Cron jobs, systemd services, SSH authorized keys and startup configuration.
6. **Review permissions:** Unexpected SUID/SGID files, writable directories and ownership changes.
7. **Preserve evidence:** Save relevant logs and command output with timestamps.
8. **Contain carefully:** Follow the organization's response procedure; avoid destroying volatile evidence or disrupting business services unnecessarily.

## 7. Day 5 Review Checklist

- [ ] Identify the purpose of `/var/log`, `/etc`, `/tmp`, `/dev/shm` and `/proc`.
- [ ] Locate authentication logs on common Linux distributions.
- [ ] Explain Linux user, group and other permissions.
- [ ] Convert permission values such as `755`, `644` and `4755`.
- [ ] Explain SUID, SGID and the sticky bit.
- [ ] Find SUID files and explain why findings require baseline comparison.
- [ ] Inspect a process tree with `ps`.
- [ ] Resolve a process executable through `/proc/<PID>/exe`.
- [ ] Distinguish listening sockets from established connections.
- [ ] Map a port to a process with `lsof`.
- [ ] Build a log-analysis pipeline with `grep`, `awk`, `sort` and `uniq`.
- [ ] Explain the assumptions and limitations in the Bash scripts.

## Key Takeaway

Linux SOC work is not just about running commands. It is about correlating users, processes, files, permissions, network connections and logs into a defensible explanation of what happened on a host.
