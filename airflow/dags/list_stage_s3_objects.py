""" DAG for listing stage bucket """

import sys
from pathlib import Path
from airflow import DAG
from airflow.providers.amazon.aws.hooks.s3 import S3Hook
from airflow.operators.python import PythonOperator
import logging

sys.path.append(str(Path(__file__).parent.absolute()))

from common_utils.defaults import (
    STAGE_S3_CONN,
    STAGE_S3_BUCKET_NAME,
    DAG_DEFAULTS
)


log = logging.getLogger(__name__)


def list_files_in_bucket(bucket_name):
    """ List all objects from input bucket """

    s3_hook = S3Hook(aws_conn_id=STAGE_S3_CONN)
    keys = s3_hook.list_keys(bucket_name=bucket_name)

    if not keys:
        log.info(f"Бакет {bucket_name} пуст.")
    else:
        for k in keys:
            log.info(k)

with DAG(
    'list_stage_s3_objects',
    default_args=DAG_DEFAULTS,
    description='Простое перечисление объектов в S3 бакете',
    schedule_interval=None,
    tags=['debug']
) as dag:

    list_files_task = PythonOperator(
        task_id='list_files',
        python_callable=list_files_in_bucket,
        op_kwargs={'bucket_name': STAGE_S3_BUCKET_NAME},
    )