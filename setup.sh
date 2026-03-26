#!/bin/bash

echo "📦 Installing packages..."
pkg update -y
pkg install -y git curl golang nmap

echo "⚙️ Installing tools..."
go install ://github.com
go install ://github.com
go install ://github.com

echo "🔧 Setting up PATH..."
echo 'export PATH=$PATH:~/go/bin' >> ~/.bashrc
export PATH=$PATH:~/go/bin

echo "📥 Downloading your project..."
git clone https://github.com

echo "✅ DONE"
echo "👉 To continue:"
echo "cd subdomain-scanner"
echo "chmod +x scan.sh"
echo "./scan.sh example.com"
