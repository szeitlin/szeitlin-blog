---
title: "Dvc_vs_pachyderm"
date: 2021-01-27T13:13:57-08:00
draft: true
---

# Some intro here about why I'm looking at this:

# comparison

Main differences:

- Pachyderm expects you to use kubernetes. You can run it locally with minikube, but 
really the whole point is to containerize models. DVC has no such expectation. 

Main similarities:

Both DVC and Pachyderm can:
- track and save data and ML models (pachyderm can do this too)
- switch between versions easily
- easily pull in data from cloud storage, and push back out

#todo: Some intro here about what else dvc says it can do:
- compare model metrics among experiments (not sure what this means yet)


Some links to past posts about pachyderm:
#todo: put link(s) here

Started trying to go through one of the tutorials, but I don't have enough free space on my laptop!

So, let's see if I can do something with a small data set I had leftover from a recent job interview. 


Starting with a folder that has a data file in it. 

Create an environment: 

`$ conda create -n iterative python=3 pandas numpy scikit-learn jupyter notebook`

Conda install failed with my usual channels and I'm too lazy to look for others, so I did:

`$ pip install dvc`

Then I did 

`$ git init`

and then 

`$ dvc init`

I added my data files to my .gitignore, as usual, and then 

`$ dvc add win-rate-small.data.pickle`

So now files that I'd normally never put into git, are tracked with dvc instead. 
I like this. 

And then I put the tracking file into git for safekeeping:

`$ git add win-rate-small.data.pickle.dvc`

The main advantage of this seems to be if you want to store your large data files
remotely, and then pull them in when you want to work on them. 

I think this is cute, but I'm not sure how it would work in practice. 

In the interest of time, I'm going to skip over this for now and maybe come back later.

So anyway I went and built a model in a jupyter notebook, and the first version wasn't very good (unsurprisingly). 
Just to be safe, I dumped it out anyway: 

```python
from joblib import dump, load
dump(clf, 'logit_bad.joblib') 
```

Then we add that with `dvc add` and `git add` and `git tag`. Although I don't have aliases for my usual 
git workflow, since this adds another line of typing to every git command, I am thinking if I were going to do this a lot, 
I would want an alias or something. 

The next thing the tutorial does makes perfect sense: try to improve the model and save another version of it. 
Back to my notebook. 

Since I didn't spend much time on it, the second version of the model isn't much better, but I write out `logit_bad2.joblib` anyway. 

The next step is to demonstrate switching between workspaces, so you can check out the data and the model 
versions easily. This is where I think DVC really shines, and is easier than Pachyderm. 

Because we tagged the versions, it's really trivial to say `git checkout v1.0` and then `dvc checkout`. 

With Pachyderm, at scale anyway, this was not so easy. The times when I needed this the most were not during development, 
though, they were during debugging. And then the hard part was going through to find which chunk of data was
associated with a failed model run, and track back to get the uuid of that commit. 









