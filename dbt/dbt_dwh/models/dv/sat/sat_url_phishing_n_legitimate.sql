{{-
    config(
        incremental_strategy='append',
        indexes=[
            {'columns': ['sat_url_phishing_n_legitimate_hashdiff'], 'unique': True},
            {'columns': ['url_hash_key']},
        ],
    ) 
-}}


with
phishing_n_legitimate_url as (
select {{ clean_url('url') }} as url,
       status,
       source,
       load_ts
  from {{ source('dwh_stage', 'phishing_n_legitimate_url') }}  
),
url_attrs as (
select distinct
       {{ hash(['url', 'status'], 'u') }} as sat_url_phishing_n_legitimate_hashdiff,
       {{ hash(['url'], 'u') }} as url_hash_key,
       status,
       source,
       load_ts
  from phishing_n_legitimate_url u
 where url is not null
)
select ua.*
  from url_attrs ua
{% if is_incremental() -%}
 where not exists (select 1 from {{ this }} trg where trg.sat_url_phishing_n_legitimate_hashdiff = ua.sat_url_phishing_n_legitimate_hashdiff )
{% endif -%}
