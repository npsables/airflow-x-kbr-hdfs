"""
Code that goes along with the Airflow located at:
http://airflow.readthedocs.org/en/latest/tutorial.html
"""
from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime, timedelta


default_args = {
    "owner": "airflow",
    "depends_on_past": False,
    "start_date": datetime(2015, 6, 1),
    "email": ["airflow@airflow.com"],
    "email_on_failure": False,
    "email_on_retry": False,
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

dag = DAG("test", default_args=default_args, catchup=False, schedule_interval=timedelta(1))

cmd = """spark-submit --master yarn --deploy-mode cluster \
                --principal ${KERBEROS_PRINCIPAL} --keytab ${KERBEROS_KEYTAB_PATH} ${AIRFLOW_HOME}/dags/submit.py"""

t1 = BashOperator(task_id="test1", bash_command=cmd, retries=0, dag=dag)
    