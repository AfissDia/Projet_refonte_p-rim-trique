#!/usr/bin/env bash
set -euo pipefail
p=$(sudo docker inspect -f '{{.LogPath}}' p5-waf)
printf 'Chemin Docker WAF : %s\n' "$p"
sudo ls -lh "$p"
echo 'Présences textuelles du SID 942100 dans le journal :'
sudo grep -c '942100' "$p" || true
