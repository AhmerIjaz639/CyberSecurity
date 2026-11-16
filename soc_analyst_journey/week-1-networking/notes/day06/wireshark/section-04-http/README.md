# Section 4 - HTTP Analysis

## Goal

Read HTTP requests and responses, find web attacks, and extract files from a capture.

## Why plain HTTP still matters

- Old internal apps, routers and cameras still use it
- Malware droppers often download their next stage over plain HTTP
- Anyone on the path can read passwords and cookies sent over HTTP
- Web attacks (SQL injection, XSS, path traversal) are fully visible in the URL and body

## Methods

| Method | Use | SOC note |
|--------|-----|----------|
| GET | Fetch data | Scans and parameter attacks |
| POST | Send data | Logins, uploads, exfiltration |
| HEAD | Headers only | Recon by scanners |
| PUT | Create a file | Web shell placement |

## Response codes

| Code | Meaning | Note |
|------|---------|------|
| 200 | OK | The request worked |
| 301/302 | Redirect | Check where it goes |
| 401 | Unauthorized | Possible brute force |
| 403 | Forbidden | Blocked |
| 404 | Not found | Scanning noise |
| 500 | Server error | Input broke the application |

## Filters

```
http
http.request.method == "POST"
http.response.code == 200
http.request.uri contains "admin"
http.user_agent contains "sqlmap"
```

## Useful features

- Follow HTTP stream: right click, Follow, HTTP Stream. Request in red, response in blue.
- Executable on the wire: `Content-Type: application/x-msdownload` and the bytes `MZ` (4D 5A).
- Extract files: File, Export Objects, HTTP.

## Practice 1 (medium): attack on 10.0.0.10 from 192.168.1.50

```
GET /product.php?id=1                       -> 200 OK
GET /product.php?id=1'                      -> 500 (SQL syntax error)
GET /product.php?id=1' UNION SELECT 1,username,password FROM users--   -> 200 OK
```

1. Attack: SQL injection. My answer was correct. The single quote was the test, the UNION SELECT was the data theft.
2. Result: packet 4 returned 500, which told the attacker the page is injectable. Packet 6 returned 200 with data, so it succeeded. My answer matched.
3. Filter. My answer: `ip.addr==192.168.1.50&& http.request.uri contains "UNIOIN"`. The word was misspelled. Correct:

```
ip.src == 192.168.1.50 && http.request.uri contains "UNION"
```

## Practice 2 (hard): web shell upload

```
POST /invoices/upload.php   (file: shell.php)      -> 200 OK
GET  /invoices/uploads/shell.php?cmd=whoami         -> 200 OK, body: www-data
```

I did not know these answers when I first tried. The correct ones:

1. Attack chain: unrestricted file upload, then web shell, then remote code execution (RCE).
2. Packet 5 runs the system command `whoami` through the shell. Packet 6 returns `www-data`, the web server account, so commands now run on the server.
3. Extract the file: File, Export Objects, HTTP, select `shell.php`, Save.
4. Filter:

```
http.request.method == "POST" && http.response.code == 200
```

Note: in a real capture, the response is a separate packet, so a filter that checks both a request and a response field on the same packet will not match. Wireshark links them with `http.response_in` / `http.request_in`, or I can look at the response filter on its own and follow the stream.

## What I learned

- A 500 after a quote in a parameter is a strong sign of injection testing. A 200 with extra data afterwards means it worked.
- Always check the response, not only the request, to know if an attack succeeded.
- Upload then execute is a very common web attack chain.

## Still to practise

- Web shell and RCE understanding
- Doing Export Objects on a real capture
