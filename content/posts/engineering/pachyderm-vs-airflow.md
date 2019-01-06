---
title: "Pachyderm vs Airflow"
date: 2018-12-02T17:10:01-08:00
draft: false
---
If you do a lot of data pipelining, you've probably heard a lot about Airflow by now. I gave a talk
about it a while back at a meetup, and wrote a blog post about it. The gist of my pitch for Airflow
was essentially *"Look, it's so much better than cron."*

Fast-forward a year or two, and my team is using Pachyderm now. This post is about why I wanted to try Pachyderm, 
what I love about it, some things that can be improved about it, and some of the tricks you'll need to know if you want to start using it. 

*Note: I am not in any way being paid by Pachyderm.* 

----
# What is appealing about Pachyderm

- Designed for a machine learning model workflow, but can also handle regular data pipelining
(including cron-style scheduling). This is incredibly reassuring to me, because Airflow is kind of the other way around.

- Scalability (parallelization support). I haven't done much with this yet, but it's also reassuring to know it's there,
since we're a rapidly growing company, and I'm sure our data needs are going to continue to expand. 

- Data and code provenance tracking are built-in. 

*What that means:* It's easy to figure out what version
 of your code was running at any given time, and on what data. This is critical if you're iterating on 
 code for ETL processes or  
 models, or tracking a model that's going to evolve over time based on what data it has seen.

- The egress feature and built-in feed-forward are amazingly elegant.  

Feed-forward (I don't know what they call it, that's just what I call it) means 
you can have one pipeline read from the output of another, and trigger off of that directly. 

In Airflow, for comparison, you had to configure this with messaging and it was kind of clunky 
(and originally there was no push, only pull, so you were always polling for *is that thing done yet?*). 

In Pachyderm, it's an extremely simple configuration. 

Egress means you don't have to write a plugin to do something as basic as push your data to s3. Pachyderm already
knows how to do that for you (see below for an example of how this is specified in a pipeline). 

There's also an easy way to tell it to re-process as much data as you want (*except for cron inputs, but they're
going to fix that).

- Not having to clean up the fallout from runaway backfills

Runaway backfill in Airflow made our server fall down more than once whenever anybody 
forgot to update the start date or name of their DAG. This was a built-int default setting that we couldn't change, 
where Airflow would try to backfill any missing data to the beginning of time
(1970, of course), and celery would get overloaded. 

We tried numerous approaches to make it impossible to do this
by accident, including having tests for checking that the start_date for a revised DAG 
was always after the date of the latest changes. 

It was the bane of my Airflow existence. Clearing the celery cache
and getting it to restart, and then backfill what we _actually_ wanted was always a time-consuming process, including
kicking the web server again and getting everything back online. 

- Smart re-tries by default (and this is configurable). 

Having retries at all was a big advantage of Airflow over basic cron, especially since it's modular, so you can
have different re-try settings for each step of an ETL pipeline. 

Having said that, this was a also kind of a pain to deal with in Airflow, because 
if somebody set a ridiculous number of retries, or a backfill job was failing, 
it could easily become a blocker for unrelated pipelines just by 
gunking up the celery queue with tons of re-tries for something that was
 already failing (see above re: runaway backfill). 
 
With Airflow, we were always having to guess about how many 
retries to do, and how much back-off to add in between tries. 

Pachyderm's defaults for this are completely reasonable
(3 retries, with increasing delay in between each try).

If you get the enterprise version (which is cheap for an enterprise product):
- It's more secure than Airflow, with built-in encryption (There's also no risk of exposing
passwords by printing all the logs to a webpage that anyone can see, the way Airflow did by default.)
- Really responsive and smart team, and a growing community of users
- Nice dashboard to go with the CLI tool

- Finally, if you don't like writing DAGs in Airflow, and are considering one of the myriad (!) new tools
to simplify that for you, this is even simpler than that. (And in my opinion, makes a lot more sense.) 

And here's an example of a full ETL process with 3 pipeline steps:

**1. Get the data from an api**


    {
        "pipeline": {
           "name": "api_to_s3_pipeline"
        },
        
        "transform": {
           "cmd": ["python3", "get_requests.py"],
           "image": "pathto.ecr.region.aws.com/mydockerregistry:my_api_image_v1",
           "image_pull_secrets": ["regcred"]
        },
        "input":{
            "cron": {
                "name": "api_daily_job",
                "spec": "16 6 * * *",
                "repo": "api_to_s3"
             }
        },
        "egress": {"URL": "s3://mys3bucket/"},
        "enable_stats": true,
        "job_timeout": 10m
    }
    
