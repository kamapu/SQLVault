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

