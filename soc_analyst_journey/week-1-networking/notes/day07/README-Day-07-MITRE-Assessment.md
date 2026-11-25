# Day 7 — MITRE ATT&CK and Week 1 Comprehensive Assessment

## Overview

Day 7 brings the week's technical topics together. It introduces a common language for describing adversary behaviour, compares threat-modelling frameworks and provides a comprehensive assessment across networking, Wireshark, Linux, Windows and Active Directory.

This README contains:

1. MITRE ATT&CK structure and Enterprise tactics
2. Cyber Kill Chain, Diamond Model and MITRE ATT&CK comparison
3. Week 1 assessment: 40 questions
4. Answer key with explanations and SOC context
5. A practical review and scoring guide

---

## 1. MITRE ATT&CK Framework

### 1.1 What is MITRE ATT&CK?

MITRE ATT&CK stands for **Adversarial Tactics, Techniques, and Common Knowledge**. It is a knowledge base that describes adversary behaviour observed in real-world activity and organizes that behaviour into a structured framework.

Security teams use ATT&CK to:

- Describe observed attacker behaviour consistently
- Map alerts and incidents to techniques
- Identify detection and visibility gaps
- Plan threat hunting
- Communicate incident findings
- Evaluate defensive coverage

ATT&CK is not a linear attack lifecycle. An adversary may skip, repeat or perform activities in a different order.

### 1.2 Tactics, techniques, sub-techniques and procedures

| Level | Main question | Explanation |
|---|---|---|
| Tactic | Why? | The adversary's tactical objective |
| Technique | How? | A method used to achieve that objective |
| Sub-technique | How specifically? | A more detailed form of a technique |
| Procedure | What did this actor actually do? | A concrete implementation observed in an operation |

Example:

```text
Tactic: Credential Access
    Technique: OS Credential Dumping
        Sub-technique: LSASS Memory
            Procedure: An actor uses a specific tool or process
            to access LSASS memory and obtain credential material.
```

A technique describes a behaviour category. A procedure describes an actual implementation by an adversary.

### 1.3 Enterprise tactics

The Enterprise ATT&CK matrix currently organizes adversary objectives into the following 14 tactics. The order below is a useful learning sequence, not a mandatory timeline.

| # | Tactic | Objective | Example behaviour |
|---:|---|---|---|
| 1 | Reconnaissance | Gather information about a target | Collect public information about an organization |
| 2 | Resource Development | Prepare resources for operations | Register domains or obtain infrastructure |
| 3 | Initial Access | Gain an initial foothold | Phishing or exploiting a public-facing application |
| 4 | Execution | Run malicious code | Execute commands or scripts |
| 5 | Persistence | Maintain access | Configure an autorun entry or service |
| 6 | Privilege Escalation | Obtain higher permissions | Exploit a misconfiguration or vulnerable component |
| 7 | Defense Evasion | Avoid detection | Obfuscate activity or impair security tools |
| 8 | Credential Access | Obtain credentials | Access credential stores or dump process memory |
| 9 | Discovery | Learn about the environment | Enumerate users, hosts or network resources |
| 10 | Lateral Movement | Move to other systems | Use remote services or valid accounts |
| 11 | Collection | Gather target information | Stage files or capture relevant data |
| 12 | Command and Control | Communicate with compromised systems | Beacon to external infrastructure |
| 13 | Exfiltration | Move data out of the environment | Transfer collected data to external storage |
| 14 | Impact | Disrupt or manipulate systems or data | Encrypt files or interrupt services |

### 1.4 Example: mapping activity to ATT&CK

| Observed activity | Possible tactic | Why |
|---|---|---|
| A suspicious Run key is added | Persistence | The command may execute again after login |
| A process accesses LSASS memory | Credential Access | The activity may target authentication material |
| A compromised account connects to another server over SMB | Lateral Movement | The account may be used to access another system |
| A large archive is uploaded to external cloud storage | Exfiltration | Data is being transferred out of the environment |
| Files are encrypted and made unavailable | Impact | The activity disrupts access to data |

ATT&CK mapping should be evidence-based. One event may support multiple hypotheses, and a technique should not be assigned solely because a tool or process name appears in a log.

---

## 2. Threat-Modelling Framework Comparison

### 2.1 Cyber Kill Chain

The Cyber Kill Chain, developed by Lockheed Martin, describes an intrusion as a sequence of stages. Its traditional stages are:

