import sys
from pathlib import Path

from airflow import DAG
from airflow.providers.ssh.operators.ssh import SSHOperator

sys.path.append(str(Path(__file__).parent.absolute()))

from common_utils.defaults import (
    DAG_DEFAULTS,
    DBT_SSH_CONN,
)

extra_defaults = {
    "cmd_timeout": None,
}

with DAG(
    'load_dm',
    schedule_interval=None,
    default_args=DAG_DEFAULTS | extra_defaults,
    catchup=False,
    tags=['dbt', 'ssh', 'dm']
):

    run_dm_models_task = SSHOperator(
        task_id='run_dm_models',
        ssh_conn_id=DBT_SSH_CONN,
        command='dbt run -s tag:dm',
    )

    test_dm_models_task = SSHOperator(
        task_id='test_dm_models',
        ssh_conn_id=DBT_SSH_CONN,
        command='dbt test -s tag:dm',
    )

    run_dm_models_task >> test_dm_models_task