**2. Process the data with pyspark on kubernetes**

    {
        "pipeline": {
           "name": "pyspark_pipeline"
        },
        
        "transform": {
           "cmd": ["python3", "pyspark_processsing.py"],
           "image": "pathto.ecr.region.aws.com/mydockerregistry:my_pyspark_image_v1",
           "image_pull_secrets": ["regcred"]
        },
        "input":{
            "atom": {
                "name": "pyspark_daily_job",
                "repo": "pyspark_daily_job",
                "glob: "/*/*/*/"
             }
        },
        "egress": {"URL": "s3://my-pyspark-bucket/"},
        "enable_stats": true,
        "job_timeout": 120m
    }
    
**3. Load the data to Redshift**

    {
        "pipeline": {
           "name": "load_to_redshift_pipeline"
        },
        
        "transform": {
           "cmd": ["python3", "load_to_redshift.py"],
           "image": "pathto.ecr.region.aws.com/mydockerregistry:my_psycopg2_image_v1",
           "image_pull_secrets": ["regcred"]
        },
        "input":{
            "atom": {
                "name": "daily_load_job",
                "repo": "daily_load_job",
                "glob: "daily_*.gz"
             }
        },
        "enable_stats": true,
        "job_timeout": 125m
    }


Also, they just got Series A funding, so they're going to be around for a while. 

---
# The tradeoffs of kubernetes and containerization

This was my first time using kubernetes, never mind suddenly being in charge of it (!). 

Fair warning: Minikube is deceptively easy to set up and use for very basic testing. If this is all you do with 
kubernetes, you'll think Kubernetes very simple. 

Kubernetes itself
isn't that hard to deploy if you know what needs to be configured, but I really didn't
know any of that when I started. I ran into some weird issues where the kubernetes control script
kubectl didn't set the permissions correctly on some of the config files, stuff like that. 

In case you're wondering, as did almost everyone I spoke to while I was doing this, 
EKS on AWS is not really ready for prime-time yet, so 
I ended up relying on a script that the Pachyderm guys wrote to deploy Kubernetes
directly on EC2, and just adapted that for our needs. 

Things that are great about deploying in the cloud:
- Encapsulation is your friend. It's so much easier when you have complete control of the environment, and there's no mystery 
about what packages are available or what the paths are. Scaling becomes relatively easy. Just split your data and run
more jobs in parallel. 

Things to remember about deploying in the cloud:
- Logging is your friend. You won't be able to debug with print statements on a remote, headless machine. Some of my 
teammates didn't quite understand this until they actually did it. Good logging makes it trivially easy to figure out what went wrong.

- Versioning is your friend. Kubernetes won't pull the container unless it knows it needs to, so you have to keep renaming your container
if you want to test changes. It's kind of a pain, but it's simple enough to 
just make it part of the workflow (and our next step is to have Jenkins do this for us as part of our
CICD workflow). 

- Having to rebuild the container and version it and push it up each time does a couple of things:

a) Testing is even more important. It's a lot nicer if you can do enough testing that after a few bug fixes you're on version 4, rather than
(as one of my early pipelines is) version 16. 

b) It can be a little bit more annoying to push bug fixes/updates (especially without a CICD system
to build and deploy the containers for you)

____

# The learning curve (at least for me)

- People steered us away from EKS, so then setting up our own kubernetes cluster without a 
devops person (!) was challenging, mostly because of
- AWS permissions issues, including but not limited to:

    a) giving the cluster the ability to run queries on the RDS database in the same account
    
    b) creating a separate VPC for Redshift so I could create a peering connection for that (see separate post)
    
    c) giving the cluster the ability to access s3 buckets
    
    d) giving my team access to the docker registries on ECS
    
    e) stupid things like legacy s3 bucket region restrictions that are (or should be?)
    going away any minute now(?), but EC2 still cares about, which generate completely
    uninformative AccessDenied errors
   
- Figuring out the workflow for deploying and debugging. This was a little weird at first, but once I got the hang of it,
 actually very easy (more on that below)
 
