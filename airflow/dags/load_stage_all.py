""" DAG for run all stage loading DAGs"""

import sys
from pathlib import Path

from airflow.models.dag import DAG
from airflow.operators.empty import EmptyOperator
from airflow.operators.trigger_dagrun import TriggerDagRunOperator

sys.path.append(str(Path(__file__).parent.absolute()))

from common_utils.defaults import (
    DAG_DEFAULTS,
    STAGE_TAGS,
)

extra_defaults = {
    "trigger_run_id": "{{ dag_run.run_id }}",
    "logical_date": "{{ logical_date }}",
    "reset_dag_run": True,
    "wait_for_completion": True,
}

with DAG(
        dag_id='load_stage_all',
        default_args=DAG_DEFAULTS | extra_defaults,
        schedule_interval=None,
        tags=STAGE_TAGS
) as dag:

    start_task = EmptyOperator(task_id='start')

    load_stage_a_records_task = TriggerDagRunOperator(
        task_id="load_stage_a_records",
        trigger_dag_id="load_stage_a_records",
    )

    load_stage_abuse_ip_db_task = TriggerDagRunOperator(
        task_id="load_stage_abuse_ip_db",
        trigger_dag_id="load_stage_abuse_ip_db",
    )

    load_stage_cname_records_task = TriggerDagRunOperator(
        task_id="load_stage_cname_records",
        trigger_dag_id="load_stage_cname_records",
    )

    load_stage_malicious_phishing_url_task = TriggerDagRunOperator(
        task_id="load_stage_malicious_phishing_url",
        trigger_dag_id="load_stage_malicious_phishing_url",
    )

    load_stage_phishing_legitimate_url_task = TriggerDagRunOperator(
        task_id="load_stage_phishing_legitimate_url",
        trigger_dag_id="load_stage_phishing_legitimate_url",
    )

    load_stage_phishing_urlset_task = TriggerDagRunOperator(
        task_id="load_stage_phishing_urlset",
        trigger_dag_id="load_stage_phishing_urlset",
    )

    finish_task = EmptyOperator(task_id='finish')

    (start_task >>
     [
         load_stage_a_records_task,
         load_stage_abuse_ip_db_task,
         load_stage_cname_records_task,
         load_stage_malicious_phishing_url_task,
         load_stage_phishing_legitimate_url_task,
         load_stage_phishing_urlset_task
     ] >>
     finish_task)

