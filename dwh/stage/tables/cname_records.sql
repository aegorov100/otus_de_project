create table if not exists stage.cname_records (
num bigint,
domain_name varchar,
date_created date,
last_seen date,
type varchar,
address varchar,
ttl integer,
source varchar default 'CNAME_RECORDS'::varchar,
load_ts timestamp default current_timestamp::timestamp
);
