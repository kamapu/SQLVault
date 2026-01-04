/*--- yaml
type: SQLVault.project
database: iris-db
user: miguel
initialized: 2026-01-02 17:30
dms: PostgreSQL 16.11 (Ubuntu 16.11-0ubuntu0.24.04.1) on x86_64-pc-linux-gnu, compiled
  by gcc (Ubuntu 13.3.0-6ubuntu2~24.04) 13.3.0, 64-bit
server: 16.11 (Ubuntu 16.11-0ubuntu0.24.04.1)
remarks: Structuring database. The result is a database with defined schemas and relations
  but without any data.
released: 2026-01-02 18:49
backup: iris-db_20260102-1849.backup
sql: iris-db_20260102-1849.sql
---*/

create schema data_frames;

create table data_frames.iris (
id serial primary key,
petal_length double precision,
petal_width double precision,
sepal_length double precision,
sepal_width double precision,
species text
);

