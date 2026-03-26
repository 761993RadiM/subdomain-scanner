#!/bin/bash

DOMAIN=$1
set -e
if [ -z "$DOMAIN" ]; then
  echo "Použití: ./scan.sh domena.cz"
  exit 1
fi

mkdir -p output
cd output

echo "🔎 Hledám subdomény..."
subfinder -d $DOMAIN -silent -o subs.txt

echo "🌐 Kontroluji živé weby..."
httpx -l subs.txt -silent -o live.txt

echo "🧨 Spouštím scan..."
nuclei -l live.txt -silent -severity critical,high,medium -o nuclei.txt

echo "📡 Scan portů..."
nmap -iL live.txt -oN nmap.txt

echo "📂 Hledám citlivé věci..."
> findings.txt

for path in ".env" "config.php" "backup.zip" "admin" "phpinfo.php"; do
  while read url; do
    STATUS=$(curl -o /dev/null -s -w "%{http_code}" "$url/$path")
    if [ "$STATUS" == "200" ]; then
      echo "[CRITICAL] $url/$path" >> findings.txt
    fi
  done < live.txt
done

echo "Hotovo → output složka"
