Why Spark?
----------

Lately I have been working on a project that requires cleaning and analyzing a large volume of event-level data. 

Originally, I did some exploratory data analysis on small samples of data (up to 15 million rows) using pandas, my usual data visualization tools, and multiprocessing. But then it was time to scale up. 

Why Spark is good for this
--------------------------

Distributed processing means it's very fast at very large scale, and we can scale it up with minimal adjustments (the same code still works, we just need a bigger cluster). 

It's very readable, re-usable and unit-testable. That means it's very maintainable, which makes it easier to hand off than some older map reduce tools (my team has traditionally used Pig). 

The output can be dataframes, or tables in various formats. 

It also incorporates SQL, which can be used for filtering, joining, grouping, and aggregations. 

Finally, it has functionality for machine learning, which means we could build the next parts of this project in the same place using the same tools, which also makes it easier to maintain. 

What my python script was doing
-------------------------------

 1. Read in files
 2. Filter for the types of rows we care about
 3. Parse out some fields
 4. Run some helper functions to make some things more human-readable 
 5. Deal with missing values
 6. Convert some fields to boolean flags
 7. Optional steps to join to other tables, group, aggregate, etc. 
 8. Write out a pandas dataframe and/or CSV files, with or without compression 

My first question: why is making dataframes in spark so hard?
----------------------------------------

First, there are too many ways to do it. Most of the ways I found on Teh Internet don't work because the syntax is changing so rapidly, and there are a lot of unwritten rules. Also, it's a lot dumber than pandas. Pandas is really good at two things that make your life easy, and if you're just starting out with pyspark you will miss these things dearly: 

(1) automatic type inference
(2) dealing with missing values, so you don't have to

What I ended up doing:
---------------------

1. Parse lines into RDDs, zipWithIndex, and use a lambda function to swap (val, index) to get (index, val) 

2. Make sure every item has a key (I chose to use dicts). These will become the column names (see more below).

	My items now each look like this:
	```python
	one = lines.take(1)
	assert (one == (1, {'first_column': 100}))
	```

3. Fill any missing values with 'None' (because `None` leads to weird behavior with join, I found it was better to use strings) to square everything up, because otherwise it's impossible to convert to dataframe.

4. Join RDDs on the index

5. Drop the index with a lambda function, because we don't want it in the dataframe, and we won't use it for ordering or lookups

6. Flatten everything (with a flatMap lambda function)

7. Convert to Row objects with a helper function

	```python
	#this method is from StackOverflow, but it really should be built-in (!)

	from collections import OrderedDict
	from pyspark.sql import Row

	def convert_to_row(inputdict):
		'''
		For creating a pyspark DataFrame from Row objects, have to convert to Row objects first

		Note: python3 sorts the input dict by default

		:param: inputdict (dict) of {colname : value}
		:returns: pyspark Row object
		'''
		return Row(**OrderedDict(inputdict)) #Note that only the kwargs version of ** dictionary expansion is supported in python 3.4
	```

8. Convert big RDD of Row objects to dataframe

	```python
	df = deindexed.map(ph.convert_to_row).toDF()
	```

9. Rename any columns that aren't compatible with the ultimate destination, e.g. in my case I had to convert things like "req.id" and "device-type" to "req_id" and "device_type" because Redshift and Athena will not tolerate period symbols or dashes in column names. 

	1) create the list of df.columns, just like you would in pandas
	2) create a new dataframe with the new columns like this: 
		```python 
		renamed = df.toDF(*df_columns) #note that the asterisk splat operator is supported even in python3.4, even though the ** dictionary expansion is not supported until later versions
		```

10. Write out with coalesce to avoid getting a ton of tiny files

The actual parsing ended up being a series of regular expressions, wrapped in a helper to catch exceptions (which is basically just a try:except that says it's ok if there's no match, just fill with 'None' instead of freaking out). I also had to write a helper to flatten, because I was doing this on AWS, and the latest version of python they support is 3.4, which does not include the compact double-asterisk syntax for flattening dictionaries).  


