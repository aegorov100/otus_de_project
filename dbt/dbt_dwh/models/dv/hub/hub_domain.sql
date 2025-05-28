{{-
    config(
        incremental_strategy='append',
        indexes=[
            {'columns': ['domain'], 'unique': True},
            {'columns': ['domain_hash_key'], 'unique': True},
        ],
    ) 
-}}


with
a_records as (
select {{ clean_domain('domain_name') }} as domain_name,
       source,
       load_ts
  from {{ source('dwh_stage', 'a_records') }}
),
cname_records as (
select {{ clean_domain('domain_name') }} as domain_name,
       {{ clean_domain('address') }} as address,
       source,
       load_ts
  from {{ source('dwh_stage', 'cname_records') }}
),
malicious_phishing_url as (
select {{ clean_domain(domain_from_url('url')) }} as domain_name,
       source,
       load_ts
  from {{ source('dwh_stage', 'malicious_phishing_url') }}
),
phishing_n_legitimate_url as (
select {{ clean_domain(domain_from_url('url')) }} as domain_name,
       source,
       load_ts
  from {{ source('dwh_stage', 'phishing_n_legitimate_url') }}
),
phishing_urlset as (
select {{ clean_domain(domain_from_url('domain')) }} as domain_name,
       source,
       load_ts
  from {{ source('dwh_stage', 'phishing_urlset') }}
),
domain as (
select distinct
       {{ hash(['domain_name'], 'ar') }} as domain_hash_key,
       domain_name as domain,
       source,
       load_ts
  from a_records ar
 where domain_name is not null
union all
select distinct
       {{ hash(['domain_name'], 'cr') }} as domain_hash_key,
       domain_name as domain,
       source,
       load_ts
  from cname_records cr
 where domain_name is not null
union all
select distinct
       {{ hash(['address'], 'cr') }} as domain_hash_key,
       address as domain,
       source,
       load_ts
  from cname_records cr
 where address is not null
union all
select distinct
       {{ hash(['domain_name'], 'mpu') }} as domain_hash_key,
       domain_name as domain,
       source,
       load_ts
  from malicious_phishing_url mpu
 where domain_name is not null
union all
select distinct
       {{ hash(['domain_name'], 'plu') }} as domain_hash_key,
       domain_name as domain,
       source,
       load_ts
  from phishing_n_legitimate_url plu
 where domain_name is not null
union all
select distinct
       {{ hash(['domain_name'], 'pus') }} as domain_hash_key,
       domain_name as domain,
       source,
       load_ts
  from phishing_urlset pus
 where domain_name is not null
),
domain_rn as (
select d.*,
       row_number() over (partition by domain order by load_ts, source) as rn
  from domain d
{% if is_incremental() -%}
 where not exists (select 1 from {{ this }} trg where trg.domain = d.domain )
{% endif -%}
)
select domain_hash_key,
       domain,
       source,
       load_ts
  from domain_rn
 where rn = 1