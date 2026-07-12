# 🎯 OverTheWire Bandit — My Learning Journey

Hey! I'm working through the OverTheWire Bandit wargame to build my Linux skills 
for cybersecurity. This repo has my writeups and notes as I go through each level.

Sharing this in case it helps others learning the same stuff. Not spoiling the 
passwords, just explaining the approach and commands I used.

---

## 📊 Progress

**Currently at:** Level 6  
**Completed:** 6/34 levels  
**Started:** 12/7/2026

---

## 🔧 What I've Learned So Far

Just from the first 6 levels, I've picked up:

- SSH basics (connecting to remote servers)
- Handling weird filenames (dashes, spaces, dots)
- Finding hidden files
- Using the `file` command to check file types
- Advanced `find` with size and permission filters
- Reading files that start with `-` (harder than it sounds!)

---

## 📝 Level Writeups

### Level 0 → 1: Getting Started

**Task:** Log in with SSH and find the password in the readme file.

**How I did it:**

```bash
ssh bandit0@bandit.labs.overthewire.org -p 2220
# Password: bandit0

ls
cat readme
```

Simple stuff, but important — I learned SSH takes the port with `-p`. Also 
noticed the password won't show as you type (security thing).

**Tricky part:** I typed the password wrong twice. Turns out you have to be 
careful, no visual feedback.

---

### Level 1 → 2: The Dash File

**Task:** Read a file literally named `-` (just a dash).

**Why it's hard:** If you just do `cat -`, the terminal thinks you want to type 
input manually. It waits forever.

**How I did it:**

```bash
ls          # File is called "-"
cat ./-     # The ./ tells cat "this is a file, not an option"
```

**Learning:** In Linux, `-` usually means "read from input" for many commands. 
So you need `./` before it to say "no, this is actually a file path".

---

### Level 2 → 3: Spaces in Filenames

**Task:** Read a file called `spaces in this filename` (with spaces!).

**How I struggled first:**

I tried a bunch of things that didn't work:
```bash
cat "spaces in this filename"      # Wrong filename (missed characters)
cat 'spaces i this filename'       # Same problem
cat spaces\ i\ this\ filename      # Still wrong
```

**Then I realized the actual filename had extra dashes:**

```bash
ls
# Output: --spaces in this filename--

# Since filename starts with --, cat thinks it's an option
# Fix: Use -- to say "no more options after this"

cat -- "--spaces in this filename--"
```

**Learning:** The `--` trick is really useful! It tells commands "stop looking 
for options, everything after this is a file/argument."

---

### Level 3 → 4: Hidden Files with Dots

**Task:** Find password in a hidden file inside the `inhere` folder.

**How I did it:**

```bash
cd inhere
ls              # Nothing shown!
ls -a           # Now I see: . .. ...Hiding-From-You

cat ./...Hiding-From-You
```

**Tricky part:** Files starting with `.` are hidden. You need `-a` flag to see 
them. Also, the filename had `...` (three dots) at the start which is unusual.

**Mistake I made:** Typed "Hinding" instead of "Hiding" twice. Tab completion 
would have saved me!

---

### Level 4 → 5: Finding the Text File

**Task:** Multiple files in a folder, but only ONE is human-readable. Find it.

**How I approached it:**

```bash
cd inhere
ls              # Files: -file00 to -file09
```

Since files start with `-`, I need `--` again. But I had to check each file to 
find the readable one. Instead of trying all manually, I could have used `file`:

```bash
file ./*        # Shows type of each file
# Look for one that says "ASCII text"
```

But I just checked each with cat until I found readable text:

```bash
cat -- -file07  # This one was ASCII text
```

Others showed weird symbols (binary files). File 07 was the answer.

**Learning:** The `file` command is smarter — tells you file type without 
opening it. Would've been faster than trial and error.

---

### Level 5 → 6: The find Command Power

**Task:** Find a file with these properties:
- Human-readable
- 1033 bytes exactly
- Not executable

**How I did it:**

Started with a broad search:

```bash
cd inhere
find / -type f -size 1033c
```

Got tons of permission errors and results from all over the system. Cleaned it up:

```bash
find / -type f -size 1033c ! -executable 2>/dev/null
```

Found my target: `/home/bandit5/inhere/maybehere07/.file2`

```bash
cat /home/bandit5/inhere/maybehere07/.file2
```

**Breaking down the command:**
- `find /` → search from root
- `-type f` → only files, not folders
- `-size 1033c` → exactly 1033 bytes (c = bytes)
- `! -executable` → NOT executable (the ! means "not")
- `2>/dev/null` → hide all the permission errors

**Learning:** The `2>/dev/null` part is a lifesaver. Without it, terminal gets 
flooded with "Permission denied" messages. This throws all errors into the void.

---

## 🎓 Key Commands I've Learned

| Command | What it does |
|---------|--------------|
| `ssh user@host -p 2220` | Connect to remote server on port 2220 |
| `ls -a` | List all files including hidden ones |
| `cat ./file` | Read file (safe way for weird names) |
| `cat -- filename` | Read file when name starts with `-` |
| `file *` | Check what type files are |
| `find / -size Nc` | Find files of exact size N bytes |
| `find / ! -executable` | Find non-executable files |
| `2>/dev/null` | Hide error messages |

---

## 🎯 What's Next

Working on Level 6 → 7 next (finding files by owner and group). Then more grep, 
sort, uniq stuff coming up.

My plan: Complete Level 15 in the next 2 weeks (matches with my cybersecurity 
bootcamp Module 2 - Linux Mastery).

---

## 💭 Honest Thoughts

These challenges are actually fun once you get into them. Each level teaches 
something specific and you can't fake it — either you find the password or you 
don't.

The best part is that everything I'm learning here applies to real cybersecurity 
work. Like, that `find` command from Level 5? That's literally what pentesters 
use to find SUID binaries during privilege escalation.

If you're just starting cybersecurity, I highly recommend Bandit. It's free and 
teaches you Linux in a way that actually sticks.

---

## 📚 Useful Resources

- [OverTheWire Official](https://overthewire.org/wargames/bandit/)
- [Man pages](https://man7.org/linux/man-pages/) — always check `man command`
- Tab completion is your friend!

---

## ⚠️ Note About Passwords

I'm not posting the actual passwords here (that would ruin it for others). Just 
explaining the approach. If you're stuck on a level, try to work through the 
logic — that's where the real learning happens.

---

**Last Updated:** [Add current date]  
**Total Time Spent:** ~3 hours so far  
**Difficulty So Far:** Beginner-friendly, but Level 5 was tricky
