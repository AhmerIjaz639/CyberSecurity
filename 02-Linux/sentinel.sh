#!/bin/bash

REPORT="audit_report.txt"

echo "==========================================" > $REPORT
echo "      SENTINEL LINUX SECURITY AUDIT       " >> $REPORT
echo "      Date: $(date)                       " >> $REPORT
echo "==========================================" >> $REPORT

# 1. User Audit
echo -e "\n[!] Checking for UID 0 users..." >> $REPORT
awk -F: '$3 == 0 {print $1}' /etc/passwd >> $REPORT

# 2. Network Audit
echo -e "\n[!] Checking for listening ports..." >> $REPORT
ss -tulpn | grep LISTEN >> $REPORT

# 3. Persistence Check
echo -e "\n[!] Checking for enabled services (Persistence)..." >> $REPORT
systemctl list-unit-files --state=enabled | grep -E "backdoor|shell|temp|update" >> $REPORT

echo -e "\n[!] Checking Cron Jobs..." >> $REPORT
ls -la /etc/cron.* >> $REPORT

# 4. SUID Check
echo -e "\n[!] Top 10 SUID binaries (Potential PrivEsc)..." >> $REPORT
find / -perm -4000 -type f 2>/dev/null | head -10 >> $REPORT

# 5. File Integrity
echo -e "\n[!] Checking for world-writable files in /tmp..." >> $REPORT
find /tmp -perm -o+w -type f 2>/dev/null >> $REPORT

echo "==========================================" >> $REPORT
echo "Audit Complete. Report saved to $REPORT"
