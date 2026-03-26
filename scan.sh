#!/bin/bash

DOMAIN=$1

if [ -z "$DOMAIN" ]; then
  echo "Usage: ./scan.sh domain.com"
  exit 1
fi

mkdir -p output
cd output

echo "🔎 Finding subdomains..."
subfinder -d $DOMAIN -silent -o subs.txt

echo "🌐 Checking live domains..."
httpx -l subs.txt -silent -o live.txt

echo "🧨 Running scan..."
nuclei -l live.txt -silent -severity critical,high,medium -o nuclei.txt

echo "📡 Scanning ports..."
nmap -iL live.txt -oN nmap.txt

echo "📂 Checking sensitive files..."
> findings.txt

for path in ".env" "config.php" "backup.zip" "admin" "phpinfo.php"; do
  while read url; do
    STATUS=$(curl -o /dev/null -s -w "%{http_code}" "$url/$path")
    if [ "$STATUS" = "200" ]; then
      echo "[CRITICAL] $url/$path" >> findings.txt
    fi
  done < live.txt
done

echo "✅ Done → check output folder"
