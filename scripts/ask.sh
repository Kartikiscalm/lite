#!/bin/sh
# Usage: ./scripts/ask.sh "I want to become a backend developer"   (or run with no args to be prompted)
cd "$(dirname "$0")/.."
q="$*"
[ -z "$q" ] && printf "Goal: " && read -r q
id=$(python3 -c 'import json,sys;print(json.dumps({"query":sys.argv[1]}))' "$q" |
  curl -s -m 60 localhost:8000/map-goal -H 'content-type: application/json' -d @- |
  python3 -c 'import json,sys;print(json.load(sys.stdin)["goal_id"] or "")')
[ -z "$id" ] && { echo "No match (null)"; exit 1; }
docker compose exec -T db psql -U postgres -d kb -Atc "SELECT goal_id||' - '||name FROM goals WHERE goal_id='$id'"
