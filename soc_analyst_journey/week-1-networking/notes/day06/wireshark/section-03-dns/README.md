# Section 3 - DNS Analysis

## Goal

Read DNS queries and responses, and spot DNS-based attacks: DGA malware, DNS tunneling and spoofing.

## Why DNS matters

Almost no company blocks port 53, because blocking it breaks the whole network. Attackers use that. They hide data in DNS queries, find C2 servers with generated domains, or redirect users with fake answers.

## DNS packet fields

- Transaction ID: ties a response to its query
- Flags: query or response
- Questions: the name being asked
- Answers: the returned address
- RCODE: result status

## Record types

| Type | Use | SOC note |
|------|-----|----------|
| A | IPv4 address | Normal lookup |
| AAAA | IPv6 address | Normal lookup |
| TXT | Free text | High risk, used for C2 and exfiltration |
| MX | Mail server | Seen in phishing recon |
| PTR | Reverse lookup | Seen in internal scanning |

## Response codes

| Code | Name | Meaning |
|------|------|---------|
| 0 | NOERROR | Success |
| 3 | NXDOMAIN | Name does not exist. Many of these can mean DGA |
| 5 | REFUSED | Server refused to answer |

## Filters

```
dns
dns.flags.response == 0
dns.flags.response == 1
dns.flags.rcode == 3
dns.qry.type == 16
dns.qry.name contains "xyz"
dns.id == 0x3379
```

## Checks on a normal exchange

- The query ID and the response ID must match. A reply with no matching query can be spoofing or cache poisoning.
- The client uses a random high port, the server answers from port 53.
- Red flags: very long random subdomains, lots of TXT queries, a DNS server that is not the configured one.

## Practice 1 (medium): host 10.0.0.88, 500+ queries in 30 seconds

Queries like `h9x2k1q8a.biz`, `m3p7w4v9r.biz`, all answered NXDOMAIN.

1. Technique: DGA (Domain Generation Algorithm). My answer: I did not know the name.
2. Why NXDOMAIN: the domains do not exist. My answer was correct. The malware generates many domains and only one is registered by the attacker.
3. Filter. My answer: `dns.flags.recode=3 && ip.addr=10.0.0.88`. Problems: `rcode` was misspelled, `=` should be `==`, and direction was missing. Correct:

```
dns.flags.rcode == 3 && ip.dst == 10.0.0.88
```

## Practice 2 (hard): workstation 172.16.5.12

Queries like `SGVsbG8gV29ybGQgRGF0YQ.c2-exfil.com`, type TXT, answered with "ACK".

1. Technique: DNS tunneling used for data exfiltration. My answer: data exfiltration, which was right.
2. Encoding: Base64. My answer was hashing, which was wrong. A hash cannot be reversed, Base64 can. `SGVsbG8gV29ybGQgRGF0YQ` decodes to "Hello World Data", and the third query decodes to what looks like a card number.
3. Why TXT: it carries arbitrary text, so the attacker can send data. My answer was correct.
4. Filter. My answer: `ip.addr=172.16.5.12&& dns.qry.type=16`. Correct:

```
ip.src == 172.16.5.12 && dns.qry.type == 16 && dns.flags.response == 0
```

5. Response. My answer: block the IP or subdomain. That is only part of it. Full response: isolate the host, block the domain and IP, then hand over to Tier 2 / forensics for memory and disk analysis.

## What I learned

- Many NXDOMAIN replies to random names is DGA.
- Long encoded subdomains with TXT queries is tunneling.
- Base64 is encoding, not hashing.
- Blocking the destination is not enough, the infected host must be isolated.

## Still to practise

- Decoding Base64 from a capture by hand
- Telling real CDN traffic with long names from real tunneling
