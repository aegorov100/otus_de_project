with
domain_abuse_ip_stats as (
select di.domain_hash_key, 
       count(distinct ipad.ip_address_hash_key) as abuse_ip_count, 
       string_agg(distinct ipad.country_code, ', ') as abuse_ip_countries
  from {{ ref('sat_ip_address_abuse_db') }} ipad 
  join {{ ref('link_domain_ip_address') }} di
    on di.ip_address_hash_key = ipad.ip_address_hash_key  
 where ipad.abuse_confidence_score >= 75
 group by di.domain_hash_key 
),
url_threat as (
select ump.url_hash_key, 1 as url_threat
  from {{ ref('sat_url_malicious_phishing') }} ump
 where ump.type != 'benign'
union all 
select upl.url_hash_key, 1 as url_threat
  from {{ ref('sat_url_phishing_label') }} upl
 where upl.label = 1.0
union all 
select upl.url_hash_key, 1 as url_threat
  from {{ ref('sat_url_phishing_n_legitimate') }} upl
 where upl.status = 0
),
domain_url_threat_stats as (
select du.domain_hash_key, 
       sum(ut.url_threat) as url_threats_count
  from url_threat ut
  join {{ ref('link_domain_url') }} du
    on du.url_hash_key = ut.url_hash_key  
 group by du.domain_hash_key 
)
select d.domain, 
       coalesce(dais.abuse_ip_count, 0) as abuse_ip_count, 
       coalesce(dais.abuse_ip_countries, '') as abuse_ip_countries, 
       coalesce(duts.url_threats_count, 0) as url_threats_count
  from {{ ref('hub_domain') }} d
  left
  join domain_abuse_ip_stats dais 
    on dais.domain_hash_key = d.domain_hash_key
  left
  join domain_url_threat_stats duts 
    on duts.domain_hash_key = d.domain_hash_key