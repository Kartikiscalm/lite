#!/bin/sh
cd "$(dirname "$0")/.."
Q() { docker compose exec -T db psql -U postgres -d kb -Atc "$1"; }
fail=0
for t in goals skills modules courses goal_skill module_skill institute_resources external_resources question_bank faculty faculty_course skill_overlaps prerequisites skill_faculty resource_coverage skill_course_sheet; do
  csv=$(python3 -c "import csv,sys;csv.field_size_limit(10**9);print(sum(1 for _ in csv.reader(open('db/data/$t.csv',encoding='utf-8-sig')))-1)")
  db=$(Q "SELECT count(*) FROM $t")
  [ "$csv" = "$db" ] && s=ok || { s=MISMATCH; fail=1; }
  echo "$t csv=$csv db=$db $s"
done
orph=$(Q "SELECT conrelid::regclass||'.'||a.attname||' -> '||confrelid::regclass||': '||
 (xpath('/row/c/text()', query_to_xml(format('SELECT count(*) c FROM %s t WHERE t.%I IS NOT NULL AND NOT EXISTS (SELECT 1 FROM %s p WHERE p.%I = t.%I)', conrelid::regclass, a.attname, confrelid::regclass, fa.attname, a.attname), false, true, '')))[1]
 FROM pg_constraint c JOIN pg_attribute a ON a.attrelid=c.conrelid AND a.attnum=c.conkey[1]
 JOIN pg_attribute fa ON fa.attrelid=c.confrelid AND fa.attnum=c.confkey[1] WHERE c.contype='f'")
echo "$orph"
echo "$orph" | grep -qv ': 0$' && fail=1
[ $fail = 0 ] && echo PASS || echo FAIL
exit $fail