1. Reconnaissance
2. Weaponization
3. Delivery
4. Exploitation
5. Installation
6. Command and Control
7. Actions on Objectives

**Strength:** Helps explain and disrupt an intrusion as it progresses.

**Limitation:** Its linear structure may not represent every modern intrusion, especially activity after an attacker has already gained access.

### 2.2 Diamond Model

The Diamond Model represents an intrusion event through four core features:

- **Adversary:** The actor conducting the activity
- **Capability:** The tools or methods used
- **Infrastructure:** The systems or resources used to conduct the activity
- **Victim:** The target of the activity

It helps analysts connect related events and build threat-intelligence relationships.

### 2.3 MITRE ATT&CK

ATT&CK provides a detailed catalogue of tactics and techniques. It is especially useful for describing what an adversary did and mapping defensive detections to observed behaviour.

### 2.4 Comparison

| Model | Main focus | Useful for |
|---|---|---|
| Cyber Kill Chain | Stages of an intrusion | Understanding and disrupting an attack sequence |
| Diamond Model | Relationships between adversary, capability, infrastructure and victim | Threat intelligence and linking events |
| MITRE ATT&CK | Adversary tactics and techniques | Detection engineering, threat hunting and incident reporting |

These models complement one another. An analyst can use the Kill Chain to describe progression, the Diamond Model to connect infrastructure and actors, and ATT&CK to label specific behaviours.

---

## 3. Week 1 Comprehensive Assessment

### Exam structure

| Domain | Questions | Coverage |
|---|---:|---|
| 1. Networking, routing and switching | 1–10 | CAM tables, VLANs, routing, NAT, firewalls and ACLs |
| 2. Wireshark packet analysis | 11–20 | IP filters, DNS, HTTP, TLS, DHCP, TCP and ICMP |
| 3. Linux internals and Bash SOC analysis | 21–30 | Persistence, permissions, logs, processes and sockets |
| 4. Windows internals, Active Directory and MITRE | 31–40 | LSASS, Windows events, Sysmon, Kerberos and ATT&CK |

Try answering all questions before opening the answer key.

### Domain 1 — Networking, Routing and Switching

1. A switch receives a very large number of frames with random source MAC addresses. If its CAM table becomes full, what forwarding behaviour may occur for unknown destination MAC addresses?
2. In the classic 802.1Q double-tagging scenario described in this module, what relationship must exist between the attacker's access VLAN and the trunk's native VLAN?
3. In a router-on-a-stick configuration, where are the VLAN gateway IP addresses assigned: on the physical interface or on its subinterfaces?
4. If OSPF routing exchanges are not adequately authenticated or protected, what routing threat may become possible?
5. When two internal hosts share one public IP through PAT, what information allows the NAT device to distinguish their translated connections?
6. What is the RFC 1918 private IPv4 range commonly associated with the former Class B space?
7. What is the fundamental difference between stateful firewall inspection and stateless ACL filtering?
8. A firewall log says that it sent a TCP RST to the source. Is that more consistent with DROP or REJECT?
9. Where is an extended Cisco ACL generally placed: close to the source or close to the destination?
10. What Cisco Layer 2 security feature can validate ARP packets using DHCP snooping binding information?

### Domain 2 — Wireshark Packet Analysis

11. What is the difference between the Wireshark display filters `ip.addr == 10.0.0.5` and `ip.src == 10.0.0.5`?
12. What does DNS response code `3` mean? What suspicious behaviour may repeated NXDOMAIN responses help an analyst investigate?
13. Why may DNS TXT records be useful for carrying data in DNS tunnelling?
14. Where can an analyst inspect an HTTP form submission using `application/x-www-form-urlencoded` in Wireshark?
15. Which TLS Client Hello extension may expose the requested hostname in plaintext when SNI is present?
16. Which five Client Hello characteristics are used in the traditional JA3 fingerprint input?
17. What are the typical source and destination IPv4 addresses and UDP ports for a DHCP Discover message?
18. A client sends TCP SYN and receives RST-ACK. What does this normally indicate about the destination port?
19. What does a TCP Zero Window indication tell an analyst about the receiver?
20. If an ICMP Echo Request payload begins with bytes `4D 5A`, what file format signature may those bytes represent?

### Domain 3 — Linux Internals and Bash SOC Analysis

