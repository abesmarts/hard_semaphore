#!/usr/bin/env bash
set -euo pipefail
sudo systemctl start docker
if systemctl list-unit-files | grep -q '^semaphore\.service'; then
  sudo systemctl enable semaphore
  sudo systemctl start semaphore
else
  echo "semaphore.service not found—start manually if needed."
fi
echo "All services started."
