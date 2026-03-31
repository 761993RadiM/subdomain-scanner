#!/bin/bash

echo "🔥 TERMUX RECON INSTALLER START"

# update
pkg update -y && pkg upgrade -y

# base packages
pkg install -y git curl wget golang nmap jq

# fix PATH
mkdir -p $HOME/go/bin
echo 'export PATH=$PATH:$HOME/go/bin' >> ~/.bashrc
export PATH=$PATH:$HOME/go/bin

echo "🛠 Installing tools..."

install_tool () {
  echo "➡️ Installing $1"
  go install $1@latest
}

# tools
install_tool github.com/projectdiscovery/subfinder/v2/cmd/subfinder
install_tool github.com/projectdiscovery/httpx/cmd/httpx
install_tool github.com/projectdiscovery/nuclei/v3/cmd/nuclei
install_tool github.com/projectdiscovery/katana/cmd/katana
install_tool github.com/tomnomnom/assetfinder
install_tool github.com/lc/gau/v2/cmd/gau
install_tool github.com/tomnomnom/waybackurls
install_tool github.com/ffuf/ffuf

echo "📦 Updating nuclei templates..."
nuclei -update-templates

echo "🧪 Testing tools..."

tools=("subfinder" "httpx" "nuclei" "katana" "assetfinder" "gau" "waybackurls" "ffuf")

for t in "${tools[@]}"
do
  if command -v $t &> /dev/null
  then
    echo "✅ $t OK"
  else
    echo "❌ $t FAILED"
  fi
done

echo "🔥 INSTALL DONE"
echo "👉 restart Termux or run: source ~/.bashrc"