21. Besides `/var/spool/cron/`, which system-wide cron locations should an administrator inspect for scheduled-task persistence?
22. What numeric permission mode corresponds to `-rwsr-xr-x`, and what does the `s` indicate?
23. On Debian/Ubuntu, which common log file can contain sudo command audit records? What is a common equivalent on RHEL-family systems?
24. Which RAM-backed temporary filesystem path is worth checking when investigating suspicious temporary executable content?
25. For PID `4125`, which `/proc` symbolic link points to the process executable?
26. Write a Bash pipeline to display the top 10 client IP addresses generating HTTP 404 responses in a common Nginx access log, with counts.
27. What is the practical security difference between permissions `777` and `1777` on a shared directory?
28. In `ss` output, what is the difference between `LISTEN` and `ESTAB`?
29. Which `lsof` command can identify processes associated with port `4444`?
30. In a Bash test, what is the difference between `[ -f "$FILE" ]` and `[ -x "$FILE" ]`?

### Domain 4 — Windows Internals, Active Directory and MITRE

31. What is the main security role of LSASS, and why might an attacker attempt to access or dump its memory?
32. In Windows Security Event ID 4624, what is the difference between Logon Type 3 and Logon Type 10?
33. What does status/sub-status code `0xC000006A` commonly indicate in a failed logon event?
34. A Sysmon Event ID 1 record shows `w3wp.exe` spawning `cmd.exe` or `powershell.exe`. Why is this suspicious?
35. Which Active Directory account's secret is used to protect Kerberos Ticket Granting Tickets (TGTs)?
36. Which Active Directory attribute is central to identifying service accounts that may be targeted in Kerberoasting?
37. What is the persistence benefit of adding an autorun command to the Windows Run registry key?
38. In MITRE ATT&CK, what is the difference between a tactic and a technique?
39. An attacker uploads a collected archive containing company data to an external cloud storage service. Which ATT&CK tactic best describes the objective?
40. Which Windows System event commonly records the installation of a new service, including a service created during some PsExec activity?

---

## 4. Answer Key and Explanations

### Domain 1 — Networking, Routing and Switching

**1. Unknown-unicast flooding**

When a switch does not have a destination MAC entry, it may flood the frame through eligible ports in the same VLAN, excluding the ingress port. CAM table flooding attempts to create this condition by generating many source MAC addresses. Switch behaviour and protections vary by platform.

**SOC relevance:** Look for abnormal MAC learning rates, port-security violations and unusual unknown-unicast traffic.

**2. The attacker's access VLAN matches the native VLAN**

In the classic double-tagging explanation, the outer tag is associated with the native VLAN and may be removed by the first switch. The downstream switch can then process the inner tag.

**SOC relevance:** Use a dedicated unused native VLAN, tag native traffic where supported, and configure trunks explicitly.

**3. Subinterfaces**

The VLAN gateway addresses are assigned to logical subinterfaces such as `g0/0.10` and `g0/0.20`. Each subinterface is associated with a VLAN using 802.1Q encapsulation.

**SOC relevance:** Knowing the gateway design helps interpret routing paths and firewall logs.

**4. Rogue route injection or route manipulation**

An unauthorized router or routing peer may attempt to advertise false or unexpected routes. The result could be traffic redirection, interception or blackholing.

**SOC relevance:** Investigate unexpected OSPF neighbors, adjacency changes and route-table modifications.

**5. Translated transport-layer ports**

PAT commonly uses unique translated source ports, together with protocol and address information, to distinguish simultaneous connections sharing one public IP.

**SOC relevance:** Correlate public IP, translated port, protocol and timestamp with NAT records to identify the internal host.

**6. `172.16.0.0/12`**

The RFC 1918 range extends from `172.16.0.0` through `172.31.255.255`.

**SOC relevance:** An address in this range is private-use space and should not be treated as a globally routable public source.

**7. Stateful versus stateless filtering**

A stateful firewall tracks connection state and can permit return traffic that matches an allowed session. A stateless ACL evaluates each packet independently according to its rules.

**SOC relevance:** Analysts need to understand whether a log represents a new connection, return traffic or a packet that failed policy.

**8. REJECT**

A TCP RST sent to the source is consistent with an explicit rejection. DROP silently discards traffic, often causing the sender to time out.

**SOC relevance:** Confirm the action field and vendor-specific semantics in the firewall log.

