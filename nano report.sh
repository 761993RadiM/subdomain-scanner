#!/bin/bash

echo "📊 Generuji HTML report..."

cat <<EOF > report.html
<html>
<head>
<title>Scan Report</title>
<style>
body { font-family: Arial; background:#111; color:#eee; }
h1 { color:#00ffcc; }
.box { border:1px solid #333; padding:10px; margin:10px; }
.red { color:red; }
.green { color:lime; }
</style>
</head>
<body>

<h1>🔎 Subdomain Scan Report</h1>

<div class="box">
<h2>🌐 Live Domains</h2>
<pre>$(cat live.txt)</pre>
</div>

<div class="box">
<h2>🧨 Vulnerabilities</h2>
<pre>$(cat nuclei.txt)</pre>
</div>

<div class="box">
<h2 class="red">🔥 Critical Findings</h2>
<pre>$(cat findings.txt)</pre>
</div>

<div class="box">
<h2>📡 Ports</h2>
<pre>$(cat nmap.txt)</pre>
</div>

</body>
</html>
EOF

echo "✅ report.html vytvořen"
