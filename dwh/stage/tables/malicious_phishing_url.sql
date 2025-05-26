create table if not exists stage.malicious_phishing_url(
url varchar,
type varchar,
source varchar default 'MALICIOUS_PHISHING_URL'::varchar,
load_ts timestamp default current_timestamp::timestamp
);
