

#  OverTheWire Bandit — Level 6 → 8 Writeups

Continuing my OverTheWire Bandit journey to improve my Linux and cybersecurity 
skills.

This section covers Levels **6 to 8**, where I practiced searching files across 
the system, filtering results using permissions and ownership, and using powerful 
text-processing commands like `sort` and `uniq`.

No passwords are shared here — only the methods, commands, and concepts learned.

---

## 📊 Progress

**Currently at:** Level 10
**Completed:** 9/34 levels  

---

# 📝 Level Writeups

---

## Level 6 → 7: Finding Files by Owner, Group, and Size

### Task:

Find a file somewhere on the server that:

- Is owned by user `bandit7`
- Belongs to group `bandit6`
- Has a size of exactly 33 bytes

---

### How I approached it:

At first, searching the whole system gave many permission errors.

I used:

```bash
find / -type f -user bandit7 -group bandit6 -size 33c 2>/dev/null
````

---

### Breaking down the command:

```
find /
```

Search the entire filesystem starting from root.

```
-type f
```

Only search normal files, not directories.

```
-user bandit7
```

Find files owned by user bandit7.

```
-group bandit6
```

Find files belonging to group bandit6.

```
-size 33c
```

File size must be exactly 33 bytes.

`c` means bytes.

```
2>/dev/null
```

Hide permission denied errors.

---

### After finding the file:

I used:

```bash
cat /path/to/found/file
```

This displayed the password for the next level.

---

### What I Learned:

This level improved my understanding of Linux permissions and ownership.

The `find` command is extremely powerful for system enumeration.

In cybersecurity, attackers and defenders often search systems using similar
filters to locate important files.

---

# Level 7 → 8: Searching Inside Large Files

### Task:

Find the password inside a file called `data.txt`.

The password is next to the word:

```
millionth
```

---

### My approach:

Instead of manually reading thousands of lines, I searched directly:

```bash
grep "millionth" data.txt
```

---

### Output:

The command returned the matching line containing the password.

---

### Breaking down the command:

```
grep
```

Searches for text patterns inside files.

```
"millionth"
```

The keyword I wanted to find.

```
data.txt
```

The file where grep searched.

---

### Learning:

`grep` is one of the most important Linux commands.

It is useful for:

* Searching logs
* Finding configuration values
* Analyzing files
* Filtering command output

Example:

```bash
cat /var/log/auth.log | grep failed
```

This can search failed login attempts.

---

# Level 8 → 9: Finding the Unique Line

### Task:

Find the only line in `data.txt` that appears once.

Most lines are repeated, but one line is unique.

---

### First attempt:

I checked the file:

```bash
cat data.txt
```

The file was too large, so manually checking was impossible.

---

### Better solution:

I used:

```bash
sort data.txt | uniq -u
```

---

### Breaking down the command:

## sort

```bash
sort data.txt
```

Sorts all lines alphabetically.

`uniq` only works correctly when duplicate lines are next to each other, so sorting is required first.

---

## uniq

```bash
uniq -u
```

Shows only lines that appear exactly once.

`-u` means:

```
unique lines only
```

---

### Pipeline:

```bash
sort data.txt | uniq -u
```

The `|` pipe sends the output of one command into another.

Flow:

```
data.txt
    |
    v
 sort
    |
    v
 uniq -u
    |
    v
 unique line
```

---

### Extra Verification:

I confirmed the result using:

```bash
grep -n "unique_text" data.txt
```

Output showed the line number where it existed.

---

# 🎓 New Commands Learned

| Command                   | Purpose                         |
| ------------------------- | ------------------------------- |
| `find / -user username`   | Find files owned by a user      |
| `find / -group groupname` | Find files belonging to a group |
| `find -size Nc`           | Search files by exact size      |
| `2>/dev/null`             | Hide error messages             |
| `grep "text" file`        | Search text inside files        |
| `sort file`               | Sort lines alphabetically       |
| `uniq -u`                 | Show only unique lines          |
| `command1 \| command2`    | Pipe output between commands    |

---

# 🧠 Cybersecurity Connections

These levels taught concepts used in real security work:

## File Enumeration

Attackers and penetration testers often search systems for:

* Sensitive files
* Misconfigured permissions
* Interesting ownership patterns

Example:

```bash
find / -perm -4000 2>/dev/null
```

Finding SUID binaries during privilege escalation.

---

## Log Analysis

`grep` is heavily used in:

* SOC operations
* Incident response
* Threat hunting

Example:

```bash
grep "failed password" /var/log/auth.log
```

---

## Data Processing

Commands like:

```bash
sort
uniq
grep
awk
cut
```

are essential for analyzing large amounts of security data.

---

# 💡 Main Lessons From Level 6-9

✅ Advanced `find` filtering
✅ Linux ownership and groups
✅ Searching large files efficiently
✅ Using pipes between commands
✅ Text processing with grep, sort, and uniq

---

# 🎯 What's Next

Moving towards:

* More Linux command practice
* Advanced text processing
* File permissions
* Networking basics
* Cybersecurity enumeration techniques

---

# ⚠️ Note About Passwords

Passwords are intentionally not included.

The goal of Bandit is to learn the methodology, not just collect answers.

Understanding the commands and thinking process is what builds real Linux and
cybersecurity skills.

---

**Last Updated:** 7/12/2026

**Completed Levels:** 9/34

**Difficulty:** Beginner → Intermediate

**Current Focus:** Linux fundamentals for cybersecurity


