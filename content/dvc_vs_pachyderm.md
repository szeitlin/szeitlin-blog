---
title: "Dvc_vs_pachyderm"
date: 2021-01-27T13:13:57-08:00
draft: true
---

Some intro here about what dvc says it can do:

Some links to past posts about pachyderm:

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





