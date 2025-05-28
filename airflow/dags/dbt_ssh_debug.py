from airflow import DAG
from airflow.providers.ssh.operators.ssh import SSHOperator
from airflow.utils.dates import days_ago

default_args = {
    'owner': 'airflow',
    'start_date': days_ago(1),
}

with DAG(
    'dbt_ssh_debug',
    schedule_interval=None,
    default_args=default_args,
    catchup=False,
    tags=['dbt', 'ssh', 'debug']
):


    dbt_debug_task = SSHOperator(
        task_id='run_dbt_debug_via_ssh',
        ssh_conn_id='dbt_ssh',
        command='dbt debug',
    )


