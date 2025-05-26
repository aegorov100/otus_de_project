create table if not exists stage.abuse_ip_db (
ip_address varchar, 
country_code varchar(2), 
last_reported_at timestamp, 
abuse_confidence_score integer,
source varchar default 'ABUSE_IP_DB'::varchar,
load_ts timestamp default current_timestamp::timestamp
);
