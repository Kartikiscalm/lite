# Goal Mapper — Setup Guide (from scratch)

Type a career goal in plain English (e.g. "I want to build websites") and an LLM finds the closest goal in a Postgres database.

**How it works:** your text → app → LiteLLM → LLM (Groq) writes one read-only SQL `SELECT` → the app checks it and runs it with a read-only DB user → you get a `goal_id`.

## 1. What you need
- A Mac/Windows/Linux computer with a terminal.
- **Docker Desktop** — download from https://www.docker.com/products/docker-desktop, install, and **open it** (wait until it says "running").
- A free **Groq API key** — sign up at https://console.groq.com → API Keys → Create. It starts with `gsk_`.

Check Docker works:
```
docker --version
docker compose version
```

## 2. Get the project
Open a terminal and go to the project folder (the one containing `docker-compose.yml`):
```
cd /path/to/adobe_lite
```
All commands below are run from this folder.

## 3. Create your `.env` file (secrets)
```
cp .env.example .env
```
Open `.env` in any editor and fill it in:
```
DB_PASSWORD=pick_any_password
GOAL_READER_PASSWORD=pick_another_password
GROQ_API_KEY=gsk_your_key_here
LITELLM_MASTER_KEY=sk-pick-anything-starting-with-sk-
```
Never share or commit `.env`.

## 4. Start everything
```
docker compose down -v && docker compose up --build
```
The first run downloads images (a few minutes). It is ready when you see:
`Uvicorn running on http://0.0.0.0:8000`

This terminal stays busy. Open a **second terminal** (and `cd` to the project folder again) for the next steps. To run in the background instead, use `docker compose up -d --build`.

`down -v` wipes the database so it reloads from the CSVs in `db/data/`. Leave it out if you want to keep existing data.

## 5. Verify the data loaded
```
./scripts/verify.sh
```
It compares each table's row count with its CSV and checks foreign keys. It should end with `PASS`.

## 6. Ask the LLM a question
```
./scripts/ask.sh "I want to become a backend developer"
```
Output looks like `SWE_BACKEND - Backend Software Engineer`. Run it with no text to be prompted. If nothing matches you get `No match (null)`.

Or call the API directly:
```
curl -s localhost:8000/map-goal -H 'content-type: application/json' \
  -d '{"query": "I want to become a backend developer"}'
```

## 7. See the LLM calls in the LiteLLM dashboard
1. Open http://localhost:4000/ui
2. Username `admin`, password = your `LITELLM_MASTER_KEY` from `.env`.
3. Go to **Logs**. Each call shows your text, the SQL the model wrote, tokens and latency (appears after ~1 minute).

Logs live in Postgres, database `litellm`, table `LiteLLM_SpendLogs`.

## 8. Everyday commands
| Do this | Command |
|---|---|
| Stop | `docker compose down` |
| Start again (keeps data) | `docker compose up -d` |
| Full reset (reloads CSVs) | `docker compose down -v && docker compose up --build` |
| Watch logs | `docker compose logs -f app` (or `litellm`, `db`) |
| Peek into the database | `docker compose exec db psql -U postgres -d kb` |

## 9. Troubleshooting
- **`No match (null)` for everything** — the app swallows errors. Check `docker compose logs litellm`. After editing `.env`, restart *all* services: `docker compose up -d --force-recreate`.
- **"Invalid API Key" in LiteLLM logs** — wrong `GROQ_API_KEY` in `.env`.
- **"model does not exist"** — change the model in `litellm/config.yaml` (currently `groq/openai/gpt-oss-120b`).
- **Dashboard says "Too many failed sign-in attempts"** — `docker compose up -d --force-recreate litellm`, and use the master key as password.
- **`Cannot connect to the Docker daemon`** — open Docker Desktop first.
- **Port already in use** (5432/4000/8000) — stop whatever uses it, or change the left number in `ports:` in `docker-compose.yml`.
- **`404 Not Found` for `GET /` in app logs** — harmless; the only endpoint is `POST /map-goal`.

## 10. What's in the folder
```
docker-compose.yml     the 3 services: db (Postgres 16), litellm, app
.env / .env.example    secrets
db/data/*.csv          your data (one CSV per sheet tab)
db/init/               runs once on a fresh DB: 01 schema, 02 load CSVs,
                       03 foreign keys/indexes/view, 04 read-only role
litellm/config.yaml    model alias `grok` -> Groq model
app/main.py            the API (POST /map-goal) and the LLM call
scripts/verify.sh      checks row counts and foreign keys
scripts/ask.sh         ask a question from the terminal
```

## 11. Safety notes
- The LLM's SQL runs as `goal_reader`, which can only `SELECT` from `goals`, with a 3-second timeout.
- The app accepts only a single `SELECT`, rejects `;` inside it, forces `LIMIT 1`, and returns `null` on any error (no retries).
