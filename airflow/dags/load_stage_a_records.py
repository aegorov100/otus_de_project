""" DAG for loading data file "A records" from S3 bucket to staging schema in DWH """

import sys
from pathlib import Path

from airflow import DAG

sys.path.append(str(Path(__file__).parent.absolute()))

from common_utils.stage_utils import generate_s3_to_stage_dag

dag: DAG = generate_s3_to_stage_dag(
    dag_id='load_stage_a_records',
    s3_file_name='a_records.csv',
    stage_table='a_records',
    stage_table_columns=['num', 'domain_name', 'date_created', 'last_seen', 'type', 'address', 'ttl'],
    description='Загрузка файла данных "A records"',
)
