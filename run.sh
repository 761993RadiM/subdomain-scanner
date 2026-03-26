#!/bin/bash

echo "📦 Setup..."

pkg update -y
pkg install -y git curl golang nmap

go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install github.com/projectdiscovery/httpx/cmd/httpx@latest
go install github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest

export PATH=$PATH:~/go/bin

echo "📥 Cloning repo..."
git clone https://github.com/761993RadiM/subdomain-scanner.git

cd subdomain-scanner
chmod +x scan.sh

echo "🚀 Running scan..."
./scan.sh example.com
