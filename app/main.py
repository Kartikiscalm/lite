import os, re
import psycopg
import psycopg.sql
from fastapi import FastAPI
from openai import OpenAI

H = "db"
llm = OpenAI(base_url="http://litellm:4000", api_key=os.environ["LITELLM_MASTER_KEY"])
app = FastAPI()

DDL = """CREATE TABLE goals (goal_id TEXT PRIMARY KEY, programme TEXT, name TEXT, parent_goal_id TEXT,
goal_type TEXT, definition TEXT, horizon_months INTEGER, assessment_methods TEXT, success_criteria TEXT, source TEXT, status TEXT);"""


@app.on_event("startup")
def load_goals():
    with psycopg.connect(host=H, dbname="kb", user="postgres", password=os.environ["DB_PASSWORD"], autocommit=True) as c:
        pw = os.environ["GOAL_READER_PASSWORD"]
        c.execute(psycopg.sql.SQL("DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='goal_reader') "
                                  "THEN CREATE ROLE goal_reader LOGIN; END IF; END $$"))
        c.execute(psycopg.sql.SQL("ALTER ROLE goal_reader PASSWORD {}").format(psycopg.sql.Literal(pw)))
        c.execute("GRANT SELECT ON goals TO goal_reader")
        c.execute("ALTER ROLE goal_reader SET statement_timeout = '3s'")
    with psycopg.connect(host=H, dbname="kb", user="postgres", password=os.environ["DB_PASSWORD"]) as c:
        rows = c.execute("SELECT goal_id, name FROM goals ORDER BY goal_id").fetchall()
    app.state.ids = {r[0] for r in rows}
    app.state.names = dict(rows)
    app.state.system = (
        f"Schema:\n{DDL}\n\nGoals (goal_id | name):\n" + "\n".join(f"{i} | {n}" for i, n in rows)
        + "\n\nWrite ONE read-only PostgreSQL SELECT that returns the single best-matching goal_id "
        "for the user's goal. Output only the SQL, no explanation."
    )


def clean(sql: str):
    sql = re.sub(r"^```\w*|```$", "", sql.strip(), flags=re.M).strip().rstrip(";").strip()
    if ";" in sql or not re.match(r"(?i)select\b", sql):
        return None
    return f"SELECT * FROM ({sql}) q LIMIT 1"


@app.post("/map-goal")
def map_goal(body: dict):
    try:
        r = llm.chat.completions.create(
            model="grok",
            messages=[{"role": "system", "content": app.state.system}, {"role": "user", "content": str(body["query"])}],
        )
        sql = clean(r.choices[0].message.content)
        if not sql:
            return {"goal_id": None}
        with psycopg.connect(host=H, dbname="kb", user="goal_reader", password=os.environ["GOAL_READER_PASSWORD"]) as c:
            row = c.execute(sql).fetchone()
        gid = row[0] if row else None
        gid = gid if gid in app.state.ids else None
        return {"goal_id": gid, "name": app.state.names.get(gid)}
    except Exception:
        return {"goal_id": None}
