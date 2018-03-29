---
title: "Airflow"
draft: false
date: 2017-11-18
tags: ["python", "testing"]
author: Samantha G. Zeitlin
---


# Airflow for hands-off ETL
-----

Almost exactly a year ago, I joined [Yahoo][1], which more recently became [Oath][2]. 

The team I joined is called the Product Hackers, and we work with large amounts of data. By large amounts I meant, billions of rows of log data. 

Our team does both ad-hoc analyses and ongoing machine learning projects. In order to support those efforts, our team had initially written scripts to parse logs and run them with cron to load the data into Redshift on AWS. After a while, it made sense to move to [Airflow][3]. 

----------
## Do you need Airflow? ##

 1. How much data do you have?    *A lot*
2. Do you use cron jobs for ETL? How many?     *Too many*
3. Do you have to re-run scripts manually when they fail? How often?      *Yes, often enough to be a pain point*
4. Do you use on-call shifts to help maintain infrastructure?      *Unfortunately, we did*


----------
## What exactly is Airflow? ##

Airflow is an open-source python library. It creates Directed Acyclic Graphs (DAGs) for extracting, transforming, and loading data. 

'Directed' just means the tasks are supposed to be executed in order (although this is not actually required, tasks don't even have to be connected to each other and they'll still run). 'Acyclic' means tasks are not connected in a circle (although you can write loops that generate tasks dynamically, you still don't want circular dependencies). 

A DAG in this case is a python object made up of tasks. A typical DAG might contain tasks that do the kinds of things you might do with cron jobs:

get logs --> parse logs --> create table in database --> load log data into new table

Each DAG step is executed by an Operator (also a python object). 

Operators use Hooks to connect to external resources (like AWS services). 

Task instances refer to attempts to run specific tasks, so they have state that you can view in the dashboard. The state tells you whether that tasks is currently executing, succeeded, failed, skipped, or waiting in the queue. 


----------
## Some tips if you're going to use Airflow ##

### Make your jobs idempotent if possible ###

My team has a couple different types of tables that we load into Redshift. One is the type we call 'metadata', which is typically just a simple mapping that doesn't change very often. For this type of table, when it does change, it's important to drop the old table and re-create it from scratch. This is easier to manage with separate tasks for each SQL step, so the DAG has the following steps: 

get_data --> drop_old_table --> create_new_table --> load_data
 
This way, if any of the steps fail, we can re-start from there, and it doesn't matter if the step was partially completed before it failed. 

The other kind of table we have is an event table, and those are loaded with fresh data every day. We retain the data for 3 days before we start running out of space on the Redshift cluster. This kind of table doesn't really need a drop_old_table step, because the table name includes the date (which makes it easier to find the table you want when you're running queries). However, when we create these tables, we still want to make sure we don't create duplicates, so in the create step we check to see if the table already exists. 

### Get AIRFLOW_HOME depending on where you're running ###

If you want a really stable build that requires the least amount of hands-on maintenance, do yourself a favor and 'productionize' your setup. That means you'll want to run Airflow in at least 3 places:

 1. In a virtual environment on your local machine (we use Docker with Ansible)
 2. In a virtual environment in your continuous integration system (we use Jenkins)
 3. In a virtual environment on your production host (we use virtualenv with python 3)

Note that Airflow doesn't make this easy, so I wrote a little helper script to make sure Airflow has the right configuration files and is able to find the DAGs, both of which are dependent on using the correct AIRFLOW_HOME environment variable. 

Here's the TL;DR:

```python
#If AIRFLOW_HOME environment variable doesn’t exist, it defaults:
    os.getenv('AIRFLOW_HOME', '~/airflow')

#It’s really useful to always check where the code is running:
    homedir = os.getenv('HOME')

#If it’s on Jenkins, there’s an environment variable that gives you the path for that:
    jenkins_path = os.getenv('JENKINS_HOME', None)

#In the Jenkinsfile (without Docker), we’re doing this: 
    withEnv(['AIRFLOW_HOME=/br/airflow'])
    cp -r $PWD/dags $AIRFLOW_HOME/

#If you’re running tests locally, there’s a helper that I stole from inside Airflow’s guts:
    import airflow.configuration as conf
    conf.load_test_config()
    os.environ['TEST_CONFIG_FILE'] = conf.TEST_CONFIG_FILE
```

### Write unit tests for your Operators and your DAGs ###

I hadn't seen anyone doing this for Airflow, but I write tests for all my python code, so why should Airflow be any different?

It's a little unintuitive, because Airflow DAG files are not like regular python files. DAG objects have to be at the top level, so the way I got around this was to grab the dag file and then get each of the task objects as attributes. 

I wrote the tests for the Operators so that they could be easily re-used, since most of our DAGs have similar tasks. This also lets us use unit tests to enforce best practices. 

```python
class TestPostgresOperators:
    """
    Not meant to be used alone
    For use within specific dag test file
    """
    @classmethod
    def setUp(cls, dagfile):
        cls.dagfile = dagfile

    def test_droptable(self, taskname='dropTable'):
        '''
        validate fields here
        check retries number
        :param taskname: str

        '''
       drop = getattr(self.dagfile, taskname)
       assert(0 <= drop.retries <= 5)
       assert(drop.postgres_conn_id=='redshift')
```

Then these 'abstract tests' get instantiated in the test file for a particular DAG, like this:

```python
import advertisers_v2
from test_dag_instantiation import TestDAGInstantiation
from conftest import unittest_config

from test_postgres_operators import TestPostgresOperators
from test_mysql_to_redshift import TestMySQLtoRedshiftOperator

mydag = TestDAGInstantiation()
mydag.setUp(advertisers_v2,unittest_config=unittest_config)
mydag.test_dagname()
mydag.test_default_args()

postgres_tests = TestPostgresOperators()
postgres_tests.setUp(advertisers_v2)
postgres_tests.test_droptable()
postgres_tests.test_createtable()

mysql_to_redshift_tests = TestMySQLtoRedshiftOperator()
mysql_to_redshift_tests.setUp(advertisers_v2)
mysql_to_redshift_tests.test_importstep()
```

Doing it this way makes it ridiculously easy to set up tests, and they can still be parameterized however you want, to test customizations as needed. 


### Some other fun tidbits ###

If you're using XCOMs, the docs are a little bit out of date. This took me a while to figure out, so hopefully it helps save someone else the same pain. Note that this is for version 1.8 (not sure if anything is changing with XCOMs in the newer versions). 

The xcom values are actually stored in the `context` object, so when you go to push them you have to explicitly grab the task instance object to make that work.

Inside the task where you're pushing:

```python
task_instance = context.get('task_instance')
task_instance.xcom_push(name_of_xcom_key, name_of_xcom_value)
```

And then inside the task where you're pulling, you can use the jinja macro with the key name:

```python
"{{ task_instance.xcom_pull(task_ids=name_of_task_that_pushed, key=name_of_xcom_key) }}"
```
 

  [1]: https://www.yahoo.com
  [2]: https://www.oath.com
  [3]: http://pythonhosted.org/airflow/
