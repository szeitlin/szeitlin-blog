---
title: "Pachyderm vs Airflow"
date: 2018-12-02T17:10:01-08:00
draft: true
---
If you do a lot of data pipelining, you've probably heard a lot about Airflow by now. I gave a talk
about it a while back at a meetup, and wrote a blog post about it. The gist of my pitch for Airflow
was essentially *"Look, it's so much better than cron."*

Fast-forward a year or two, and my team is using Pachyderm now. This post is about why I wanted to try Pachyderm, 
what I love about it, and some of the tricks you'll need to know if you want to start using it. 

*Note: I am not in any way being paid by Pachyderm (in fact, we have an enterprise contract with them).* 

----
1. What is appealing about Pachyderm


- **Data and code provenance tracking are built-in.** 

*What that means:* It's incredibly easy to figure out what version
 of your code was running at any given time, and on what data. This is critical if you're iterating on models or tracking
 a model that's going to evolve over time based on what data it has seen.

- **The egress feature and built-in feed-forward are amazingly elegant.**  

Feed-forward (I don't know what they call it, that's just what I call it) is a way of saying 
you can have one pipeline read from the output of another, and trigger off of that directly. 

In Airflow, for comparison, you had to configure this with messaging and it was kind of clunky 
(and originally there was no push, only pull, so you were always polling for *is that thing done yet?*). 

In Pachyderm, it's an extremely simple configuration. 

Egress means you don't have to write a plugin to do something as basic as push your data to s3. Pachyderm already
knows how to do that for you (see below for an example of how this is specified in a pipeline). 

There's also an easy way to tell it to re-process as much data as you want.

- **No runaway backfill**

Runaway backfill in Airflow made our server fall down more than once whenever anybody 
forgot to update the start date or name of their DAG because celery just got overloaded. 

It was the bane of my Airflow existence because clearing the celery cache
and getting it to restart, and then backfill what we _actually_ wanted was always a time-consuming process, including
kicking the web server again and getting everything back online. 

- **Smart re-tries by default (and this is configurable).** 

This was also kind of a pain to deal with in Airflow because 
if somebody set a ridiculous number of retries, or a backfill job was failing, 
it could easily become a blocker for unrelated pipelines just by 
gunking up the celery queue (see above re: runaway backfill). 

- Designed for a machine learning model workflow, but can also handle regular data pipelining
(including cron-style scheduling). This is incredibly reassuring to me, because Airflow is kind of the other way around.

- Scalability (parallelization support). I haven't done much with this yet, but it's also reassuring to know it's there,
since we're a rapidly growing company, and I'm sure our data needs are going to continue to expand. 

If you get the enterprise version (which is cheap for an enterprise product):
- Built-in encryption
- Really responsive and smart team
- Really nice dashboard and simple CLI tool

- Also, if you don't like writing DAGs in Airflow, and are considering one of the myriad (!) new tools
to simplify that for you, this is even simpler than that. (And in my opinion, makes a lot more sense.) 

Here's an example of a single pipeline:

And here's an example of a full ETL process with 3 pipeline steps:

Also, they just got Series A funding, so they're going to be around for a while. 

---
2. The tradeoffs of kubernetes and containerization

This was my first time using kubernetes, never mind suddenly being in charge of it (!). 

Minikube is deceptively easy to set up and use for very basic testing. 

Kubernetes itself
isn't even that hard to deploy if you know what needs to be configured, but I really didn't
know any of that when I started. I ended up relying on a script
that the Pachyderm guys wrote and just adapted that for our needs. 

Things to remember for deploying in the cloud:
- Encapsulation is your friend. It's so much easier when you have complete control of the environment, and there's no mystery 
about what packages are available or what the paths are. Scaling becomes relatively easy. Just split your data and run
more jobs in parallel. 

- Logging is your friend. You won't be able to debug with print statements on a remote, headless machine. Some of my 
teammates didn't quite understand this until they actually did it. Good logging makes it trivially easy to figure out what went wrong.

- Versioning is your friend. Kubernetes won't pull the container unless it knows it needs to, so you have to keep renaming your container
if you want to test changes. It's kind of a pain, but it's simple enough to just make it part of the workflow. 

- Having to rebuild the container and version it and push it up each time does a couple of things:
a) Testing is even more important. It's a lot nicer if you can do enough testing that after a few bug fixes you're on version 4, rather than
(as one of my early pipelines is) version 16. 
b) It can be a little bit more annoying to push bug fixes/updates (especially without a CICD system
to build and deploy the containers for you)

____

3. The learning curve (at least for me)

- People steered us away from EKS, so then setting up our own kubernetes cluster without a 
devops person (!)
- AWS permissions issues, including but not limited to:

    a) giving the cluster the ability to run queries on the RDS database in the same account
    
    b) creating a separate VPC for Redshift so I could create a peering connection for that (see separate post)
    
    c) giving the cluster the ability to access s3 buckets
    
    d) giving my team access to the docker registries on ECS
    
    e) stupid things like legacy s3 bucket region restrictions that are (or should be?)
    going away any minute now(?), but EC2 still cares about, which generate completely
    uninformative AccessDenied errors
   
- Figuring out the workflow for deploying and debugging 
- Setting up a docker registry and using that (and don't have Jenkins running with handling that for us yet)
- Managing two clusters and switching between them (learning in hard mode is not twice as fun as just learning!)
- There is a built-in outlet to connect it up with Prometheus, but no built-in monitoring means we're doing it downstream
(i.e with automated email alerts sent from Looker if something fails) or manually checking via the
CLI or dashboard view (I have been using the CLI thus far, but now that we have more than a few pipelines 
going on one cluster, the dashboard is starting to make more sense).

- Understanding how the pachyderm filesystem (pfs) and egress work, and coding accordingly (more on that in the next section).
____

4. Some things that are currently being improved

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
____

**Using the pachyderm filesystem for ingress, and best practices for egress with s3**

*Note: Pachyderm is under rapid development (it's open-source, and I'm a watcher on the repo so I'm constantly seeing all the work they're 
doing), so some of this may already be out of date by the time I actually post it.*
 
At the time of this writing, we're on version 1.7.11. 

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

