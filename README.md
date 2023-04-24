# data-pipelines
Data pipelines using python and AWS.


In this data pipeline, I generate the unload query using a function for all the types of queries we wish to unload on to S3.
 
A couple of things to note before I explain further:

1. Unload and Copy are redshift commands. To move data between redshfit and S3, I use the unload command directly on redshift and then AWS redshift sends our data to the S3 bucket that we specify in the Unload command. 

2. There is a limitation to the unload command in AWS Redshift. The max one time unload capacity of AWS redshift is 6.2GB, so if a file is bigger than that, AWS would, by default, split it. To make data transfer easily trackable, everytime AWS unloads a file, it adds 000 at the end of it. 

Brief explaination:

When the unload_sales_data() is triggered by airflow, it sends the select query which specifies the data it wants to move to the generate_query() method which returns the fully formed query back to it. This call will integrate the select query with the unload query. 

Thereafter, we use psycopg2 to run this query on redshfit which will unload it to the S3 bucket specified in the unload query.

Remember the limitation mentioned in point 2?

We get over it by sending the file name which we just sent to aws_cli_rename() method. This method will copy the data from the old file to the new file with the name that we want, we also delete the old file with the weird naming convention :)


# Airflow: 

We schedule this pipeline to run every day at 9 AM (schedule_interval='00 16 * * *'). We have a send slack method here which we use to send a confirmation message on slack everytime the file is sent. We get the slack information that we have stored in the variables of airflow.

The first task will call the unload method which calls the generate query method and the aws command line rename method to complete our tasks. 
The second task calls the method which we use to send our slack confirmation. 

Happy to receive feedback on how to improve this pipeline.

Thanks!!