**9. Close to the source**

Extended ACLs can match source, destination, protocol and port information. Placing them close to the source can prevent unwanted traffic from travelling further through the network.

**SOC relevance:** This principle can support containment of a compromised host, subject to network design and change-control procedures.

**10. Dynamic ARP Inspection (DAI)**

DAI validates ARP packets and can use DHCP snooping bindings to detect invalid IP-to-MAC mappings.

**SOC relevance:** Review DAI violations and DHCP snooping state when investigating ARP spoofing.

### Domain 2 — Wireshark Packet Analysis

**11. `ip.addr` matches either direction; `ip.src` matches only the source**

- `ip.addr == 10.0.0.5` matches packets where the address is either source or destination.
- `ip.src == 10.0.0.5` matches packets sent by that source address.

**SOC relevance:** Start with a bidirectional filter when reconstructing a conversation.

**12. NXDOMAIN**

DNS RCODE `3` means the queried domain name does not exist. Repeated NXDOMAIN responses can be a clue when investigating Domain Generation Algorithm (DGA) activity, but they are not proof of malware by themselves.

**SOC relevance:** Correlate the volume, queried domains, endpoint, timing and other process/network evidence.

**13. TXT records can carry arbitrary text data**

A DNS A record maps a hostname to an IPv4 address. TXT records can carry text strings, which makes them more flexible for tunnelling data. DNS tunnelling may abuse DNS queries and responses to move commands or data.

**SOC relevance:** Look for unusually long or high-volume DNS labels, abnormal TXT responses and rare query patterns.

**14. Packet Details or Follow Stream**

Select the HTTP request and expand the Hypertext Transfer Protocol details. The `Content-Type` header may show `application/x-www-form-urlencoded`; the request body may contain encoded key-value form fields. “Follow TCP Stream” can help reconstruct the exchange.

**SOC relevance:** Only inspect payloads when authorized. Modern HTTPS content is encrypted unless the analyst has an appropriate decryption method.

**15. Server Name Indication (SNI)**

When present, the SNI extension in the TLS Client Hello can expose the requested server hostname. Encrypted Client Hello (ECH) and other deployment details can limit visibility.

**SOC relevance:** SNI can help with domain-level triage, but it is not guaranteed to be visible in every TLS session.

**16. Traditional JA3 input fields**

The traditional JA3 fingerprint is derived from:

1. TLS version
2. Accepted cipher suites
3. Extension list
4. Supported elliptic curves/groups
5. Elliptic-curve point formats

The values are normalized into a string and hashed.

**SOC relevance:** JA3 can help cluster similar TLS clients, but it is not a unique or conclusive malware identifier. Different software can share fingerprints, and fingerprints can change.

**17. DHCP Discover uses `0.0.0.0:68` to `255.255.255.255:67`**

A client without an assigned IPv4 address commonly sends DHCP Discover from UDP port 68 to server port 67 using the limited broadcast destination.

**SOC relevance:** DHCP captures can reveal new devices requesting network configuration.

**18. The destination port is normally closed**

A host that receives a SYN for a non-listening TCP port commonly responds with RST-ACK. The host may be reachable even though the requested service is not listening.

**SOC relevance:** Distinguish a closed port response from a silent filtered response.

**19. The receiver is advertising that it cannot currently accept more data**

A TCP Zero Window means the receiver's advertised receive window is zero. The receiving host's buffer or application consumption may be unable to keep up.

**SOC relevance:** Investigate receiver resource pressure and application behaviour; do not automatically classify it as a network-bandwidth fault.

**20. Windows Portable Executable signature**

Bytes `4D 5A` represent ASCII `MZ`, commonly found at the start of Windows PE executables such as EXE and DLL files.

**SOC relevance:** Executable-looking content inside an ICMP payload may warrant investigation for tunnelling or unusual data transfer. The signature alone is not proof of malicious activity.

### Domain 3 — Linux Internals and Bash SOC Analysis

**21. `/etc/crontab` and `/etc/cron.d/`**

Also inspect distribution-specific periodic directories such as `/etc/cron.hourly/`, `/etc/cron.daily/`, and systemd unit locations such as `/etc/systemd/system/`.

**SOC relevance:** Attackers may use scheduled tasks or services to regain execution after reboot or at regular intervals.

**22. `4755`; SUID is enabled**