- Setting up a docker registry and using that (and we don't have Jenkins handling that for us yet)
- Managing two clusters on two separate accounts, and switching between them (learning in hard mode is not
 always twice as fun as just learning!)
- There is a built-in outlet to connect Pachyderm up with Prometheus, but no built-in monitoring means we're doing it downstream
(i.e with automated email alerts sent from Looker if something fails) or manually checking via the
CLI or dashboard view. I have been using the CLI thus far, but now that we have more than a few pipelines 
going on one cluster, the dashboard is starting to make more sense.

- Understanding how the pachyderm filesystem (pfs) and egress work, and coding accordingly (more on that in the next section).
____

# Some things that are currently being improved

- The docs are being updated all the time. There are a lot of platform-specific (read
Google Cloud or AWS or whatever) things that users are finding and contributing. 

- The deployment/upgrade process is still a little bit under construction and not
all features are supported for all versions yet, but mostly it just works.

- Logging/visibility is not bad now, but could be better. Basically you have to make sure your logging is sufficiently noisy and has
timestamps, or you might find yourself wondering why you can't tell what time a retry happened. 

- Minor configuration things that maybe most people wouldn't care about, but which affect us
with our cross-account access issues (like the ability to pass a region and/or profile flag to the egress 
if you need that). 

- With my current setup, I'm not sure how I can have two dashboards for two clusters going at once. I'm sure there's a way. 
I just haven't had time to figure it out yet. 

- Some silly timeout issues, like in the example above, the load_to_redshift pipeline has to 'run' for as long as
the job before it, because it wants to start trying to load data as soon as the one before it starts running. So the actual
process might take less than 5 minutes, but if it tries to run before the upstream pipeline finishes, it will fail. This is 
easy enough to work around for now (now that we know about it).

- It's easy to re-process a whole pipeline, but it's not easy to pass a list of failed jobs and only re-process those,
for example with an ETL job that only fails intermittently (I had one that was timing out every few days
over the holidays, when I was out on vacation and the data got too big to finish in the time I had allotted)
____

# Using the pachyderm filesystem for ingress, and best practices for egress with s3

*Note: Pachyderm is under rapid development (it's open-source, and I'm a watcher on the repo so I'm constantly seeing all the work they're 
doing), so some of this may already be out of date by the time I actually post it.*
 
At the time of this writing, my team is using version 1.7.11. 

One thing to note about Pachyderm: the equivalent of a DAG here is composed of multiple pipelines (each pipeline can be one
or more tasks). 

To make my life easier, I've been naming the repositories and the pipelines
with the same string. You'll see why that's helpful when you have several pipelines you want to string together. 

So for example I have one ETL job I just finished, which goes like this (names have been changed for security reasons):
1. data-api
2. data-parsing
3. data-loading-to-db

The simplest thing to do with the output of a job on pachyderm
is to write it to `/pfs/out`. 

So let's say you're running `data-parsing-pipeline`. That pipeline writes to `/pfs/out`. 
Then the next pipeline can pick it up from there in a folder named for the upstream pipeline's internal pfs repository, in this case
it would be `/pfs/data-parsing-pipeline/`.  

One thing to note, if you want to follow s3 best practices (see my other
post) for partitioning file names with forward slashes, you'll have to actually make those sub-directories inside the 
pachyderm filesystem. 

Otherwise, you're going to write out `mydatafile.csv` and then you'll want to put something like 
`s3://mybucket/2018/12/08/` for egress, but what you'll end up with in s3 is just `s3://mybucket/mydatafile.csv`. 

(And in case
it's not obvious, the reason you may not want that is you either have to put some other identifier in the file names, or you're going to be 
overwriting the files every time the pipeline runs).

---
# TL;DR

Almost every
problem we've run into (aside from the AWS headaches) were because I didn't know what I was doing, or had a bug in my code, or the data got too
big for the space or time I had allocated for a given step. So, the usual reasons why anything (everything) fails in
in software. 

I like that we can all interact with the cluster
directly from our own machines, using the CLI, for quickly debugging. It has been fairly easy for my team
to start learning how to write and run pipelines, because they're just json. 

There are some features that can be improved, and that's actually happening. 
So overall, I'm a huge fan. So far Pachyderm has been rock-solid on the stuff it's running. In that sense,
it has been a lot easier to deal with than Airflow. 





