""" DAG for loading data file "Phishing & Legitimate URL" from S3 bucket to staging schema in DWH """

import sys
from pathlib import Path

from airflow import DAG

sys.path.append(str(Path(__file__).parent.absolute()))

from common_utils.stage_utils import generate_s3_to_stage_dag

dag: DAG = generate_s3_to_stage_dag(
    dag_id='load_stage_phishing_legitimate_url',
    s3_file_name='phishing_n_legitimate_urls.csv',
    stage_table='phishing_n_legitimate_url',
    stage_table_columns=['url','status'],
    description='Загрузка файла данных "Phishing & Legitimate URL"',
)