The leading `4` is the SUID bit. In `-rwsr-xr-x`, the owner execute position contains `s`, indicating that the executable runs with the file owner's effective user ID.

**SOC relevance:** Compare SUID files with a trusted system baseline and investigate unexpected additions or permission changes.

**23. `/var/log/auth.log` on Debian/Ubuntu; `/var/log/secure` on many RHEL-family systems**

These files commonly record authentication and sudo-related activity, depending on the distribution and logging configuration.

**SOC relevance:** Review timestamps, usernames, source addresses, TTY information and executed commands.

**24. `/dev/shm/`**

This is commonly a tmpfs-backed shared-memory filesystem. It can be used legitimately, but suspicious executable content there may be worth examining.

**SOC relevance:** Correlate files in `/dev/shm` with process execution, open file descriptors and system logs.

**25. `/proc/4125/exe`**

The symbolic link points to the executable associated with PID 4125.

Example:

```bash
readlink /proc/4125/exe
```

**SOC relevance:** It can reveal an executable path even when the process command name is misleading. A deleted executable may be shown with a `(deleted)` suffix.

**26. Nginx 404 pipeline**

```bash
grep " 404 " /var/log/nginx/access.log \
  | awk '{print $1}' \
  | sort \
  | uniq -c \
  | sort -nr \
  | head -n 10
```

**Explanation:** Filter 404 entries, extract the first field (client IP in the common log format), group duplicates, count them, sort by count and display the top ten.

**SOC relevance:** A high number of 404 responses may indicate scanning or content discovery, but also may result from ordinary broken links.

**27. Sticky bit in `1777`**

With `777`, all users can write to the directory and there is no sticky-bit restriction on deleting other users' entries. With `1777`, the sticky bit restricts deletion or renaming in a shared directory to the file owner, directory owner or root.

**SOC relevance:** Verify that shared temporary directories have appropriate permissions.

**28. LISTEN versus ESTAB**

- `LISTEN`: A service is waiting for incoming connections.
- `ESTAB`: A TCP connection has been established.

**SOC relevance:** Investigate unexpected listeners and correlate established external connections with their owning processes.

**29. `lsof -i :4444`**

Example:

```bash
sudo lsof -i :4444
```

It can show process and socket information associated with that port.

**SOC relevance:** Treat the result as an investigative lead. Port 4444 is not inherently malicious.

**30. `-f` versus `-x`**

- `[ -f "$FILE" ]` checks whether the path is a regular file.
- `[ -x "$FILE" ]` checks whether the current user can execute the path.

**SOC relevance:** Scripts can use these tests to validate inputs and identify executable files, but permissions should be interpreted in the context of the running user.

### Domain 4 — Windows Internals, Active Directory and MITRE

**31. LSASS handles important local security and authentication functions**

LSASS (`lsass.exe`) enforces local security policy and participates in authentication. Depending on Windows configuration and protections, credential-related material may be present in or accessible through its process memory. Attackers may target it to obtain credential material.

**SOC relevance:** Monitor suspicious process access to LSASS, unexpected dump files and related privilege activity. Windows protections and credential-isolation settings affect what can be accessed.

**32. Logon Type 3 versus Type 10**

- **Type 3:** Network logon, commonly associated with access to network resources such as SMB.
- **Type 10:** RemoteInteractive logon, commonly associated with Remote Desktop.

**SOC relevance:** Correlate logon type with account, source address, time, target system and expected user behaviour.

**33. `0xC000006A` means wrong password**

The account name is generally recognized, but the supplied password is incorrect. By comparison, `0xC0000064` commonly indicates that the user name does not exist.

**SOC relevance:** Repeated failures may indicate password guessing or a misconfigured service. Look at the full event and surrounding activity.

**34. Possible web-server command execution**

`w3wp.exe` is the IIS worker process. If it spawns a command interpreter such as `cmd.exe` or `powershell.exe`, this may indicate that a web request triggered command execution or that the server is misconfigured.

**SOC relevance:** Treat it as high priority, but validate the application, parent-child process details, command line, user context and change records before concluding that a web shell or RCE occurred.

**35. The `krbtgt` account**

The `krbtgt` account's secret is used to protect Kerberos Ticket Granting Tickets in Active Directory.

**SOC relevance:** Compromise of this account can enable forged-ticket attacks, including Golden Ticket activity. Protect and monitor domain controllers and privileged account operations.

