#!/usr/bin/env bash
# Poll the latest GitHub Actions run until completion (max ~9 minutes per call).
REPO="$1"
TOKEN=$(printf "protocol=https\nhost=github.com\n\n" | GCM_INTERACTIVE=Never git credential fill | grep '^password=' | cut -d= -f2-)
DEADLINE=$((SECONDS + 540))
while true; do
  RESP=$(curl -s -H "Authorization: token $TOKEN" "https://api.github.com/repos/$REPO/actions/runs?per_page=1")
  STATUS=$(echo "$RESP" | grep '"status"' | head -1 | sed 's/.*: "\([^"]*\)".*/\1/')
  CONCL=$(echo "$RESP" | grep '"conclusion"' | head -1 | sed 's/.*: "\([^"]*\)".*/\1/')
  ID=$(echo "$RESP" | grep '"id"' | head -1 | sed 's/.*: \([0-9]*\).*/\1/')
  echo "[$(date +%H:%M:%S)] status=$STATUS conclusion=$CONCL run=$ID"
  if [ "$STATUS" = "completed" ]; then
    echo "FINAL: $CONCL"
    echo "URL: https://github.com/$REPO/actions/runs/$ID"
    exit 0
  fi
  if [ $SECONDS -ge $DEADLINE ]; then
    echo "STILL_RUNNING"
    exit 2
  fi
  sleep 30
done
