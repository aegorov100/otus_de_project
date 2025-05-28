{{-
    config(
        incremental_strategy='append',
        indexes=[
            {'columns': ['domain_hash_key', 'ip_address_hash_key'], 'unique': True},
            {'columns': ['domain_ip_address_hash_key'], 'unique': True},
        ],
    ) 
-}}


with
a_records as (
select {{ clean_domain('domain_name') }} as domain_name,
       {{ clean_ip_address('address') }} as address,
       source,
       load_ts
  from {{ source('dwh_stage', 'a_records') }}
),
domain_x_ip as (
select distinct
       {{ hash(['domain_name', 'address'], 'ar') }} as domain_ip_address_hash_key,
       {{ hash(['domain_name'], 'ar') }} as domain_hash_key,
       {{ hash(['address'], 'ar') }} as ip_address_hash_key,
       source,
       load_ts
  from a_records ar
 where domain_name is not null
   and address is not null)
select di.*
  from domain_x_ip di 
{% if is_incremental() -%}
 where not exists (select 1 
                     from {{ this }} trg 
                    where trg.domain_hash_key = di.domain_hash_key
                      and trg.ip_address_hash_key = di.ip_address_hash_key )
{% endif -%}
