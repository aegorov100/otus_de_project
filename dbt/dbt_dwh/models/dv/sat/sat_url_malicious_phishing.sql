{{-
    config(
        incremental_strategy='append',
        indexes=[
            {'columns': ['sat_url_malicious_phishing_hashdiff'], 'unique': True},
            {'columns': ['url_hash_key']},
        ],
    ) 
-}}


with
malicious_phishing_url as (
select {{ clean_url('url') }} as url,
       type
  from {{ source('dwh_stage', 'malicious_phishing_url') }}  
),
url_attrs as (
select distinct
       {{ hash(['url', 'type'], 'u') }} as sat_url_malicious_phishing_hashdiff,
       {{ hash(['url'], 'u') }} as url_hash_key,
       type,
       'MALICIOUS_PHISHING_URL'::varchar as source,
       current_timestamp::timestamp as load_ts
  from malicious_phishing_url u
 where url is not null
)
select ua.*
  from url_attrs ua
{% if is_incremental() -%}
 where not exists (select 1 from {{ this }} trg where trg.sat_url_malicious_phishing_hashdiff = ua.sat_url_malicious_phishing_hashdiff )
{% endif -%}
