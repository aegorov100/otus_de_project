create table if not exists stage.cname_records (
num bigint,
domain_name varchar,
date_created date,
last_seen date,
type varchar,
address varchar,
ttl integer
);
