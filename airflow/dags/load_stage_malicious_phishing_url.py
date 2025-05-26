""" DAG for loading data file "Malicious Phishing URL" from S3 bucket to staging schema in DWH """

import sys
from pathlib import Path

from airflow import DAG

sys.path.append(str(Path(__file__).parent.absolute()))

from common_utils.stage_utils import generate_s3_to_stage_dag

dag: DAG = generate_s3_to_stage_dag(
    dag_id='load_stage_malicious_phishing_url',
    s3_file_name='malicious_phishing.csv',
    stage_table='malicious_phishing_url',
    stage_table_columns=['url','type'],
    description='Загрузка файла данных "Malicious Phishing URL"',
)
