# Day 4 — Switching, VLANs, Routing, NAT and Firewall Security

## Overview

Day 4 focuses on how enterprise networks move traffic between devices and network segments, and how a SOC analyst can recognize attacks or misconfigurations in that traffic.

The main topics are:

1. Ethernet switching and CAM table security
2. VLANs, 802.1Q trunking and VLAN-hopping attacks
3. Inter-VLAN routing and routing protocols
4. NAT, PAT and translation-log analysis
5. Firewalls and Access Control Lists (ACLs)

The examples use Cisco-style configuration syntax where applicable. Run configuration commands only in an authorized lab.

---

## 1. Ethernet Switching and CAM Table Security

### 1.1 What a switch does

A Layer 2 switch forwards Ethernet frames using destination MAC addresses. It learns which MAC address is reachable through which physical port and stores this information in its **CAM table** (also called the MAC address table).

A simplified entry looks like this:

| VLAN | MAC address | Switch port |
|---|---|---|
| 10 | 00:11:22:33:44:55 | Gi0/1 |
| 20 | 00:AA:BB:CC:DD:EE | Gi0/2 |

When a frame arrives, the switch learns the source MAC address and checks the destination MAC address:

- **Known unicast:** Forward the frame through the port associated with the destination MAC.
- **Unknown unicast:** Flood the frame out eligible ports in the same VLAN, except the port on which it arrived.
- **Broadcast:** Flood the frame within the VLAN, subject to normal switching rules.

### 1.2 CAM table flooding

A CAM table has finite capacity. An attacker may generate a large number of frames with many spoofed source MAC addresses in an attempt to fill the table. This is commonly called **MAC flooding** or **CAM table flooding**.

If the switch cannot learn new MAC addresses, traffic for unknown destinations may be flooded within the VLAN. This can expose traffic to devices that would not normally receive those frames. The exact behavior depends on the switch model and configuration; it should not be described as every switch universally entering a literal “hub mode.”

**SOC indicators**

- An unusually high rate of new MAC addresses on one access port
- MAC address-table utilization approaching device capacity
- MAC addresses rapidly moving between ports
- Unexpected unknown-unicast flooding
- Port-security violation messages

### 1.3 Port security

Port security limits which source MAC addresses are allowed on a switch port.

Common Cisco violation modes:

| Mode | Behaviour |
|---|---|
| `protect` | Drops frames from unauthorized MAC addresses; does not generate the same violation notifications as restrict mode |
| `restrict` | Drops unauthorized frames and increments violation counters; can generate syslog/SNMP notifications |
| `shutdown` | Places the port into an error-disabled state |

Example lab configuration:

```text
Switch(config)# interface gi0/1
Switch(config-if)# switchport mode access
Switch(config-if)# switchport port-security
Switch(config-if)# switchport port-security maximum 2
Switch(config-if)# switchport port-security violation restrict
```

Useful verification commands:

```text
show port-security
show port-security interface gi0/1
show mac address-table
show logging
```

### 1.4 Incident response for suspected MAC flooding

Do not shut down an entire switch as the first response. That could disconnect many legitimate users and create an outage.

A more controlled response is:

1. Identify the affected access port using the MAC address table, port-security status and switch logs.
2. Confirm whether the MAC churn is abnormal and whether the port belongs to an endpoint or an infrastructure device.
3. If evidence supports an attack, contain the specific source port according to the organization's incident-response procedure.
4. Preserve relevant logs and record timestamps, MAC addresses, VLANs and port details.
5. Review port-security limits and other Layer 2 protections.
6. Restore service only after the port and connected device have been assessed.

---

## 2. VLANs and 802.1Q Trunking

### 2.1 Why VLANs are used

A **Virtual LAN (VLAN)** divides a switched network into separate Layer 2 broadcast domains. For example, an organization may separate Finance, HR, servers and guest devices even when they share physical switch infrastructure.

Without appropriate segmentation and access controls, devices in the same broadcast domain may have greater opportunities to observe or interfere with local traffic.

A VLAN is a Layer 2 boundary. Communication between different VLANs requires Layer 3 routing and may also be restricted by firewall or ACL policy.

### 2.2 Access ports and trunk ports

| Port type | Purpose | Typical connection |
|---|---|---|
| Access | Carries traffic for one assigned VLAN | Desktop, printer or ordinary endpoint |
| Trunk | Carries traffic for multiple VLANs | Switch-to-switch or switch-to-router link |

An access port normally sends and receives untagged frames from the connected endpoint. A trunk uses VLAN tagging to identify the VLAN associated with each frame.

### 2.3 IEEE 802.1Q

IEEE 802.1Q adds a four-byte VLAN tag to an Ethernet frame. The tag includes:

- **TPID:** Commonly `0x8100`, identifying an 802.1Q-tagged frame.
- **Priority information:** Used for traffic-class/priority handling.
- **VLAN ID:** A 12-bit field. VLAN IDs 1–4094 are commonly available for ordinary VLAN assignment; 0 and 4095 have reserved meanings.

### 2.4 VLAN-hopping risks

VLAN hopping describes attempts to send traffic into a VLAN that the sender should not be able to access. Two classic methods are switch spoofing and double tagging.

