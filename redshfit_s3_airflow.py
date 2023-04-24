"""DAG that sends files to the third party S3 bucket"""
​
from airflow.models import (
    DAG,
    Variable,
)
import datetime
from airflow.operators.postgres_operator import PostgresOperator
from airflow.operators.python_operator import PythonOperator
from airflow.operators.slack_operator import SlackAPIPostOperator
from airflow.hooks.postgres_hook import PostgresHook
from psycopg2.extras import DictCursor
​
from airflow import AirflowException
​
from tempfile import NamedTemporaryFile
from airflow.models import Connection
from airflow.utils.db import provide_session
from tools import settings
from slackclient import SlackClient
import re
​
import logging
import traceback
import time
import boto3
​
​
​
logger = logging.getLogger(_name_)
​
DURATION_THRESHOLD_ALERT = 60 * 60 * 1000 * 1000  # 1 hour.
schedule_interval = '00 16 * * *'
​
​
​
​
args = {
'owner': 'self',
'email': ['your.address@provider.com'],
'depends_on_past': False,
'email_on_failure': True,
'email_on_retry': True,
'retries': 1,
'retry_delay': datetime.timedelta(minutes=5),
'start_date': datetime.datetime(2010, 1, 1)
}
​
dag = DAG(
    dag_id="data_pipeline_redshift_s3",
    default_args=args,
    schedule_interval='00 16 * * *',
    max_active_runs=1,
    catchup=False
)
​
s3bucket = 's3://bucket-name/'
access_key='LASKDJFSDJFLSDJFLSDD'
secret_access_key='sdlkfjsdlfjsdlf/slkdfjsdfs'
timestr = time.strftime("%Y%m%d")
​
​
​
try:
​
​#AWS appends 000 to every file it unloads, which sucks. So keep the naming nice and pretty,
#we copy the data to another file with
    def aws_cli_rename(old_file_name):
        aws_naming_extension = '000.gz'
        logger.info('param received for renaming: ', old_file_name)
​
        new_file=old_file_name+'.gz'
        logger.info('new file name is: ' + new_file)
        old_file_sent=old_file_name+aws_naming_extension
        logger.info('File name created by aws is ' + old_file_name + aws_naming_extension)
​
        s3 = boto3.client('s3', aws_access_key_id=access_key, aws_secret_access_key=secret_access_key)
​
        bucket = s3bucket.split('//')[1].split('/')[0]
        logger.info('S3 bucket is: ' + bucket)
        #prefix used to add folders inside S3
        prefix = '/'.join(s3bucket.split('//')[1].split('/')[1:])
        logger.info('S3 prefix(unused) is: ' + bucket)
​
        key = new_file
        copy_source = bucket+'/'+old_file_sent
​
        kwargs = {'Bucket': bucket, 'Key': key, 'CopySource':copy_source}
​
        s3.copy_object(**kwargs)
        #s3.Object(bucket,new_file).copy_from(CopySource=copy_source)
        logger.info('data copied to new file')
        s3.delete_object(Bucket=bucket, Key=old_file_sent)
        logger.info('old file deleted')
​
        return
​
#This method generates the unload query for the type of select query that you want.
#The unload method calls this methods and receives back the propery generated unload query
​
    def generate_query(file_type_param,select_query):
​
        try:
​
            filetype=file_type_param
            select_query=select_query
​
            sales_query_message=('Processing sales data for '+timestr)
​
            if filetype=='sales':
                logger.info(order_details_message)
                print sales_query_message
​
            else:
                raise AttributeError('File name passed not recognized. We only send sales query to our 3rd party s3 bucket')
​
​
            filename_today='{filetype}_{date}'.format(filetype=filetype,date=time.strftime("%Y%m%d"))
            print ('File name to be sent is ' + filename_today)
​
            unload_query = ''' unload
                            ('{select_query}')
                            to '{s3bucket}{filename}'
                            credentials 'aws_access_key_id={accesskey};aws_secret_access_key={secretaccesskey}'
                            PARALLEL off
                            DELIMITER AS ','
                            REGION 'us-west-2'
                            HEADER
                            ALLOWOVERWRITE
                            gzip
                            ; '''.format(select_query=select_query,s3bucket=s3bucket,filename=filename_today,accesskey=access_key,secretaccesskey=secret_access_key)
​
            return unload_query,filename_today
​
        except AttributeError as ae:
            logger.info(ae)
            print ae
​
        except Exception as e:
            logging.error(traceback.format_exc())
            raise
​
    def unload_sales_data():
​
        select_sales_data='''select * from schemaname.sales'''
        sales_file_type='sales_details'
​
        sales_final_query,sales_filename = generate_query(sales_file_type,select_sales_data)
​
        hooks = [
        PostgresHook(postgres_conn_id="connection_id"),
                ]
        for hook in hooks:
​
            conn = hook.get_conn()
            cursor = conn.cursor(cursor_factory=DictCursor)
            logger.info('executing the sales query now')
            cursor.execute(sales_final_query)
            conn.close()
​
​
        logger.info('Calling the rename method to change file name or sales file.')
        aws_cli_rename(sales_filename)
​
        return
​
​
    def send_slack_unload_sales_data():
​
    	logger.info('sending slack for sales file task completion now')
​
    	slack_client = SlackClient(Variable.get("slack_token"))
    	message = ('sales_details file sent for ' + timestr)
    	logger.info(message)
    	slack_client.api_call(
    	    "chat.postMessage",
    	    channel="#sales_data_daily",
    	    text=message,
    	)


​
except Exception as e:
    logger.info(e)
    logging.error(traceback.format_exc())
    raise
​
​
unload_sales_data_task = PythonOperator(
    task_id="unload_sales_data_task",
    dag=dag,
    python_callable=unload_sales_data,
    execution_timeout=datetime.timedelta(minutes=60),
)
​
​
send_slack_sales_data_task= PythonOperator(
    task_id="send_slack_sales_data_task",
    dag=dag,
    python_callable=send_slack_unload_sales_data,
    execution_timeout=datetime.timedelta(minutes=5),
)
unload_sales_data_task  >> send_slack_sales_data_task
