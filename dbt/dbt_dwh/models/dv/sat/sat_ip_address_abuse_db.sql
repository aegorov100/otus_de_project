{{-
    config(
        incremental_strategy='append',
        indexes=[
            {'columns': ['sat_ip_address_abuse_db_hashdiff'], 'unique': True},
            {'columns': ['ip_address_hash_key']},
        ],
    ) 
-}}


with
abuse_ip_db as (
select {{ clean_ip_address('ip_address') }} as ip_address,
       country_code,
	   last_reported_at,
	   abuse_confidence_score 
  from {{ source('dwh_stage', 'abuse_ip_db') }}
),
ip_address as (
select distinct
       {{ hash(['ip_address', 'country_code', 'last_reported_at', 'abuse_confidence_score'], 'aid') }} as sat_ip_address_abuse_db_hashdiff,
       {{ hash(['ip_address'], 'aid') }} as ip_address_hash_key,
       country_code,
	   last_reported_at,
	   abuse_confidence_score,
       'ABUSE_IP_DB'::varchar as source,
       current_timestamp::timestamp as load_ts
  from abuse_ip_db aid
 where ip_address is not null
)
select ia.*
  from ip_address ia
{% if is_incremental() -%}
 where not exists (select 1 from {{ this }} trg where trg.sat_ip_address_abuse_db_hashdiff = ia.sat_ip_address_abuse_db_hashdiff )
{% endif -%}
