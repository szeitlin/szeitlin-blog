---
title: "Dvc_vs_pachyderm"
date: 2021-01-27T13:13:57-08:00
draft: true
---

# DVC vs. Pachyderm

I decided to embark on this comparison mostly out of curiosity. No tool is perfect for all use cases, that's why 
we have forks, and spoons, and sometimes when we're camping, sporks. Although Pachyderm claims to use a git-style 
model for data and code versioning, there are aspects of the Pachyderm model (like forking) that aren't exactly 
like git. So one thing I wanted to know is, how well does this analogy to git work for DVC? And are there use cases
where one should definitely use DVC or Pachyderm? 

So here's the bottom line, and if you want more details, scroll down to read about my experience trying out DVC 
on my own. 

# comparison

Both DVC and Pachyderm can:
- track and save data and ML models 
- connect data transformation steps and models in pipelines
- switch between versions easily*
- easily pull in data from cloud storage, and push back out
- pull in streaming data
- facilitate work on a shared development server (or cluster, in the case of Pachyderm)

One major difference is that Pachyderm expects you to use kubernetes. You can run it locally with minikube, but 
really the whole point is to containerize models. DVC has no such expectation. 

Another major difference is that Pachyderm is designed to serve models, both for development and production. DVC 
isn't a model serving service. 

There are some minor differences, too. Pachyderm uses json for pipeline definitions; DVC uses yaml. Pachyderm has you 
create a separate pipeline file for each step, wherease DVC has you create DAGs, a little more like Airflow (but simpler). 
But these differences are what one of my former coworkers would refer to as "implementation details". 

## todo: could write a whole paragraph about having a whole DAG, vs. a single pipeline step, per file

##todo if time allows, look at CML

##todo: Some intro here about what else dvc can do that Pachyderm doesn't do as easily:
- visualize the structure of a dag with ascii art (this is really cute)
- compare model metrics among experiments, e.g `dvc metrics diff` 

This is a feature I would've love to have in Pachyderm, but it doesn't exist. 


Some links to past posts about pachyderm:
## todo: put link(s) here

____

First, I started trying to go through one of the tutorials, but I don't have enough free space on my laptop!

So, then I thought, let's see if I can do something with a small data set I had leftover from a recent job interview. 

Starting with a folder that has a data file in it, I created an environment: 

`$ conda create -n iterative python=3 pandas numpy scikit-learn jupyter notebook`

Conda install failed with my usual channels and I'm too lazy to look for others, so I did:

`$ pip install dvc`

Then I did 

`$ git init`

and then 

`$ dvc init`

I didn't have to add my data files to my .gitignore, as usual, because dvc takes care of that when you do:

`$ dvc add win-rate-small.data.pickle`

So now files that I'd normally never put into git, are tracked with dvc instead. 
I like this. 

And then I put the tracking file into git for safekeeping:

`$ git add win-rate-small.data.pickle.dvc`

A big advantage of this seems to be if you want to store your large data files
remotely, and then pull them in when you want to work on them. 

I think this is cute, but I'm not sure how it would work in practice. Do you always delete the local copy of the file
to save space? I may just be paranoid, but I always get nervous when I have to delete data, even if I know it's 
backed up somewhere else. I'm not sure if it's just because I first started working with data when disks could go bac
and it took forever to load things, but it just feels weird to me. 

Anyway, in the interest of time, I'm going to skip over this for now and maybe come back later.

____

Next, I went and built a model in a jupyter notebook, and the first version wasn't very good (unsurprisingly). 
Just to be safe, I dumped it out anyway: 

```python
from joblib import dump, load
dump(clf, 'logit_bad.joblib') 
```

Then we add that with `dvc add` and `git add` and `git tag`. Although I don't have aliases for my usual 
git workflow, since this adds another line (or two, with tagging) of typing to every git command, 
if I were going to do this a lot, I would want an alias in my terminal. 

The next thing the tutorial does makes perfect sense: try to improve the model and save another version of it. 

Back to my notebook. 

Since I didn't spend much time on it, the second version of the model isn't much better, but I write out `logit_bad2.joblib` anyway. 

The next step is to demonstrate switching between workspaces, so you can check out the data and the model 
versions easily. This is where I think DVC really shines, and is easier than Pachyderm. 

Because we tagged the versions, it's really trivial to say `git checkout v1.0` and then `dvc checkout`. 

With Pachyderm, at scale anyway, this was not so easy. The times when I needed this the most were not during development, 
though, they were during debugging. And then the hard part was going through to find which chunk of data was
associated with a failed model run, and track back to get the uuid of that commit. It was doable, but it wasn't smooth. 

----

The `dvc get` command is not that different from how Pachyderm works. Both systems use remote file storage like s3 or GCS, 
so you use their command instead of having to use the aws or GCP CLI to retrieve your files.

I also see that there is a function to load/stream data from external DVC projects, which is exciting, and I wish I had 
time to test it out now. I ran into problems with Pachyderm's streaming functionality when we tried to use it at scale, 
so I'd be curious to know if DVC has solved or avoided the kinds of problems we were having. 

The way DVC sets up sharing for multiple users on a single development server is different from how Pachyderm does it, 
because DVC relies on git and caching, and you have to manually set permissions on those caches. 
This seems like a pain to set up the first time. 

Pachyderm's enterprise offering has role-based access controls, but we never bothered to set those up, either. 
(We always said we'd do it later...) Instead, we just gave everyone on the team access, and as long as we didn't 
touch each other's pipelines, it was fine. 

I think if we were going to have multiple people working directly on the same data and/or same models, 
we would want more granular controls (and the equivalent of `git blame`) for this. 

Another major difference between DVC and Pachyderm is that DVC can be run as a python library. 
I was curious to try this out, so I opened a new notebook and typed `import dvc.api`. 
This looks like it should be really easy, in the sense that you don't have to build and push up a container to a container
registry in order to pull an updated version of your model. So I think that's potentially really useful in situations
where you won't be building microservices. 

One thing I like about the containerized approach is that it's extremely reproducible, and well, contained. DVC seems to 
be able to make the reproducible part pretty straightforward with helping you track, for example, what files are in a folder, 
and taking advantage of git tagging. 








