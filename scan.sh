#!/bin/bash

domain=$1

if [ -z "$domain" ]; then
  echo "Usage: ./scan.sh domain.com"
  exit 1
fi

DATE=$(date +%Y-%m-%d_%H-%M)
OUT="scan_$domain_$DATE"

mkdir -p $OUT
cd $OUT

echo "🔥 Starting ULTIMATE recon on $domain"
echo "Output folder: $OUT"

# ----------------------------
# 1. SUBDOMAIN ENUM
# ----------------------------
echo "[1/8] Subdomain enumeration..."
subfinder -d $domain -silent > subs.txt
assetfinder --subs-only $domain >> subs.txt
amass enum -passive -d $domain >> subs.txt
sort -u subs.txt > final-subs.txt

# ----------------------------
# 2. LIVE HOSTS
# ----------------------------
echo "[2/8] Checking live hosts..."
cat final-subs.txt | httpx -silent -status-code -title -tech-detect -json > live.json
cat live.json | jq -r '.host' > live.txt

# ----------------------------
# 3. PORT SCAN (light)
# ----------------------------
echo "[3/8] Port scanning..."
nmap -iL live.txt -T4 -F -oN ports.txt

# ----------------------------
# 4. URL DISCOVERY
# ----------------------------
echo "[4/8] Gathering URLs..."
katana -list live.txt -silent > katana.txt
waybackurls $domain >> katana.txt
gau $domain >> katana.txt
sort -u katana.txt > urls.txt

# ----------------------------
# 5. FILTER INTERESTING
# ----------------------------
echo "[5/8] Filtering interesting endpoints..."
grep -E "\.php|\.json|\.env|\.bak|admin|login|api|config" urls.txt > interesting.txt

# ----------------------------
# 6. VULN SCAN
# ----------------------------
echo "[6/8] Running nuclei..."
nuclei -l live.txt -silent -severity low,medium,high,critical -o vulns.txt

# ----------------------------
# 7. QUICK FUZZ (SAFE LIMIT)
# ----------------------------
echo "[7/8] Light fuzzing..."
head -n 10 live.txt | while read url; do
  ffuf -u "$url/FUZZ" -w -w wordlist.txt -mc 200,403 -t 30 -maxtime 60 >> fuzz.txt
done

# ----------------------------
# 8. REPORT
# ----------------------------
echo "[8/8] Generating report..."

echo "==== SUMMARY ====" > report.txt
echo "Domain: $domain" >> report.txt
echo "Date: $DATE" >> report.txt
echo "" >> report.txt

echo "Subdomains: $(wc -l < final-subs.txt)" >> report.txt
echo "Live hosts: $(wc -l < live.txt)" >> report.txt
echo "URLs found: $(wc -l < urls.txt)" >> report.txt
echo "Interesting endpoints: $(wc -l < interesting.txt)" >> report.txt
echo "Vulnerabilities: $(wc -l < vulns.txt)" >> report.txt

echo "" >> report.txt
echo "Top vulnerabilities:" >> report.txt
head -n 20 vulns.txt >> report.txt

echo "" >> report.txt
echo "Top interesting URLs:" >> report.txt
head -n 20 interesting.txt >> report.txt

echo "" >> report.txt
echo "Live hosts sample:" >> report.txt
head -n 10 live.txt >> report.txt

echo "✅ DONE!"
echo "📁 Folder: $OUT"
echo "📄 Report: $OUT/report.txt"
