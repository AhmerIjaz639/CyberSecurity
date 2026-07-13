## Date : 13/7/2026
## 📝 Level Writeups (Continued)

### Level 8 → 9: Finding Human-Readable Text in Binary

**Task:** The password is in `data.txt` somewhere. Find human-readable strings 
that come after several `=` characters.

**How I did it:**

First I tried `cat data.txt` and got a screen full of weird symbols. It's a 
binary file with some readable text hidden inside. That's when `strings` command 
became useful.

```bash
strings data.txt
```

This gave me a huge list of readable text scattered throughout the file. But I 
needed the one after `==` characters. So I piped it to grep:

```bash
strings data.txt | grep "=="
```

Output showed a few lines:
```
========== the
[==p+
========== password
Y========== is
========== [PASSWORD HERE]
```

The password was clearly in the last line. Interesting how they broke the 
sentence "the password is [PASSWORD]" into pieces to make us work for it.

**Learning:** 
- `strings` extracts readable text from binary files
- Useful in real forensics (finding hardcoded strings in malware)
- Piping strings to grep is a common technique

---

### Level 9 → 10: Base64 Decoding

**Task:** File contains base64 encoded text. Decode it to find password.

**How I did it:**

Opened the file first:

```bash
cat data.txt
```

Saw this line:
```
VGhlIHBhc3N3b3JkIGlzIHBZZk9ZNkh3VXNEajVyTDlVdnloVTdNQ212OHZONVJvCg==
```

The `==` at the end was a big clue — that's how base64 encoded strings often 
end. Also all letters/numbers, no special chars, looks like base64 to me.

Decoded it with:

```bash
base64 -d data.txt
```

Output:
```
The password is [PASSWORD]
```

Easy level after understanding what base64 looks like.

**Learning:**
- Base64 encoding is common in cybersecurity (emails, tokens, cookies)
- `-d` flag means decode
- Recognizing base64: alphanumeric + `+/=` characters, ends with `=` often
- Attackers often base64 encode payloads to avoid detection

---

### Level 10 → 11: ROT13 Cipher

**Task:** Decrypt text where every letter is shifted 13 positions in alphabet.

**How I did it (with mistakes!):**

This one I struggled with. My first attempt:

```bash
cat data.txt | tr "N-Zn-z" "A-Ma-m"
```

Got wrong output that looked like gibberish still.

Then I realized ROT13 shifts BOTH ways — A→N and N→A. So I need to swap both 
halves:

```bash
cat data.txt | tr 'A-Za-z' 'N-ZA-Mn-za-m'
```

**Correct output:**
```
The password is [PASSWORD]
```

**Breaking down the command:**
- `tr` translates characters
- `A-Za-z` = all letters (source)
- `N-ZA-Mn-za-m` = shifted alphabet (target)
- So A→N, B→O, ..., M→Z, N→A, ..., Z→M
- Same for lowercase

**Learning:**
- ROT13 is symmetric — applying it twice gives original text back
- Common in CTFs and old-school cryptography
- `tr` command is powerful for character substitution
- I made mistakes but figured out the correct pattern

---

### Level 11 → 12: Multiple Compression Formats (THE HARDEST ONE!)

**Task:** File is a hexdump. Decode it, then decompress it many times with 
different formats until you find the password.

**How I did it (long journey!):**

This level took me about 45 minutes. It's like unwrapping an onion — each layer 
is a different compression type.

**Step 1: Setup working directory** (because home is read-only)

```bash
mkdir /tmp/mywork
cd /tmp/mywork
cp ~/data.txt .
```

**Step 2: Convert hexdump back to binary**

Since it was a hexdump, I reversed it:

```bash
xxd -r data.txt > data.bin
file data.bin
```

Output: `gzip compressed data`

**Step 3: Decompress gzip**

```bash
mv data.bin data.gz
gunzip data.gz
file data
```

Output: `bzip2 compressed data`

**Step 4: Decompress bzip2**

```bash
mv data data.bz2
bunzip2 data.bz2
file data
```

Output: `gzip compressed data` (again!)

**Step 5: Decompress gzip again**

```bash
mv data data.gz
gunzip data.gz
file data
```

Output: `POSIX tar archive`

**Step 6: Extract tar**

```bash
mv data data.tar
tar xf data.tar
```

Now I had `data5.bin`. Kept going:

**Step 7: More extractions**

```bash
file data5.bin           # tar archive
tar xf data5.bin         # extracted data6.bin

file data6.bin           # bzip2
mv data6.bin data6.bz2
bunzip2 data6.bz2

file data6               # tar again!
mv data6 data6.tar
tar xf data6.tar

# Got data8.bin
file data8.bin           # gzip
mv data8.bin data8.gz
gunzip data8.gz

file data8               # ASCII text FINALLY!
cat data8
```

**Output:**
```
The password is [PASSWORD]
```

**My mistakes along the way:**
- Typed `mz` instead of `mv` once (typo)
- Tried `bunzip2 data6.bin` instead of renaming to `.bz2` first
- Got confused about which file to work with when many similar names existed
- Kept forgetting to check with `file *` to see current state

**Learning:**
- The `file` command is CRUCIAL — always check what you're dealing with
- Rename files with correct extensions before decompressing
- Different compression tools: `gunzip` for .gz, `bunzip2` for .bz2, `tar xf` for tar
- This is EXACTLY like real malware analysis — often payloads are compressed 
  multiple times to hide from antivirus
- Patience matters — 6-7 rounds of decompression felt endless

**Real-world connection:**
Attackers do this exact thing. They pack malware in multiple layers of 
compression/encoding to evade detection. As a defender, you'd unwrap it just 
like this to analyze the actual payload.

---

## 📊 Progress Update

**Now at:** Level 13  
**Completed:** 12/34 levels ✅

### What I Can Do Now

Combining everything learned so far, I can:
- Handle any file type (binary, text, compressed, encoded)
- Extract readable content from anything
- Decode multiple encoding schemes
- Work through multi-layered challenges
- Debug my own mistakes methodically

---

## 💭 Honest Reflection

Level 12 was HARD. I nearly gave up around round 4 of decompression. But I kept 
running `file` to check what I had, and slowly worked through it.

The biggest lesson: **Don't rush. Check every step.** When I made typos or 
forgot to rename files, I lost time. Being methodical saves you in the long run.

Also — this is exactly why we practice. If I encounter this in a real 
investigation (like analyzing a malicious email attachment), now I know the 
process. Muscle memory building! 💪

---

## 🔑 New Commands Added to My Toolkit

| Command | What it does |
|---------|--------------|
| `strings file` | Extract readable text from binary |
| `base64 -d` | Decode base64 encoded data |
| `tr 'A-Za-z' 'N-ZA-Mn-za-m'` | ROT13 decryption |
| `xxd -r` | Reverse hex dump back to binary |
| `gunzip file.gz` | Decompress gzip |
| `bunzip2 file.bz2` | Decompress bzip2 |
| `tar xf file.tar` | Extract tar archive |
| `file *` | Check type of all files in folder |
| `mktemp -d` | Create random-named temp directory |

---

## 🎯 What's Next

Level 13 introduces SSH keys — a huge concept in real cybersecurity work. 
Every system admin, every DevOps engineer, every pentester uses SSH keys daily.

Looking forward to it!
