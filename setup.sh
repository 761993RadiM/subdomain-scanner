#!/bin/bash

echo "📦 Updating packages..."
pkg update -y
pkg upgrade -y

echo "📦 Installing base packages..."
pkg install -y git curl wget golang nmap

echo "⚙️ Setting up Go PATH..."
echo 'export PATH=$PATH:~/go/bin' >> ~/.bashrc
export PATH=$PATH:~/go/bin

echo "🛠 Installing recon tools..."

# Subdomain tools
go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install github.com/tomnomnom/assetfinder@latest
go install github.com/owasp-amass/amass/v4/...@master

# HTTP probing
go install github.com/projectdiscovery/httpx/cmd/httpx@latest

# Vulnerability scanner
go install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest

# Web crawler
go install github.com/projectdiscovery/katana/cmd/katana@latest

# Fuzzing
go install github.com/ffuf/ffuf@latest

echo "⬇️ Updating nuclei templates..."
nuclei -update-templates

echo "✅ DONE!"
echo "👉 Restart Termux or run: source ~/.bashrc"
