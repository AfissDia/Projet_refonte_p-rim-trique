#!/usr/bin/env bash
set -euo pipefail
printf 'Docker :\n'; sudo docker compose -f config/docker/compose.yaml ps || true
printf '\nRéseau :\n'; ip -br addr || true
printf '\nAgent Wazuh :\n'; sudo systemctl is-active wazuh-agent || true
printf '\nDisque :\n'; df -h / || true
