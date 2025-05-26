{{-
    config(
        incremental_strategy='append',
        indexes=[
            {'columns': ['sat_url_phishing_label_hashdiff'], 'unique': True},
            {'columns': ['url_hash_key']},
        ],
    ) 
-}}


with
phishing_urlset as (
select {{ clean_url('domain') }} as url,
       label
  from {{ source('dwh_stage', 'phishing_urlset') }}  
),
url_attrs as (
select distinct
       {{ hash(['url', 'label'], 'u') }} as sat_url_phishing_label_hashdiff,
       {{ hash(['url'], 'u') }} as url_hash_key,
       label,
       'PHISHING_URLSET'::varchar as source,
       current_timestamp::timestamp as load_ts
  from phishing_urlset u
 where url is not null
)
select ua.*
  from url_attrs ua
{% if is_incremental() -%}
 where not exists (select 1 from {{ this }} trg where trg.sat_url_phishing_label_hashdiff = ua.sat_url_phishing_label_hashdiff )
{% endif -%}
