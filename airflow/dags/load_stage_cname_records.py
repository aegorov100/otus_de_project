""" DAG for loading data file "CNAME records" from S3 bucket to staging schema in DWH """

import sys
from pathlib import Path

from airflow import DAG

sys.path.append(str(Path(__file__).parent.absolute()))

from common_utils.stage_utils import generate_s3_to_stage_dag

dag: DAG = generate_s3_to_stage_dag(
    dag_id='load_stage_cname_records',
    s3_file_name='cname_records.csv',
    stage_table='cname_records',
    description='Загрузка файла данных "CNAME records"',
)
