# Section 5 - HTTPS / TLS Analysis

## Goal

Find malicious encrypted traffic by looking at the parts that are not encrypted: the handshake, the server name, the certificate and the traffic pattern.

## Idea

Most traffic is encrypted, so I cannot read the payload. I can still read metadata:

- SNI (the server name sent in the Client Hello)
- Certificate details (issuer, subject, validity dates)
- JA3 fingerprint of the client
- Packet sizes and timing

## Handshake

1. Client Hello: versions, ciphers, SNI
2. Server Hello and Certificate
3. Key exchange
4. Encrypted application data

(In TLS 1.3 the certificate is encrypted, so certificate checks are easiest on TLS 1.2 or with a decrypting proxy.)

## Key concepts

| Concept | Meaning for a SOC analyst |
|---------|---------------------------|
| SNI | Plaintext domain in the Client Hello. Normal browsers always send it |
| Certificate | Self-signed, expired, odd issuer or very short validity is suspicious |
| JA3 | Hash of Client Hello fields (version, ciphers, extensions, curves, curve formats). Same malware gives the same JA3 even if IP and domain change |

## Filters

```
tls
tls.handshake.type == 1
tls.handshake.type == 2
tls.handshake.type == 11
tls.handshake.extensions_server_name
tls.handshake.extensions_server_name contains "evil"
```

## Sample

Client Hello with SNI `command-center-node.ru`. Server certificate issued by `Evil-Root-CA`, valid for one day. The payload is encrypted but the SNI and the certificate already give the host away.

## Practice 1 (medium): host 10.0.0.15 to 45.33.32.156

Client Hello without SNI, server certificate self-signed with issuer `localhost`, small repeated 200-byte data packets.

1. Three red flags. My answer: no SNI, self-signed certificate, issuer is localhost. All correct.
2. Why no SNI is suspicious. My answer: SNI tells the server which site and certificate the client wants. Added note: a normal browser always sends it, so a missing SNI suggests a script or a binary connecting directly to an IP, such as a C2 beacon.
3. Filter. My answer: `tls.handshake.type==1`. I forgot the source IP. Correct:

```
ip.src == 10.0.0.15 && tls.handshake.type == 1
```

## Practice 2 (hard): workstation 172.16.2.90

Client Hello SNI is `static.cloudflare.com`, but the server certificate subject is `evil-c2-infrastructure.xyz`.

1. Anomaly: the SNI and the certificate name do not match. I did not know this one. The expected answer is domain fronting. A careful note: in classic domain fronting, the SNI shows a trusted front domain and the real destination is hidden in the encrypted HTTP Host header, so the certificate normally matches the front domain. A certificate that names the malicious domain, as in this lab, is a mismatch that is suspicious either way. In a report I should write "SNI and certificate mismatch, possible fronting or spoofed SNI" and then confirm.
2. JA3: a hash made from the Client Hello fields (TLS version, cipher suites, extensions, elliptic curves, curve formats). Tools like Cobalt Strike or TrickBot produce known hashes. Even when the attacker changes IP and domain, the same client software keeps the same JA3, so it can be detected. I did not answer this one at first.
3. Filter. My answer: `tls.handshake.type==1 && tcp.port==443`. Correct.

## What I learned

- Encrypted does not mean invisible. The handshake gives a lot.
- Missing SNI plus a self-signed certificate is a strong C2 sign.
- JA3 follows the tool, not the infrastructure.

## Still to practise

- Domain fronting and JA3 in real captures
- Comparing SNI to certificate name quickly
