""" DAG for loading data from API Abuse API DB to staging schema in DWH """

import sys
from pathlib import Path
import logging
import json

import requests
from requests.adapters import HTTPAdapter
from airflow.models.dag import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator
from airflow.models.variable import Variable

sys.path.append(str(Path(__file__).parent.absolute()))

from common_utils.sql_utils import generate_copy_sql
from common_utils.defaults import (
    DWH_CONN,
    DWH_STAGE_SCHEMA,
    LOCAL_STAGE_PATH,
    STAGE_DAG_DEFAULTS,
    STAGE_TAGS,
)

STAGE_JSON_TABLE = 'abuse_ip_db_json'
STAGE_TABLE = 'abuse_ip_db'
LOCAL_FILE_NAME = 'abuse_ip_db.json'

API_URL_VAR_NAME = 'abuse_ip_db_api_url'
API_KEY_VAR_NAME = 'abuse_ip_db_api_key'
IP_VERSION_VAR_NAME = 'abuse_ip_db_api_ip_version'

PARSE_SQL_JSON = [
f"truncate table {DWH_STAGE_SCHEMA}.{STAGE_TABLE};",
f"""
insert into {DWH_STAGE_SCHEMA}.{STAGE_TABLE}
select (data ->> 'ipAddress')::varchar as ip_address, 
       (data ->> 'countryCode')::varchar(2) as country_code, 
       (data ->> 'lastReportedAt')::timestamp as last_reported_at, 
       (data ->> 'abuseConfidenceScore')::integer as abuse_confidence_score
  from {DWH_STAGE_SCHEMA}.{STAGE_JSON_TABLE};""",
f"analyze {DWH_STAGE_SCHEMA}.{STAGE_TABLE};"
]

def download_from_abuse_api_db_api(save_file_path: str):
    """ Download data from Abuse API DB API """

    url = Variable.get(API_URL_VAR_NAME)
    logging.info(f"{url=}")
    headers = {
        'Key': Variable.get(API_KEY_VAR_NAME),
        'Accept': 'application/json'
    }
    params = {}
    if ip_version := Variable.get(IP_VERSION_VAR_NAME, None):
        params['ipVersion'] = ip_version
    adapter = HTTPAdapter(max_retries=3)  # 3 попытки
    with requests.Session() as session:
        session.mount('http://', adapter)
        session.mount('https://', adapter)
        response = session.get(url, headers=headers, params=params)
        response.raise_for_status()
        response_data = response.json()
        logging.info(f"{response_data=}")
        if 'data' in response_data:
            with open(save_file_path, 'w', encoding='utf-8') as file:
                for line in response_data['data']:
                    file.write(json.dumps(line) + '\n')


with DAG(
        dag_id='load_stage_abuse_ip_db',
        schedule_interval=None,
        catchup=False,
        default_args=STAGE_DAG_DEFAULTS,
        description='Загрузка данных из API "Abuse IP DB"',
        tags=STAGE_TAGS
    ) as dag:

    stage_full_table = f'{DWH_STAGE_SCHEMA}.{STAGE_JSON_TABLE}'
    data_file_path = f'{LOCAL_STAGE_PATH}{LOCAL_FILE_NAME}'
    loading_sql_list = generate_copy_sql(stage_full_table, data_file_path, file_format=None)


    download_from_api_task = PythonOperator(
        task_id='download_s3_file',
        python_callable=download_from_abuse_api_db_api,
        op_kwargs={
            'save_file_path': data_file_path,
        },
    )

    load_to_dwh_task = SQLExecuteQueryOperator(
        task_id='load_to_dwh',
        conn_id=DWH_CONN,
        sql=loading_sql_list,
    )

    parse_sql_json_task = SQLExecuteQueryOperator(
        task_id='parse_sql_json',
        conn_id=DWH_CONN,
        sql=PARSE_SQL_JSON,
    )

    download_from_api_task >> load_to_dwh_task >> parse_sql_json_task
