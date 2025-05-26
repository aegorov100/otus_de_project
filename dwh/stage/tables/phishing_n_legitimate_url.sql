create table if not exists stage.phishing_n_legitimate_url (
url varchar,
status int4,
source varchar default 'PHISHING_N_LEGITIMATE_URL'::varchar,
load_ts timestamp default current_timestamp::timestamp
);
