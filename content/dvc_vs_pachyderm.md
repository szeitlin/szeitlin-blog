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





