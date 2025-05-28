""" DAG for run all stage loading DAGs"""

import sys
from pathlib import Path

from airflow.models.dag import DAG
from airflow.operators.trigger_dagrun import TriggerDagRunOperator

sys.path.append(str(Path(__file__).parent.absolute()))

from common_utils.defaults import (
    DAG_DEFAULTS,
)

extra_defaults = {
    "trigger_run_id": "{{ dag_run.run_id }}",
    "logical_date": "{{ logical_date }}",
    "reset_dag_run": True,
    "wait_for_completion": True,
}

with DAG(
        dag_id='load_from_sources_to_dm',
        default_args=DAG_DEFAULTS | extra_defaults,
        schedule_interval=None,
        tags=['toplevel']
) as dag:

    load_stage_all_task = TriggerDagRunOperator(
        task_id="load_stage_all",
        trigger_dag_id="load_stage_all",
    )

    load_dds_task = TriggerDagRunOperator(
        task_id="load_dds",
        trigger_dag_id="load_dds",
    )

    load_dm_task = TriggerDagRunOperator(
        task_id="load_dm",
        trigger_dag_id="load_dm",
    )

    load_stage_all_task >> load_dds_task >> load_dm_task

