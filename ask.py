"""Run: python3 ask.py   (needs the stack running: docker compose up -d)"""
import json, urllib.request

while True:
    try:
        text = input("Enter text: ").strip()
    except (EOFError, KeyboardInterrupt):
        break
    if not text:
        continue
    req = urllib.request.Request("http://localhost:8000/map-goal", json.dumps({"query": text}).encode(),
                                 {"content-type": "application/json"})
    try:
        r = json.load(urllib.request.urlopen(req, timeout=60))
    except Exception as e:
        print(f"Error: {e}\n")
        continue
    print(f"Answer: {r['goal_id']} - {r['name']}\n" if r["goal_id"] else "Answer: no match\n")