**36. Service Principal Names (SPNs)**

Kerberoasting targets service tickets associated with SPNs. Service accounts with weak or outdated passwords may be at risk of offline password cracking if an attacker obtains the relevant ticket material.

**SOC relevance:** Review unusual service-ticket request patterns, service-account password strength and SPN ownership.

**37. Run key persistence**

A command added to a Windows Run key may execute automatically when the relevant user logs on (depending on the key and execution context).

Common locations include:

```text
HKLM\Software\Microsoft\Windows\CurrentVersion\Run
HKCU\Software\Microsoft\Windows\CurrentVersion\Run
```

**SOC relevance:** Monitor unexpected autorun entries and validate executable paths, signatures, owners and creation times.

**38. Tactic is the objective; technique is the method**

A tactic explains why an adversary performs an action. A technique explains how the adversary attempts to achieve that objective.

**SOC relevance:** ATT&CK mapping helps turn raw observations into consistent incident language.

**39. Exfiltration**

Uploading collected company data to external cloud storage is consistent with the Exfiltration tactic. The exact technique depends on the service and transfer method.

**SOC relevance:** Correlate data staging, outbound network traffic, cloud audit records and the account responsible.

**40. Windows System Event ID 7045**

Event ID 7045 commonly records that a service was installed. PsExec-style remote execution may create a service on the target system, which can generate this event.

**SOC relevance:** Correlate service installation with logon events, process creation, source host, service name and administrative activity.

---

## 5. Practical SOC Mapping Exercise

Use this scenario to practise connecting host evidence with ATT&CK.

**Scenario:** An organization reports unusual activity on an IIS server. The analyst finds:

- A new executable in a web-accessible directory
- `w3wp.exe` spawning `cmd.exe`
- A new outbound connection from the server
- A large archive created shortly afterwards
- The archive transferred to an external cloud service

A structured investigation might look like this:

| Evidence | Initial interpretation | ATT&CK area to consider |
|---|---|---|
| New executable in web directory | Possible unauthorized file placement | Initial Access or Persistence, depending on evidence |
| Web worker starts command interpreter | Possible command execution through web application | Execution |
| New outbound connection | Possible external communication | Command and Control, depending on purpose |
| Archive created | Possible data staging or collection | Collection |
| Archive transferred externally | Possible data theft | Exfiltration |

Do not force every observation into a single tactic. Validate each hypothesis with timestamps, process details, file metadata, network records and application logs.

---

## 6. Week 1 Scorecard

The supplied Week 1 evaluation recorded the following reported results:

| Competency | Reported score |
|---|---:|
| TCP/IP and OSI architecture | 90% |
| Subnetting and CIDR logic | 95% |
| Wireshark packet dissection | 88% |
| Switching and VLAN security | 85% |
| Routing, firewalls and NAT triage | 85% |
| Linux forensics and Bash log parsing | 82% |
| Windows internals and event analysis | 80% |
| MITRE ATT&CK and threat mapping | 85% |
| **Overall reported Week 1 grade** | **86.5%** |

These are the scores recorded in the supplied evaluation material, not independently re-tested results.

### Suggested self-grading

- 36–40 correct: Strong understanding; explain your reasoning and practise incident scenarios.
- 30–35 correct: Good foundation; revisit missed topics and repeat practical labs.
- 24–29 correct: Developing understanding; review the relevant day README and practise commands.
- Below 24: Revisit the fundamentals before moving to more advanced scenarios.

A correct answer should include the concept, the reason it is correct and its relevance to an investigation.

---

## 7. Week 1 Completion Checklist

- [ ] Explain the 14 Enterprise ATT&CK tactics.
- [ ] Distinguish tactics, techniques, sub-techniques and procedures.
- [ ] Compare the Cyber Kill Chain, Diamond Model and ATT&CK.
- [ ] Complete all 40 assessment questions without looking at the answer key.
- [ ] Explain why each answer is correct.
- [ ] Map a realistic incident's evidence to possible ATT&CK tactics.
- [ ] Identify where additional evidence is needed before declaring an incident.

## Key Takeaway

MITRE ATT&CK gives SOC analysts a shared language for describing adversary behaviour. Its greatest value comes when analysts connect the framework to real evidence: packet captures, endpoint telemetry, authentication events, process trees, network connections and file activity.