#### Method A: Switch spoofing

Some Cisco environments support Dynamic Trunking Protocol (DTP), which negotiates trunking. If an access-facing port is left in a negotiation-friendly mode, a malicious endpoint may attempt to make the switch treat it as a trunk peer.

**Mitigations**

- Configure endpoint-facing ports explicitly as access ports.
- Disable DTP negotiation where it is not required.
- Restrict the VLANs allowed on trunks.
- Disable unused switch ports and place them in an unused VLAN.
- Avoid connecting untrusted devices to trunk ports.

Example:

```text
Switch(config)# interface gi0/10
Switch(config-if)# switchport mode access
Switch(config-if)# switchport nonegotiate
```

#### Method B: Double tagging

In a classic double-tagging scenario, an attacker crafts a frame containing two VLAN tags. Under specific conditions, the first switch removes the outer tag associated with its native VLAN while forwarding the frame. A downstream switch may then process the remaining inner tag.

Important conditions and limitations:

- The attacker’s access VLAN must match the trunk’s native VLAN for the classic scenario described here.
- The attack depends on the switch topology and native-VLAN handling.
- It is generally a one-way injection technique; it does not automatically provide a two-way conversation with the target VLAN.

**Mitigations**

- Do not use the default VLAN as the native VLAN.
- Use an unused, dedicated native VLAN.
- Tag native VLAN traffic where supported and appropriate.
- Do not place user endpoints in the native VLAN.
- Restrict allowed VLANs on trunks and keep trunk configuration explicit.

### 2.5 SOC investigation points

When investigating unexpected cross-VLAN communication, review:

- Switch port mode and DTP status
- Native VLAN configuration on both ends of a trunk
- Allowed VLAN lists
- MAC address-table entries
- DHCP snooping and Dynamic ARP Inspection status
- Firewall/ACL logs for inter-VLAN traffic

---

## 3. Inter-VLAN Routing and Routing Protocols

### 3.1 Why routing is required

VLANs are separate Layer 2 broadcast domains. A device in VLAN 10 cannot directly deliver an Ethernet frame to a device in VLAN 20 as though both were on the same VLAN. A Layer 3 device must route traffic between the networks.

### 3.2 Router-on-a-stick

Router-on-a-stick uses one physical router interface with multiple logical subinterfaces. Each subinterface is associated with a VLAN and commonly serves as that VLAN's default gateway.

Example:

```text
Router(config)# interface g0/0
Router(config-if)# no shutdown

Router(config)# interface g0/0.10
Router(config-subif)# encapsulation dot1Q 10
Router(config-subif)# ip address 192.168.10.1 255.255.255.0

Router(config)# interface g0/0.20
Router(config-subif)# encapsulation dot1Q 20
Router(config-subif)# ip address 192.168.20.1 255.255.255.0
```

The switch port connected to the router must be configured as a trunk and must carry the required VLANs.

### 3.3 Layer 3 switches

A Layer 3 switch can route between VLANs using switched virtual interfaces (SVIs). In larger networks, this can provide inter-VLAN routing without sending all traffic through a separate router.

### 3.4 Routing protocol comparison

| Method / protocol | Category | Key idea | Security consideration |
|---|---|---|---|
| Static routing | Manually configured | Administrator defines routes | Simple, but changes must be managed carefully |
| OSPF | Interior Gateway Protocol; link-state | Routers exchange link-state information and calculate paths | Unauthorized adjacency or route information can affect routing if controls are weak |
| BGP | Exterior Gateway Protocol; path-vector | Autonomous systems exchange reachability information | Incorrect or malicious route announcements can cause route leaks or hijacking |

**OSPF**

- Uses IP protocol number 89; it does not use TCP or UDP port 89.
- Commonly uses multicast addresses `224.0.0.5` and `224.0.0.6` for IPv4 OSPF.
- Authentication and network design help protect routing exchanges.
- Unexpected neighbor changes or route changes deserve investigation.

**BGP**

- Uses TCP port 179.
- Exchanges routing information between autonomous systems.
- SOC teams may investigate unexpected prefix announcements, route changes or traffic-path anomalies.

### 3.5 SOC triage

If a routing alert occurs:

1. Identify the affected router, interface and routing protocol.
2. Check whether a neighbor appeared, disappeared or changed state.
3. Compare the new route with the approved network baseline.
4. Check configuration-change records and maintenance windows.
5. Determine whether traffic was redirected, blackholed or exposed.
6. Escalate suspicious route changes to the network/security engineering team.

---

## 4. NAT, PAT and Translation-Log Analysis

### 4.1 Why NAT matters to a SOC analyst

Network Address Translation (NAT) changes IP address information as traffic passes through a router or firewall. Private internal addresses are commonly translated when communicating with public networks.

A SOC analyst may see a public IP address in an external alert or service log. To identify the internal endpoint responsible, the analyst may need the NAT translation record and its timestamp.

### 4.2 RFC 1918 private IPv4 ranges

| Range | CIDR |
|---|---|
| `10.0.0.0` – `10.255.255.255` | `10.0.0.0/8` |
| `172.16.0.0` – `172.31.255.255` | `172.16.0.0/12` |
| `192.168.0.0` – `192.168.255.255` | `192.168.0.0/16` |

