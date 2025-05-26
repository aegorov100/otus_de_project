{{-
    config(
        incremental_strategy='append',
        indexes=[
            {'columns': ['ip_address'], 'unique': True},
            {'columns': ['ip_address_hash_key'], 'unique': True},
        ],
    ) 
-}}


with
a_records as (
select {{ clean_ip_address('address') }} as address
  from {{ source('dwh_stage', 'a_records') }}
),
abuse_ip_db as (
select {{ clean_ip_address('ip_address') }} as ip_address
  from {{ source('dwh_stage', 'abuse_ip_db') }}
),
ip_address as (
select distinct
       {{ hash(['address'], 'ar') }} as ip_address_hash_key,
       address as ip_address,
       'A_RECORDS'::varchar as source,
       current_timestamp::timestamp as load_ts
  from a_records ar
 where address is not null
union all
select distinct
       {{ hash(['ip_address'], 'aid') }} as ip_address_hash_key,
       ip_address as ip_address,
       'ABUSE_IP_DB'::varchar as source,
       current_timestamp::timestamp as load_ts
  from abuse_ip_db aid
 where ip_address is not null
),
ip_address_rn as (
select ia.*,
       row_number() over (partition by ip_address order by load_ts, source) as rn
  from ip_address ia
{% if is_incremental() -%}
 where not exists (select 1 from {{ this }} trg where trg.ip_address = ia.ip_address )
{% endif -%}
)
select ip_address_hash_key,
       ip_address,
       source,
       load_ts
  from ip_address_rn
 where rn = 1