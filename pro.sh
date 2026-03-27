#!/bin/bash

# Improved Bug Bounty Recon & Scan Script
# Optimized for speed and real-world parameters

DOMAIN=$1
THREADS=50

if [ -z "$DOMAIN" ]; then
  echo "Usage: ./pro.sh domain.com"
  exit 1
fi

mkdir -p output
cd output

echo "[*] Gathering subdomains..."
# Using subfinder (passive) and httpx (active verification)
subfinder -d $DOMAIN -silent -t $THREADS | httpx -silent -threads $THREADS > live.txt

echo "[*] Collecting REAL parameters (Wayback/GAU)..."
# Instead of guessing ?id=1, we fetch actual indexed parameters
echo $DOMAIN | gau --subs --threads $THREADS | grep "=" | head -n 1000 > params.txt

echo "[*] Testing for XSS (Dalfox - Automated Fuzzer)..."
# Dalfox is faster and smarter than curl + grep
cat params.txt | dalfox pipe --silent --worker $THREADS --output xss.txt

echo "[*] Testing for SQLi (Ffuf - Error-based pattern matching)..."
# Using ffuf to match specific SQL error strings in responses
ffuf -w params.txt -u "FUZZ'" -mr "SQL syntax|mysql_|ORA-|PostgreSQL" -t $THREADS -s >> sqli.txt

echo "[*] Running Nuclei (Critical & High severity)..."
# Scans for known CVEs and misconfigurations
nuclei -l live.txt -severity critical,high -silent -o nuclei_results.txt

echo "[*] Final Filter..."
cat xss.txt sqli.txt nuclei_results.txt > FINAL.txt

echo "✅ DONE → output/FINAL.txt"