My next question: How do I deploy this thing to run on AWS?
---------------------------------------------

I had trouble finding step-by-step instructions on this part, so here's what I ended up doing:

1. Write a script to load code to s3 (I used boto3)
2. Write a script to copy code from s3 to hadoop home on the EMR cluster (I did this with bash)
3. Write a script (and/or in my case, an Airflow plugin) to spin up and configure the EMR cluster
4. Write steps to bootstrap pyspark with the code, install dependencies, and run with python3
5. Create an EC2 key pair using ssh keygen, if you don't have one already. You need this to spin up the cluster, but more importantly, to be able to log into it for debugging (you want this)
6. setMaster("yarn-client")
7. addPyFile to SparkContext() so it can find your helper scripts
8. Make sure you know if auto-terminate should be on or off, depending on where you are in the development cycle (can't log into debug on a cluster that auto-terminated already!) and whether your job will be running continuously or not. 

I used a YAML file for my configuration, which includes things like the region_name, number of instances, which ec2 key pairs to use, the path to where the logs should go on s3, etc. This is really easy to import in python:

```python
with open("config.yml", 'r') as f:
   config = yaml.load(f)
config_emr = config.get("emr")

cluster_name = config_emr.get('cluster_name')
```

Other things that were non-obvious:
-----------------------------------

When I went to scale up the job to run on more data, I did run into some problems I hadn't had before. 

I had to do some funky things to get the spark unit tests to work correctly. If you want to have anything that uses the spark context object, e.g. using `sc.textFile` to read in a local file, you'll have to do this first, even if your tests don't require any other setUp:

```python

from sparktestingbase.testcase import SparkTestingBaseTestCase

class TestFileParsing(SparkTestingBaseTestCase):

	def setUp(self):
		super().setUp()

```

At the beginning, it wasn't obvious to me that zipWithIndex appends the index in the 'value' or second position in the (key, value) tuple. So you have to use a lambda function to swap it to the front, because joins only work on the 'key'. This seems like a strange design choice to me, although I can understand that append is always easier and there are probably (?) some use cases where you want an index but aren't using it for joins (I just can't think what those would be?).

After my initial script was working, I ended up refactoring to remove some joins, because they involve shuffle steps, which you want to avoid in spark because they're slow and memory-intensive. This was actually pretty easy to fix because I had plenty of tests. 

I also ended up having to explicitly `repartition` and `persist()` my original big RDD and then explicitly `unpersist()` at the end, because although pyspark is supposed to be smart about handling this kind of stuff for you, it wasn't quite smart enough to do it when I was running my methods on chunks of files iteratively.  

I also ran into some serious irritations with AWS configurations, because we have data stored in different regions, and some regions (like eu-central-1 in Frankfurt) require a little extra information for security reasons. It's also confusing that `zone` can have an extra specification, e.g for zone it has to be "us-east-1a" but `region` has to be "us-east-1", or you'll get 'cluster id is None' errors. 

The special trick for Europe is that you have to specify the s3 host yourself and include that in your `s3_additional_kwargs` (this took a bit of googling to find out, so I'm putting it here for safekeeping):

```python
if region == 'eu-central-1':
	host = 's3.eu-central-1.amazonaws.com'
```

Other irritations include having to set up separate EC2 keys in each region; having to deal with multiple profiles for cross-account access (because the log data are owned by one AWS account and the s3 buckets and spark cluster are owned by another); having to deal with setting s3 bucket policies... So maybe all of that could be its own post, but ugh so boring (!). 

Finally, I did end up having to adjust the driver-memory to 10G, executory-memory to 8G, executor-cores to 5, and num-executors to 17. This took some fiddling and it may not be the final configuration, given that we are currently using r3.2xlarge to avoid having to deal with additional configuration requirements for some of the newer instance types, but there are a limited number of instances of this type available in some regions. 

I also added a bunch of handling using `except Py4JavaError` to deal with things like missing, empty, and corrupt files on s3. 





