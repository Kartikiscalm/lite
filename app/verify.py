"""Run: docker compose exec app python verify.py"""
import csv, os, sys
import psycopg

csv.field_size_limit(10**9)
ok = True
with psycopg.connect(host="db", dbname="kb", user="postgres", password=os.environ["DB_PASSWORD"]) as c:
    tables = [r[0] for r in c.execute("SELECT tablename FROM pg_tables WHERE schemaname='public' ORDER BY 1")]
    for t in tables:
        n_csv = sum(1 for _ in csv.reader(open(f"/data/{t}.csv", encoding="utf-8-sig"))) - 1
        n_db = c.execute(f"SELECT count(*) FROM {t}").fetchone()[0]
        good = n_csv == n_db
        ok &= good
        print(f"{t}: csv={n_csv} db={n_db} {'ok' if good else 'MISMATCH'}")
    fks = c.execute("""SELECT conrelid::regclass::text, a.attname, confrelid::regclass::text, fa.attname
        FROM pg_constraint k JOIN pg_attribute a ON a.attrelid=k.conrelid AND a.attnum=k.conkey[1]
        JOIN pg_attribute fa ON fa.attrelid=k.confrelid AND fa.attnum=k.confkey[1] WHERE k.contype='f'""").fetchall()
    for t, col, pt, pcol in fks:
        n = c.execute(f"SELECT count(*) FROM {t} x WHERE {col} IS NOT NULL AND NOT EXISTS "
                      f"(SELECT 1 FROM {pt} p WHERE p.{pcol}=x.{col})").fetchone()[0]
        ok &= n == 0
        print(f"orphans {t}.{col} -> {pt}: {n}")
print("PASS" if ok else "FAIL")
sys.exit(0 if ok else 1)
