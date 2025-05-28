{{-
    config(
        incremental_strategy='append',
        indexes=[
            {'columns': ['domain_hash_key', 'url_hash_key'], 'unique': True},
            {'columns': ['domain_url_hash_key'], 'unique': True},
        ],
    ) 
-}}


with
domain_x_url as (
select {{ clean_domain(domain_from_url('url')) }} as domain_name,
       {{ clean_url('url') }} as url,
       source,
       load_ts
  from {{ source('dwh_stage', 'malicious_phishing_url') }}
union all
select {{ clean_domain(domain_from_url('url')) }} as domain_name,
       {{ clean_url('url') }} as url,
       source,
       load_ts
  from {{ source('dwh_stage', 'phishing_n_legitimate_url') }}
union all
select {{ clean_domain(domain_from_url('domain')) }} as domain_name,
       {{ clean_url('domain') }} as url,
       source,
       load_ts
  from {{ source('dwh_stage', 'phishing_urlset') }}
),
domain_x_url_hash as (
select distinct
       {{ hash(['domain_name', 'url'], 'du') }} as domain_url_hash_key,
       {{ hash(['domain_name'], 'du') }} as domain_hash_key,
       {{ hash(['url'], 'du') }} as url_hash_key,
       source,
       load_ts
  from domain_x_url du
 where domain_name is not null
   and url is not null),
domain_x_url_rn as (
select duh.*,
       row_number() over (partition by domain_hash_key, url_hash_key order by load_ts, source) as rn
  from domain_x_url_hash duh
{% if is_incremental() -%}
  where not exists (select 1 
                     from {{ this }} trg 
                    where trg.domain_hash_key = duh.domain_hash_key
                      and trg.url_hash_key = duh.url_hash_key )
{% endif -%}
)
select domain_url_hash_key,
       domain_hash_key,
       url_hash_key,
       source,
       load_ts
  from domain_x_url_rn dur
 where dur.rn = 1
