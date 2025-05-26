{% macro clean_url(column) -%}
    lower({{ column }})
{%- endmacro %}

{% macro clean_domain(column) -%}
    lower({{ column }})
{%- endmacro %}

{% macro clean_ip_address(column) -%}
    {{ column }}
{%- endmacro %}

{% macro domain_from_url(column) -%}
    (string_to_array(regexp_replace((string_to_array({{ column }}, '/'))[1], '^www\.', ''), ':'))[1] 
{%- endmacro %}

