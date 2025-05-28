{{-
    config(
        incremental_strategy='append',
        indexes=[
            {'columns': ['url'], 'unique': True},
            {'columns': ['url_hash_key'], 'unique': True},
        ],
    ) 
-}}


with
malicious_phishing_url as (
select {{ clean_url('url') }} as url,
       source,
       load_ts
  from {{ source('dwh_stage', 'malicious_phishing_url') }}  
),
phishing_n_legitimate_url as (
select {{ clean_url('url') }} as url,
       source,
       load_ts
  from {{ source('dwh_stage', 'phishing_n_legitimate_url') }}  
),
phishing_urlset as (
select {{ clean_url('domain') }} as domain,
       source,
       load_ts
  from {{ source('dwh_stage', 'phishing_urlset') }}  
),
url as (
select distinct
       {{ hash(['url'], 'mpu') }} as url_hash_key,
       url,
       source,
       load_ts
  from malicious_phishing_url mpu
 where url is not null
union all
select distinct
       {{ hash(['url'], 'plu') }} as url_hash_key,
       url,
       source,
       load_ts
  from phishing_n_legitimate_url plu
 where url is not null
union all
select distinct
       {{ hash(['domain'], 'pus') }} as url_hash_key,
       domain as url,
       source,
       load_ts
  from phishing_urlset pus
 where domain is not null
),
url_rn as (
select ia.*,
       row_number() over (partition by url order by load_ts, source) as rn
  from url ia
{% if is_incremental() -%}
 where not exists (select 1 from {{ this }} trg where trg.url = ia.url )
{% endif -%}
)
select url_hash_key,
       url,
       source,
       load_ts
  from url_rn
 where rn = 1
