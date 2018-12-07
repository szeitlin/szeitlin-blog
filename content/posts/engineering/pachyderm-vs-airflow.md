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

- **The egress feature and feed-forward are amazingly elegant.**  

Feed-forward means you can have one pipeline read from the output of another, and trigger off of that directly. 

In Airflow, for comparison, you had to configure this with messaging yourself and it was kind of clunky 
(and originally there was no push, only pull, so you were always polling for *is that thing done yet?*). 
In Pachyderm, it's an extremely simple configuration, and there's an easy way to tell it to re-process as much data as you want.

Egress means you don't have to write a plugin to do something as basic as push your data to s3. Pachyderm already
knows how to do that for you (see below for an example of how this is specified in a pipeline). 

- Smart re-tries by default (and this is configurable). This was also kind of a pain to deal with in Airflow because 
if you forgot or somebody set a ridiculous number of retries, it could be a blocker for unrelated pipelines just by 
gunking up the celery queue. 
- Designed for machine learning model workflow, but can also handle regular data pipelining
(including cron-style scheduling)
- Scalability (parallelization support)

If you get the enterprise version (which is cheap for an enterprise product):
- Built-in encryption
- Really responsive and smart team
- Really nice dashboard and simple CLI tool

- Also, if you don't like writing DAGs in Airflow, and are considering one of the myriad new tools <links here> 
to do that for you, this is a lot simpler, and in my opinion, makes a lot more sense. 

Here's an example of a single pipeline:

And here's an example of a full ETL process with 3 pipeline steps:

Finally, they just got Series A funding, so they're going to be around for a while. 

2. The tradeoffs of kubernetes and containerization

This was my first time using kubernetes, never mind suddenly being in charge of it. 
Minikube is deceptively easy to set up and use for very basic testing. Kubernetes itself
isn't even that hard to deploy if you know what needs to be configured, but I really didn't
know any of that when I started. I ended up relying on a script
that the Pachyderm guys wrote and just adapted that for our needs. 

Friends:
- encapsulation is your friend
- logging is your friend
- versioning is your friend

- having to rebuild the container and version it and push it up each time does a couple of things:
a) testing is even more important
b) a little bit more annoying to push bug fixes/updates (especially without a CICD system
to build and deploy the containers for you)

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
   
- Understanding how the pachyderm filesystem (pfs) and egress work, and coding accordingly. (elaborate on this here)

- Figuring out the workflow for deploying and debugging 
- Setting up a docker registry and using that (and don't have Jenkins running with handling that for us yet)
- Managing two clusters and switching between them (learning in hard mode is not twice as fun as just learning!)
- There is a built-in outlet to connect it up with Prometheus, but no built-in monitoring means we're doing it downstream
(i.e with automated email alerts sent from Looker if something fails) or manually checking via the
CLI or dashboard view (I have been using the CLI thus far, but now that we have more than a few pipelines 
going on one cluster, the dashboard is starting to make more sense).

4. Some things that are currently being improved

- The docs are being updated all the time. There are a lot of platform-specific (read
Google Cloud or AWS or whatever) things that users are finding and contributing. 
- The deployment/upgrade process is still a little bit under construction and not
all features are supported for all versions yet, but mostly it just works.
- Logging/visibility is not bad now, but could be better. 
- Minor configuration things that maybe most people wouldn't care about, but which affect us
with our cross-account access issues (like the ability to pass a region and/or profile flag to the egress 
if you need that). 
- With my current setup, I'm not sure how I can have two dashboards going at once. 



