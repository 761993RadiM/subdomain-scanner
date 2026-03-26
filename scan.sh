#!/bin/bash

DOMAIN=$1

if [ -z "$DOMAIN" ]; then
  echo "Použití: ./scan_smart.sh domena.cz"
  exit 1
fi

mkdir -p output
cd output

echo "🔎 Hledám subdomény..."
subfinder -d $DOMAIN -silent -o subs.txt
amass enum -passive -d $DOMAIN >> subs.txt
sort -u subs.txt -o subs.txt

echo "🌐 Kontroluji živé weby..."
httpx -l subs.txt -silent -o live.txt

echo "🧨 Spouštím nuclei..."
nuclei -l live.txt -silent -severity critical,high,medium -o nuclei.txt

echo "📡 Scan portů..."
nmap -iL live.txt -oN nmap.txt

echo "📂 Hledám citlivé věci..."
> findings.txt

for path in ".env" "config.php" "backup.zip" "admin" "phpinfo.php"
do
  while read url; do
    STATUS=$(curl -o /dev/null -s -w "%{http_code}" $url/$path)
    if [ "$STATUS" == "200" ]; then
      echo "[CRITICAL] $url/$path" >> findings.txt
    fi
  done < live.txt
done

echo "📊 Vyhodnocuji rizika..."

> report.txt

echo "===== REPORT PRO $DOMAIN =====" >> report.txt
echo "" >> report.txt

echo "🔴 KRITICKÉ NÁLEZY:" >> report.txt
grep CRITICAL findings.txt >> report.txt

echo "" >> report.txt
echo "🟠 NUCLEI (zranitelnosti):" >> report.txt
cat nuclei.txt >> report.txt

echo "" >> report.txt
echo "📡 OTEVŘENÉ PORTY:" >> report.txt
cat nmap.txt >> report.txt

echo "" >> report.txt
echo "🌐 AKTIVNÍ SUBDOMÉNY:" >> report.txt
cat live.txt >> report.txt

echo "✅ Hotovo → output/report.txt"
