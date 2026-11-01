#!/usr/bin/env bash
set -euo pipefail
URL='http://127.0.0.1:8080/'
echo '[1] Requête normale'
normal=$(curl -s -o /dev/null --max-time 8 -w '%{http_code}' "$URL")
printf 'HTTP %s\n' "$normal"
echo '[2] SQLi de laboratoire autorisée uniquement sur Juice Shop local'
sqli=$(curl -s -o /dev/null --max-time 8 -w '%{http_code}' --get --data-urlencode "id=1' OR '1'='1" "$URL")
printf 'HTTP %s\n' "$sqli"
if [[ "$normal" == 200 && "$sqli" == 403 ]]; then echo '[OK] 200 normal / 403 SQLi'; else echo '[ATTENTION] Comparer les logs WAF avant de conclure'; fi
