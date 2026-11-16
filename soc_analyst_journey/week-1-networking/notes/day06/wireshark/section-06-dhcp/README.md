# Section 6 - DHCP Analysis

## Goal

Understand how a device gets its network settings and how attackers abuse DHCP.

## Why DHCP is a target

DHCP gives a new device its IP address, gateway and DNS server. If an attacker controls that answer, they control where the victim's traffic goes.

- Rogue DHCP server: fake gateway and DNS give a man-in-the-middle position
- DNS poisoning through DHCP: victim uses the attacker's DNS
- DHCP starvation: the pool of IPs is used up with fake MAC addresses, so real users cannot join (denial of service)

## DORA process

1. Discover: client broadcasts "any DHCP server?" (0.0.0.0:68 to 255.255.255.255:67)
2. Offer: server proposes an IP
3. Request: client asks for that IP
4. Acknowledge: server confirms and gives a lease

Ports: UDP 67 (server) and UDP 68 (client). Older Wireshark names the filter `bootp`.

## Important options

| Option | Meaning | Risk |
|--------|---------|------|
| 53 | Message type (1 Discover, 2 Offer, 3 Request, 5 ACK, 6 NAK) | Used to filter |
| 3 | Router (default gateway) | If it is the attacker, MITM |
| 6 | DNS server | If it is the attacker, DNS poisoning |
| 51 | Lease time | Odd values can mean something unusual |

## Filters

```
dhcp or bootp
dhcp.option.dhcp == 1
dhcp.option.dhcp == 2
dhcp.option.dhcp == 5
dhcp.option.router
dhcp.option.dns_server
```

## Practice 1 (medium): VLAN 20 users cannot reach internal servers

Real server 10.20.0.1 offers 10.20.0.50 with router 10.20.0.1 and DNS 10.20.0.2. A second offer comes from 10.20.0.250 with itself as router and DNS. The client requests from server 10.20.0.250 and gets the ACK.

1. Attack: rogue DHCP server (man-in-the-middle). My answer was correct.
2. Attacker: 10.20.0.250. The client took its offer because, in a race, the offer that arrives first is usually the one chosen.
3. Impact. My answer: after packet 3 all traffic passes through the attacker's gateway. Correct. The DNS setting is also the attacker's, so names can be faked too.
4. Filter. My answer: `dhcp.option.type==2`. The correct one:

```
dhcp.option.dhcp == 2
```

## Practice 2 (hard): pool exhaustion on 192.168.10.0/24

About 250 Discovers per second, each with a different fake MAC, then a NAK saying no addresses are left.

1. Attack. My answer: DoS. The exact name is DHCP starvation (tools like Yersinia or Gobbler).
2. Goal. My answer: stop users reaching the network. Correct: new devices cannot get an IP.
3. Defence: DHCP snooping. I did not know this. The switch marks ports as trusted (where the real DHCP server is) or untrusted (users). Offers and ACKs from untrusted ports are dropped, which stops rogue servers. Port security limits MACs per port, which helps against starvation.
4. Filter. I wrote `dhcpp.option.type==53`, with a typo. Correct:

```
dhcp.option.dhcp == 1
```

## What I learned

- DORA by heart, and what options 3 and 6 can do in the wrong hands
- Two offers for the same client is a strong rogue server clue
- DHCP snooping is the main switch defence

## Still to practise

- Layer 2 defences (DHCP snooping, port security, dynamic ARP inspection)
