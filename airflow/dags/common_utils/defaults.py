""" Module with all common default values """

from datetime import timedelta, datetime

STAGE_S3_CONN = 's3_input'
STAGE_S3_BUCKET_NAME = 'otus-project-bd01a38f'
STAGE_S3_BUCKET_PATH = 'stage/'
DWH_CONN = 'dwh_db'
DWH_STAGE_SCHEMA = 'stage'
LOCAL_STAGE_PATH = '/stage_data/'


DAG_DEFAULTS = {
    'owner': 'airflow',
    'start_date': datetime(2025, 5, 9),
    'retries': 0,
    'retry_delay': timedelta(minutes=5)
}

STAGE_TAGS = ['stage']

DBT_SSH_CONN = 'dbt_ssh'
