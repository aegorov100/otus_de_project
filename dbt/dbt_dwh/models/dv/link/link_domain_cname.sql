{{-
    config(
        incremental_strategy='append',
        indexes=[
            {'columns': ['domain_hash_key', 'cname_hash_key'], 'unique': True},
            {'columns': ['domain_cname_hash_key'], 'unique': True},
        ],
    ) 
-}}


with
cname_records as (
select {{ clean_domain('domain_name') }} as domain_name,
       {{ clean_ip_address('address') }} as address
  from {{ source('dwh_stage', 'cname_records') }}
),
domain_x_cname as (
select distinct
       {{ hash(['domain_name', 'address'], 'cr') }} as domain_cname_hash_key,
       {{ hash(['domain_name'], 'cr') }} as domain_hash_key,
       {{ hash(['address'], 'cr') }} as cname_hash_key,
       'CNAME_RECORDS'::varchar as source,
       current_timestamp::timestamp as load_ts
  from cname_records cr
 where domain_name is not null
   and address is not null)
select dc.*
  from domain_x_cname dc 
{% if is_incremental() -%}
 where not exists (select 1 
                     from {{ this }} trg 
                    where trg.domain_hash_key = dc.domain_hash_key
                      and trg.cname_hash_key = dc.cname_hash_key )
{% endif -%}
