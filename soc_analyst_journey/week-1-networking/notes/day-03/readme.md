# Day 3 --- DNS, DHCP & HTTP/HTTPS

> **SOC Analyst Journey · Week 1 · Networking Foundations**\
> Focus: Protocol fundamentals, packet-level understanding, common
> attacks and SOC detection.

------------------------------------------------------------------------

## 📑 Table of Contents

-   [1. DNS --- Domain Name System](#1-dns--domain-name-system)
-   [2. DNS Attacks](#2-dns-attacks)
-   [3. DNS Commands and Wireshark
    Filters](#3-dns-commands-and-wireshark-filters)
-   [4. DHCP --- Dynamic Host Configuration
    Protocol](#4-dhcp--dynamic-host-configuration-protocol)
-   [5. DHCP Attacks](#5-dhcp-attacks)
-   [6. DHCP Commands and Wireshark
    Filters](#6-dhcp-commands-and-wireshark-filters)
-   [7. HTTP --- HyperText Transfer
    Protocol](#7-http--hypertext-transfer-protocol)
-   [8. HTTPS and TLS](#8-https-and-tls)
-   [9. HTTP/HTTPS Commands and Wireshark
    Filters](#9-httphttps-commands-and-wireshark-filters)
-   [10. Troubleshooting Scenarios](#10-troubleshooting-scenarios)
-   [11. Interview Questions](#11-interview-questions)
-   [12. Cybersecurity Connection](#12-cybersecurity-connection)
-   [Key Takeaways](#-key-takeaways)

------------------------------------------------------------------------

## 1. DNS --- Domain Name System

### A. Definition

DNS converts human-readable domain names into IP addresses that
computers use to communicate.

  -----------------------------------------------------------------------
  Property                            Details
  ----------------------------------- -----------------------------------
  Full form                           Domain Name System

  Purpose                             Domain name → IP address

  Port                                53

  Transport                           UDP for most queries; TCP is also
                                      used, including for zone transfers
                                      and some larger responses
  -----------------------------------------------------------------------

Example:

``` text
google.com → 142.250.80.46
```

### B. Analogy

DNS works like a phonebook: you look up a person's name to find their
phone number.

``` text
google.com (name)
       |
       v
   DNS server
       |
       v
142.250.80.46 (IP address)
       |
       v
   Connection
```

### C. DNS Resolution Process

When a user enters `www.example.com`, the lookup generally follows this
process:

``` text
User enters: www.example.com
              |
              v
1. LOCAL CACHE CHECK
   Browser cache → OS cache → hosts file
              |
       IP found? ---- Yes ---> Use cached result
              |
              No
              v
2. RECURSIVE RESOLVER
   Usually provided by an ISP or configured public DNS
              |
              v
3. ROOT DNS SERVER (.)
   Refers the resolver to the relevant TLD server
              |
              v
4. TLD DNS SERVER (.com)
   Refers the resolver to the domain's authoritative server
              |
              v
5. AUTHORITATIVE DNS SERVER
   Returns the requested DNS record
              |
              v
6. RESPONSE TO CLIENT
   Resolver returns the result; browser connects to the IP
```

**Important:** The recursive resolver performs the lookup on behalf of
the client. It contacts the DNS hierarchy when the answer is not already
cached.

### D. DNS Record Types

  -----------------------------------------------------------------------
  Record                  Full name               Purpose
  ----------------------- ----------------------- -----------------------
  A                       Address                 Maps a domain to an
                                                  IPv4 address

  AAAA                    IPv6 Address            Maps a domain to an
                                                  IPv6 address

  CNAME                   Canonical Name          Creates an alias for
                                                  another domain name

  MX                      Mail Exchange           Identifies mail servers
                                                  for a domain

  TXT                     Text                    Stores text data,
                                                  including SPF, DKIM and
                                                  verification records

  NS                      Name Server             Identifies
                                                  authoritative name
                                                  servers

  PTR                     Pointer                 Supports reverse DNS
                                                  lookup (IP → name)

  SOA                     Start of Authority      Contains administrative
                                                  information about a DNS
                                                  zone
  -----------------------------------------------------------------------

> **SOC note:** Unusually long or encoded-looking TXT queries and
> subdomains can be indicators of DNS tunneling. They are clues to
> investigate, not proof on their own.

### E. DNS Packet Structure

**DNS Query**

``` text
+----------------------------------+
| Transaction ID: 0x1a2b           |
| Flags: Standard Query            |
| Questions: 1                     |
|                                  |
| Name: www.example.com            |
| Type: A                          |
| Class: IN                        |
+----------------------------------+
```

**DNS Response**

``` text
+----------------------------------+
| Transaction ID: 0x1a2b           |
| Flags: Response, No Error        |
| Answers: 1                       |
|                                  |
| Name: www.example.com            |
| Type: A                          |
| TTL: 300                         |
| Address: 93.184.216.34           |
+----------------------------------+
```

Important fields:

-   **Transaction ID:** Helps match a response with its query.
-   **Flags:** Identify whether the message is a query or response and
    provide response information.
-   **Questions:** Number of questions in the DNS message.
-   **Answers:** Number of answer records.
-   **TTL (Time to Live):** How long a DNS record can remain cached.

------------------------------------------------------------------------

## 2. DNS Attacks

### A. DNS Spoofing / Cache Poisoning

An attacker causes a client or DNS resolver to receive or store an
incorrect DNS response. A user requesting a legitimate domain may be
directed to an attacker-controlled IP address.

``` text
User requests bank.com
          |
          v
False DNS response
          |
          v
Malicious IP returned
          |
          v
Fake website
          |
          v
Credentials may be stolen
```

**Possible indicators:**

-   DNS responses from unexpected or unauthorized sources.
-   Multiple responses associated with the same query.
-   Unexpected domain-to-IP mappings.
-   DNS cache entries that do not match trusted DNS information.

**Defenses:**

-   DNSSEC validation.
-   Trusted DNS resolvers.
-   Secure DNS configuration.
-   Monitoring unexpected DNS responses.

### B. DNS Tunneling

An attacker hides encoded information inside DNS queries and uses DNS
communication to transfer data.

Example:

``` text
aGVsbG8gd29ybGQ.evil-attacker.com
```

The subdomain resembles Base64-encoded data.

**Possible indicators:**

-   Large numbers of queries to the same unusual domain.
-   Unusually long subdomain names.
-   Frequent TXT record queries.
-   High DNS query volume from a single host.
-   Encoded-looking strings in queried domain names.

**Defenses:**

-   Monitor DNS query length and volume.
-   Detect unusual domains and query patterns.
-   Correlate DNS activity in a SIEM.
-   Restrict clients to approved DNS resolvers.

### C. DNS Amplification (DDoS)

An attacker sends DNS requests using a spoofed source IP address
belonging to the victim. DNS servers send their responses to the victim,
potentially overwhelming its network.

``` text
Attacker
   |
   | Small DNS request with spoofed source IP
   v
DNS resolvers
   |
   | Larger DNS responses
   v
Victim network
   |
   v
Traffic overload
```

**Possible indicators:**

-   Large volumes of incoming DNS responses.
-   Responses from many DNS servers.
-   Unexpected DNS responses that do not match client queries.
-   Unusually large response-to-request ratios.

**Defenses:**

-   Rate limiting.
-   Preventing open-resolver abuse.
-   BCP 38 anti-spoofing.
-   DDoS protection.

------------------------------------------------------------------------

## 3. DNS Commands and Wireshark Filters

### DNS Commands

``` bash
# Basic DNS lookup
nslookup google.com

# Detailed DNS query
dig google.com

# Query specific record types
dig google.com A
dig google.com AAAA
dig google.com MX
dig google.com TXT
dig google.com NS

# Reverse lookup (IP → domain name)
dig -x 8.8.8.8

# Query a specific DNS server
dig @8.8.8.8 google.com
dig @1.1.1.1 google.com

# Trace the DNS resolution path
dig +trace google.com

# Check configured DNS resolver information
cat /etc/resolv.conf
```

### Wireshark DNS Display Filters

``` text
dns
dns.qry.name contains "example"
dns.flags.response == 1
```

-   `dns` --- displays DNS packets.
-   `dns.qry.name contains "example"` --- displays queries whose name
    contains `example`.
-   `dns.flags.response == 1` --- displays DNS responses.

------------------------------------------------------------------------

## 4. DHCP --- Dynamic Host Configuration Protocol

### A. Definition

DHCP automatically provides network configuration to devices.

  Property      Details
  ------------- ---------------------------------------------
  Full form     Dynamic Host Configuration Protocol
  Purpose       Automatically assigns network configuration
  Server port   UDP 67
  Client port   UDP 68

DHCP can provide:

-   IP address
-   Subnet mask
-   Default gateway
-   DNS server
-   Lease time

### B. Analogy

DHCP is similar to checking into a hotel:

-   **Discover:** The guest asks whether a room is available.
-   **Offer:** Reception offers a room.
-   **Request:** The guest requests that room.
-   **ACK:** Reception confirms the booking.

### C. DORA Process

DORA stands for **Discover, Offer, Request, Acknowledge**.

``` text
CLIENT                         DHCP SERVER
  |                                  |
  |---- DISCOVER ------------------->|
  |     "Is a DHCP server available?"|
  |                                  |
  |<--- OFFER -----------------------|
  |     "You can use this IP"        |
  |                                  |
  |---- REQUEST -------------------->|
  |     "I request this IP"          |
  |                                  |
  |<--- ACK -------------------------|
  |     "The IP assignment is        |
  |      confirmed"                  |
  |                                  |
```

  Step   Message             Purpose
  ------ ------------------- -------------------------------------------
  D      Discover            Client searches for DHCP servers
  O      Offer               Server offers an IP configuration
  R      Request             Client requests the offered configuration
  A      Acknowledge (ACK)   Server confirms the assignment

### D. DHCP Information

``` text
Client receives:

├── IP Address        192.168.1.50
├── Subnet Mask       255.255.255.0
├── Default Gateway   192.168.1.1
├── DNS Server        8.8.8.8
└── Lease Time        86400 seconds (24 hours)
```

> **Connection with Day 1:** `169.254.x.x` is an APIPA/link-local IPv4
> address. A device may self-assign one when it cannot obtain an IPv4
> address through DHCP.

------------------------------------------------------------------------

## 5. DHCP Attacks

### A. Rogue DHCP Server

An attacker introduces an unauthorized DHCP server into a network. It
may provide clients with incorrect network settings, such as a malicious
default gateway or DNS server.

``` text
Client sends DHCP Discover
          |
          v
Unauthorized DHCP server responds
          |
          v
Client receives incorrect configuration
          |
          v
Traffic may be redirected through attacker
```

**Possible indicators:**

-   DHCP Offers from an unknown MAC address.
-   Multiple DHCP servers responding to the same Discover.
-   Unexpected gateway or DNS server values.
-   More than one Offer during the same address-assignment process.

**Defenses:**

-   DHCP Snooping.
-   Switch port security.
-   Monitoring for unauthorized DHCP servers.
-   Correctly configured trusted switch ports.

### B. DHCP Starvation

An attacker floods a DHCP server with requests using many spoofed or
randomized MAC addresses. The available IP address pool can become
exhausted, preventing legitimate clients from obtaining addresses.

``` text
Attacker sends many DHCP requests
              |
              v
DHCP address pool becomes exhausted
              |
              v
Legitimate clients cannot obtain IPs
              |
              v
Some clients may self-assign APIPA addresses
```

**Possible indicators:**

-   Large numbers of DHCP Discover or Request messages.
-   Many different source MAC addresses in a short period.
-   DHCP pool exhaustion.
-   Legitimate clients failing to receive Offers.

**Defenses:**

-   DHCP Snooping with rate limiting.
-   Port Security and MAC limits.
-   802.1X authentication.

------------------------------------------------------------------------

## 6. DHCP Commands and Wireshark Filters

### DHCP Commands

``` bash
# Check DHCP lease information (location depends on distribution)
cat /var/lib/dhcp/dhclient.leases

# Alternative lease location used by some NetworkManager systems
cat /var/lib/NetworkManager/*.lease

# Release the current DHCP lease
sudo dhclient -r

# Request a DHCP lease with verbose output
sudo dhclient -v

# Check for the dhclient process
ps aux | grep dhclient
```

### Wireshark DHCP Display Filters

``` text
dhcp
bootp.type == 1
bootp.type == 2
bootp.type == 3
bootp.type == 5
```

    BOOTP message type DHCP message
  -------------------- --------------
                     1 Discover
                     2 Offer
                     3 Request
                     5 ACK

------------------------------------------------------------------------

## 7. HTTP --- HyperText Transfer Protocol

### A. Definition

HTTP is an application-layer protocol that allows web browsers and web
servers to exchange data.

  Property       Details
  -------------- --------------------------------------
  Full form      HyperText Transfer Protocol
  Purpose        Web communication
  Default port   TCP 80
  Security       HTTP traffic is not protected by TLS

### B. HTTP Request Structure

Example:

``` http
GET /index.html HTTP/1.1
Host: www.example.com
User-Agent: Mozilla/5.0
Accept: text/html
Connection: keep-alive
```

  Field           Purpose
  --------------- -------------------------------------
  GET             HTTP request method
  `/index.html`   Requested resource
  HTTP/1.1        HTTP version
  Host            Target host name
  User-Agent      Client/browser information
  Accept          Content types the client can accept
  Connection      Connection-related header

### C. HTTP Methods

  -----------------------------------------------------------------------
  Method                  Purpose                 SOC relevance
  ----------------------- ----------------------- -----------------------
  GET                     Retrieve data           Common browsing
                                                  activity

  POST                    Submit data             Login forms and data
                                                  submission

  PUT                     Create or replace a     Investigate unexpected
                          resource                modifications

  DELETE                  Delete a resource       Investigate unexpected
                                                  deletion

  HEAD                    Retrieve headers        May be used for
                          without the response    reconnaissance
                          body                    

  OPTIONS                 Ask which methods are   May be used for
                          supported               reconnaissance

  PATCH                   Partially update a      API modification
                          resource                
  -----------------------------------------------------------------------

> **SOC note:** PUT and DELETE requests are not automatically malicious.
> Their significance depends on the application, user, destination and
> expected behavior.

### D. HTTP Status Codes

    Code Meaning                 Possible SOC relevance
  ------ ----------------------- -------------------------------------------
     200 OK                      Successful request
     301 Moved Permanently       Redirect
     302 Found                   Temporary redirect
     400 Bad Request             Malformed request
     401 Unauthorized            Authentication required or failed
     403 Forbidden               Access denied
     404 Not Found               May appear during scanning or enumeration
     500 Internal Server Error   Application/server error
     503 Service Unavailable     Service overload or unavailability

**SOC investigation clues:**

-   Repeated `401` responses may indicate failed login attempts or
    brute-force activity.
-   Repeated `404` responses may indicate directory or resource
    scanning.
-   Repeated `403` responses may indicate access enumeration.
-   Repeated `500` responses may require investigation of application
    errors or possible exploitation.
-   Repeated `503` responses may indicate overload or a
    denial-of-service condition.

These patterns are indicators, not proof of an attack.

------------------------------------------------------------------------

## 8. HTTPS and TLS

### A. Definition

HTTPS is HTTP communication protected by TLS (Transport Layer Security).

  -----------------------------------------------------------------------
  Property                HTTP                    HTTPS
  ----------------------- ----------------------- -----------------------
  Default port            TCP 80                  TCP 443

  TLS protection          No                      Yes

  Application data in     Not encrypted by HTTP   Encrypted by TLS
  transit                                         

  Main security benefit   No built-in TLS         Confidentiality and
                          protection              integrity in transit;
                                                  server authentication
                                                  through certificates
  -----------------------------------------------------------------------

### B. HTTP vs HTTPS

``` text
HTTP:
Browser -------- Plaintext data --------> Server

HTTPS:
Browser -------- Encrypted data --------> Server
```

HTTPS protects data in transit. It does not automatically mean a website
is trustworthy or protect against every type of attack.

### C. TLS Handshake --- Simplified

``` text
CLIENT                              SERVER
  |                                    |
  |-------- ClientHello -------------->|
  |  Supported TLS versions,            |
  |  cipher suites and key-share data  |
  |                                    |
  |<------- ServerHello ---------------|
  |  Selected parameters and           |
  |  server handshake information      |
  |                                    |
  |  Client validates server           |
  |  certificate and its trust chain   |
  |                                    |
  |<==== Key establishment ===========>|
  |                                    |
  |<==== Encrypted communication =====>|
```

The client and server negotiate cryptographic parameters and establish
shared session keys. The certificate helps the client authenticate the
server.

> **SOC note:** A failed TLS handshake can be caused by certificate
> expiry, trust problems, incompatible TLS settings, network
> interference or a possible interception attempt. A handshake failure
> alone does not prove a MITM attack.

------------------------------------------------------------------------

## 9. HTTP/HTTPS Commands and Wireshark Filters

### Commands

``` bash
# Send an HTTP request and show verbose details
curl -v http://example.com

# Send an HTTPS request and show verbose details
curl -v https://example.com

# Retrieve response headers
curl -I https://example.com

# Inspect a server's TLS connection and certificate
openssl s_client -connect example.com:443

# Send a POST request
curl -X POST -d "user=admin&pass=test" http://example.com/login
```

### Wireshark Display Filters

``` text
http
http.request.method == "POST"
http.response.code == 404
http.host contains "suspicious"
tls
tls.handshake.type == 1
```

-   `http` --- displays HTTP packets.
-   `http.request.method == "POST"` --- displays HTTP POST requests.
-   `http.response.code == 404` --- displays HTTP responses with status
    code 404.
-   `http.host contains "suspicious"` --- filters HTTP Host values
    containing the specified text.
-   `tls` --- displays TLS packets.
-   `tls.handshake.type == 1` --- displays TLS ClientHello messages.

**Packet visibility:**

-   Plain HTTP application data can generally be read in a packet
    capture.
-   HTTPS application data is encrypted; a normal packet capture does
    not reveal the webpage content.
-   TLS handshake metadata may still be visible, depending on the TLS
    version and handshake stage.

------------------------------------------------------------------------

## 10. Troubleshooting Scenarios

### Scenario A --- Domain Does Not Open, but IP Works

> A user cannot open `google.com`, but can reach `142.250.80.46` by IP
> address.

Consider:

1.  Is name resolution failing?
2.  Is DNS the likely service to investigate?
3.  What would `nslookup google.com` or `dig google.com` show?
4.  Could the configured DNS server be unavailable or incorrect?
5.  Could a local cache or hosts-file entry be causing the problem?

### Scenario B --- Some PCs Receive 169.254.x.x Addresses

> Thirty office PCs receive `169.254.x.x` addresses, while the remaining
> PCs work normally.

Consider:

1.  Did the DHCP address-assignment process fail?
2.  Are the affected clients able to reach the DHCP server?
3.  Is the DHCP pool exhausted or is a network segment affected?
4.  Could a rogue DHCP server or DHCP starvation be involved?
5.  What DHCP packets and source MAC addresses would you inspect in
    Wireshark?

------------------------------------------------------------------------

## 11. Interview Questions

### Level 1 --- Fundamentals

1.  What is DNS, what does it do, and which port does it use?
2.  What is the difference between an A record and an AAAA record?
3.  What is DHCP?
4.  What are the four steps of the DORA process?

### Level 2 --- Protocol Understanding

5.  Explain the DNS resolution process.
6.  What information can DHCP provide to a client?
7.  What is the difference between HTTP and HTTPS?
8.  What do HTTP status codes 200, 301, 401, 403 and 404 mean?
9.  What happens during a TLS handshake?

### Level 3 --- Troubleshooting

10. A user can access a website by IP but not by domain name. What would
    you investigate?
11. Why might a device receive a `169.254.x.x` address?
12. How would you identify an unexpected DHCP server?

### Level 4 --- SOC Analysis

13. How would you identify possible DNS tunneling in Wireshark?
14. Which indicators might suggest DNS spoofing or cache poisoning?
15. What is DNS amplification?
16. What is the difference between a rogue DHCP server and DHCP
    starvation?
17. What might repeated HTTP 401 or 404 responses indicate?
18. If a SIEM reports 500 DNS queries per minute from one host, what
    would you investigate before deciding on containment?

------------------------------------------------------------------------

## 12. Cybersecurity Connection

  -----------------------------------------------------------------------
  Protocol          Normal use        Example attacks   Possible
                                                        detection
                                                        indicators
  ----------------- ----------------- ----------------- -----------------
  DNS               Domain name       Spoofing,         High query
                    resolution        tunneling,        volume, long
                                      amplification     subdomains,
                                                        unusual TXT
                                                        queries,
                                                        unexpected
                                                        responses

  DHCP              Automatic IP      Rogue DHCP,       Unknown DHCP
                    configuration     starvation        server, multiple
                                                        Offers, pool
                                                        exhaustion, APIPA
                                                        addresses

  HTTP              Web communication MITM, credential  Plaintext
                                      exposure, web     sensitive data,
                                      attacks           unusual methods,
                                                        abnormal
                                                        status-code
                                                        patterns

  HTTPS             Encrypted web     Certificate       Certificate
                    communication     abuse, downgrade  warnings,
                                      or interception   unexpected TLS
                                      attempts          behavior,
                                                        handshake
                                                        failures
  -----------------------------------------------------------------------

------------------------------------------------------------------------

##  Key Takeaways

1.  **DNS** resolves domain names to IP addresses and commonly uses port
    53.
2.  **DHCP** automatically provides network configuration and uses UDP
    ports 67 and 68.
3.  **DORA** means Discover → Offer → Request → Acknowledge.
4.  **APIPA (`169.254.x.x`)** can appear when a client cannot obtain an
    IPv4 address through DHCP.
5.  **HTTP** commonly uses TCP port 80; **HTTPS** commonly uses TCP port
    443.
6.  **HTTPS** uses TLS to protect application data in transit.
7.  **DNS tunneling** may be indicated by long subdomains, unusual query
    patterns and high DNS volume.
8.  **SOC analysis** requires investigating context and correlating
    indicators instead of treating one unusual packet or status code as
    proof of an attack.
