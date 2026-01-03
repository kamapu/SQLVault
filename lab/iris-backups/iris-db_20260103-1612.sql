/*--- yaml
type: SQLVault.project
database: iris-db
user: miguel
initialized: 2026-01-03 14:11
dms: PostgreSQL 16.11 (Ubuntu 16.11-0ubuntu0.24.04.1) on x86_64-pc-linux-gnu, compiled
  by gcc (Ubuntu 13.3.0-6ubuntu2~24.04) 13.3.0, 64-bit
server: 16.11 (Ubuntu 16.11-0ubuntu0.24.04.1)
remarks: Adding full names for iris species in the database.
released: 2026-01-03 16:12
backup: iris-db_20260103-1612.backup
sql: iris-db_20260103-1612.sql
---*/

alter table "data_frames"."iris"
add column "name" text,
add column "author" text;

comment on column "data_frames"."iris"."name" is 'Scientific name.';

comment on column "data_frames"."iris"."author" is 'Author of scientific name.';

update "data_frames"."iris"
set "name" = 'Iris setosa', "author" = 'Pall. ex Link'
where "species" = 'setosa';

update "data_frames"."iris"
set "name" = 'Iris versicolor', "author" = 'L.'
where "species" = 'versicolor';

update "data_frames"."iris"
set "name" = 'Iris virginica', "author" = 'L.'
where "species" = 'virginica';

