# Section 2 - Capture and Display Filters

## Goal

Cut a large capture down to only the packets that matter, using correct filter syntax.

## Capture filter vs display filter

| | Capture filter | Display filter |
|---|----------------|----------------|
| When | Before capturing | After capturing |
| Effect | Packets not matching are never saved | Packets are only hidden |
| Syntax | BPF, for example `host 10.0.0.5 and port 80` | Wireshark syntax, for example `ip.addr == 10.0.0.5 && tcp.port == 80` |

Use a capture filter when the capture would be huge. Use display filters for analysis, because nothing is lost.

## Operators

| Operator | Meaning |
|----------|---------|
| `==` | equals (a single `=` is wrong) |
| `!=` | not equal |
| `&&` or `and` | both must match |
| `\|\|` or `or` | either can match |
| `!` or `not` | exclude |
| `contains` | field contains a string |
| `( )` | group conditions |

The filter bar colour helps: green is valid, red is invalid syntax.

## Examples

```
ip.addr == 142.250.196.78 && http
ip.addr == 142.250.196.78 && tcp.port == 80
ip.addr == 185.10.50.20 && (tcp.port == 4444 || tcp.port == 8080) && !arp
```

Brackets matter. Without them the `||` would split the whole filter in the wrong place.

## Practice

Medium: show traffic with a specific server IP that is HTTP or on port 80.

My answer:

```
ip.addr==142.250.196.78 && http / tcp.port==80
```

Feedback: the idea was right but `/` is not a valid operator, so the bar turns red. Correct versions:

```
ip.addr == 142.250.196.78 && http
ip.addr == 142.250.196.78 && tcp.port == 80
```

Hard: show traffic with attacker IP 185.10.50.20 on port 4444 or 8080 and remove ARP noise.

My answer:

```
ip.addr==185.10.50.20 && (tcp.port==4444 || tcp.port==8080) && !arp
```

Feedback: correct. Brackets and the `!arp` exclusion were used properly.

## What I learned

- Combine IP, port and protocol in one filter to narrow quickly.
- Always group `||` conditions in brackets.
- Check the filter bar colour before trusting the result.

## Still to practise

- Writing the capture filter (BPF) versions of the same filters
