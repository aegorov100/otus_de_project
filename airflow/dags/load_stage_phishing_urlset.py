''' DAG for loading data file 'Phishing URL set' from S3 bucket to staging schema in DWH '''

import sys
from pathlib import Path

from airflow import DAG

sys.path.append(str(Path(__file__).parent.absolute()))

from common_utils.stage_utils import generate_s3_to_stage_dag

dag: DAG = generate_s3_to_stage_dag(
    dag_id='load_stage_phishing_urlset',
    s3_file_name='phishing_urlset.csv',
    stage_table='phishing_urlset',
    stage_table_columns=[
        'domain', 'ranking', 'mld_res', 'mld_ps_res', 'card_rem', 
        'ratio_r_rem', 'ratio_a_rem', 'jaccard_rr', 'jaccard_ra', 
        'jaccard_ar', 'jaccard_aa', 'jaccard_ar_rd', 'jaccard_ar_rem', 'label'
    ],
    description='Загрузка файла данных "Phishing URL set"',
)