These addresses are not globally routable on the public Internet.

### 4.3 NAT terminology

| Term | Meaning |
|---|---|
| Inside local | Internal address of the inside host before translation |
| Inside global | Address representing the inside host to the outside network |
| Outside local | Address of the outside host as represented to the inside network |
| Outside global | Actual address of the outside host on the external network |

### 4.4 PAT (NAT overload)

Port Address Translation allows multiple internal devices to share one public IP address. The translator uses transport-layer port information to keep connections distinct.

Example:

```text
Internal host A: 192.168.1.50:49200
Translated to:   203.0.113.10:10050

Internal host B: 192.168.1.51:49200
Translated to:   203.0.113.10:10051
```

The translated source ports allow the NAT device to map return traffic to the correct internal connection.

### 4.5 Reading a NAT log

Example log:

```text
%ASA-6-305011: Built dynamic TCP translation from inside:192.168.1.85/54312 to outside:203.0.113.10/21045
```

Interpretation:

- Internal endpoint: `192.168.1.85:54312`
- Translated public endpoint: `203.0.113.10:21045`

For incident attribution, correlate the external IP, translated port, protocol and exact timestamp with the firewall's NAT/state records. A public IP alone may represent many internal users.

**Important:** NAT log formats differ between vendors and products. Confirm the meaning of each field against the relevant platform documentation.

---

## 5. Firewalls and Access Control Lists

### 5.1 Stateless filtering

A stateless ACL evaluates each packet independently against configured rules. It does not maintain a full connection-state table.

Consequences:

- Rules must account for both directions of traffic.
- Rule order matters.
- A broad permit can unintentionally allow traffic.
- An implicit deny at the end of many ACL configurations can block traffic not explicitly permitted.

### 5.2 Stateful inspection

A stateful firewall tracks connection information, such as source/destination addresses, ports and connection state. Return traffic can be allowed when it matches a permitted established session.

A simplified TCP lifecycle:

```text
Client                         Server
  | -------- SYN -------------> |
  | <------ SYN-ACK ------------|
  | -------- ACK --------------> |
  |       Connection established|
```

Stateful inspection is not a substitute for a well-designed security policy. It still requires carefully scoped rules and monitoring.

### 5.3 DROP versus REJECT

| Action | Behaviour |
|---|---|
| DROP | Silently discards the packet; the sender may experience a timeout |
| REJECT | Discards the packet and sends an explicit response, such as TCP RST or ICMP unreachable |

A reset or explicit unreachable response is evidence of rejection, although the exact log wording depends on the firewall.

### 5.4 Standard and extended Cisco ACLs

| ACL type | Matches | General placement guideline |
|---|---|---|
| Standard | Source IPv4 address | Close to the destination |
| Extended | Source, destination, protocol and ports | Close to the source |

Examples:

```text
! Standard ACL example
access-list 10 permit 192.168.1.0 0.0.0.255

! Extended ACL example
access-list 101 permit tcp 192.168.1.0 0.0.0.255 host 10.0.0.5 eq 80
```

Many Cisco ACLs include an implicit `deny` at the end. Therefore, traffic that does not match an earlier permit rule is denied.

### 5.5 Layer 2 protection: Dynamic ARP Inspection

Dynamic ARP Inspection (DAI) helps defend against ARP spoofing. On supported switches, it validates ARP packets against trusted information, commonly the DHCP snooping binding database.

DAI is normally configured with DHCP snooping and carefully selected trusted interfaces. Static-address environments may require additional configuration.

### 5.6 SOC checklist

When investigating a firewall or ACL event, capture:

- Source and destination IP addresses
- Source and destination ports
- Protocol
- Interface and direction
- Rule or ACL identifier
- Action: allow, drop or reject
- Timestamp and timezone
- NAT translation details, if applicable
- Whether the event is expected for the host's role

---

## 6. Day 4 Review Checklist

- [ ] Explain how a switch learns and uses MAC addresses.
- [ ] Distinguish known unicast, unknown unicast and broadcast forwarding.
- [ ] Explain CAM table flooding and port-security modes.
- [ ] Compare access ports and trunk ports.
- [ ] Explain the purpose of the 802.1Q tag.
- [ ] Describe switch spoofing and double-tagging at a conceptual level.
- [ ] Explain router-on-a-stick and the role of subinterfaces.
- [ ] Compare static routes, OSPF and BGP.
- [ ] Identify RFC 1918 private ranges.
- [ ] Explain NAT terminology and PAT port translation.
- [ ] Interpret a basic NAT translation log.
- [ ] Compare stateful and stateless filtering.
- [ ] Distinguish DROP from REJECT.
- [ ] Compare standard and extended ACLs.
- [ ] Explain how DAI helps prevent ARP spoofing.

## Key Takeaway

Day 4 connects network engineering concepts with SOC investigation. A good analyst must understand not only how traffic should move, but also how segmentation, switching, routing, NAT and firewall decisions appear in logs and how abnormal changes can affect confidentiality, availability and network integrity.
