#!/bin/sh
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -v pw="$GOAL_READER_PASSWORD" <<'SQL'
CREATE ROLE goal_reader LOGIN PASSWORD :'pw';
GRANT SELECT ON goals TO goal_reader;
ALTER ROLE goal_reader SET statement_timeout = '3s';
SQL
psql -U "$POSTGRES_USER" -c 'CREATE DATABASE litellm'
