{% macro hash(columns, table_alias) -%}
    md5(
         {%- for column in columns -%}
           {{ table_alias ~ "." if table_alias is not none}}{{ column }}{{ "||'#'||" if not loop.last }}
         {%- endfor -%}
    )
{%- endmacro %}