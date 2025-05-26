""" Module with utils for staging ETL """

import sys
from pathlib import Path
from typing import List

from airflow.models.dag import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator

sys.path.append(str(Path(__file__).parent.absolute()))

from s3_utils import download_file_from_s3
from sql_utils import generate_copy_sql
from defaults import (
    STAGE_S3_CONN,
    STAGE_S3_BUCKET_NAME,
    STAGE_S3_BUCKET_PATH,
    DWH_CONN,
    DWH_STAGE_SCHEMA,
    LOCAL_STAGE_PATH,
    STAGE_DAG_DEFAULTS,
    STAGE_TAGS,
)

def generate_s3_to_stage_dag(
        dag_id: str,
        s3_file_name:str,
        stage_table: str,
        stage_table_columns: List[str] = None,
        description: str = None,
        stage_s3_bucket_name: str = STAGE_S3_BUCKET_PATH,
        dwh_stage_schema: str = DWH_STAGE_SCHEMA
) -> DAG:
    """ Generate DAG for for loading from S3 to staging schema in DWH """

    stage_s3_file_key = f'{stage_s3_bucket_name}{s3_file_name}'
    stage_full_table = f'{dwh_stage_schema}.{stage_table}'
    data_file_path = f'{LOCAL_STAGE_PATH}{s3_file_name}'
    loading_sql_list = generate_copy_sql(stage_full_table, data_file_path, table_columns=stage_table_columns)

    dag = DAG(
        dag_id=dag_id,
        default_args=STAGE_DAG_DEFAULTS,
        description=description,
        schedule_interval=None,
        tags=STAGE_TAGS
    )

    with dag:

        download_s3_file_task = PythonOperator(
            task_id='download_s3_file',
            python_callable=download_file_from_s3,
            op_kwargs={
                's3_conn_id': STAGE_S3_CONN,
                'bucket_name': STAGE_S3_BUCKET_NAME,
                'file_key': stage_s3_file_key,
                'local_path': LOCAL_STAGE_PATH
            },
        )

        load_to_dwh_task = SQLExecuteQueryOperator(
            task_id='load_to_dwh',
            conn_id=DWH_CONN,
            sql=loading_sql_list,

        )

        download_s3_file_task >> load_to_dwh_task

    return dag
