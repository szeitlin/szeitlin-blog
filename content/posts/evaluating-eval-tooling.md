---
title: "Evaluating Eval Tooling"
date: 2025-09-29T14:40:36-07:00
draft: true
---
This post is about things I wish all eval tools provided (but many don’t). 

Over the last couple of years, I’ve used several different eval tools, from home-grown and pre-release products, 
to open source and startup-built tools with wide adoption. Most of them had inconsistent features at best, and 
glaring omissions for what I thought were obvious features, at worst. 

Now, to be fair, what I’m asking for from an eval tool is kind of a lot. 
I want something that can 
a) send my prompts (of any size), 
b) to the model (on any of the main platforms - Anthropic, AWS, etc) 
c) using my API keys, 
d) help me track costs, 
e) handle all my datasets
f) include some data visualizations and statistical tooling to make it easy for me to tell if my experiments are working or not. 

So here are my suggestions for anyone with an eval tool they're trying to get me to adopt. 

**1) Make it easy for me to upload my reference data sets.** 

Some data sets have expected output, some don’t. 
Some will be json or jsonl, some won’t. 
Please don’t make me reformat my data a different way each time. Your tool should be able to handle common formats. 
How the data needs to be formatted should be well-documented and easy to find. 

**2) Have a playground.** 

Most tools have some version of this now - a place to manually write and modify prompts and test them against a reference dataset. 
The user experience varies a lot, though - some make it easy to pick an existing prompt you want to edit, some don’t. 
Some have the ability to use existing datasets you’ve hand-curated and labeled, and some don’t. 

**3) Make it easy for me to have multiple accounts with API keys, and cost tracking.** 

Especially as a consultant, it’s not unusual for us to have one set of keys for a prototype, 
then switch to another set when the project gets picked up for development, 
and yet another when the project goes into production. 
Budgets may change, and priorities, over time. Don’t make me keep going back to calculate costs, it should be built into every API call. 

**4) Make it easy for me to export my results.** 

If you don’t provide data visualizations for analyzing experiments, that’s ok. 
But if you’re not going to make charts for me, or I can’t modify the charts you’re making, at a minimum, 
it should be easy for me to export a table with all of my relevant dataset information and scoring. It should be a csv. Then I can make my own charts. 

**5) Have an easy interface for humans to review results and mark if they’re correct or not.** 

This could be a full-fledged reinforcement learning loop, but it doesn’t have to be. 
Ideally, I should be able to select and group samples where the model consistently gives back responses within tolerances, 
vs. samples where the model consistently fails, and iterate easily from there. 

It would be even better if I could then create new datasets based off the old ones, 
without having to manually reshape the data outside of your tool and then re-upload it. 

**6) Make it easy for me to add deterministic scoring methods.** 

This is surprisingly hard with a lot of eval tools. Some newer tools will auto-generate evals for you based on samples you’ve included, 
and common metrics. This is amazing, but it’s probably never going to be enough to give you full coverage on what you’re trying to do, 
especially if you’re trying to do something that hasn’t been done before. 

**7) Make it easy for me to use LLM judges for scoring, including the ability to revise judge prompts, 
and mark and edit when an LLM judge’s answers are wrong.** 

This is similar to regular evals, but usually separate, because to use LLM judges, you have to have additional prompts, 
and a place to put those, and iterate on them. Using an LLM judge can become its own project-within-a-project, for better or worse, 
and it’s a lot easier if your eval tool can help with this. 

**8) Make it easy for me to track and manage multiple projects, datasets, and experiments.** 

Everything should be selectable, searchable, exportable, groupable, and have unique IDs. In this case, "everything" includes but is not 
limited to: prompts, datasets, metadata tags, scoring, responses, failed responses, error messages. 

**9) Make it easy for me to debug.** 

Don't wrap my code in your SDK so that it swallows my error messages. Don't hide logging, don't only send it to your own backend servers. 
If something fails in my code, or in the API response, it should be easy for me to find and fix it from my local machine. 

**10) Don’t make assumptions about the size or shape of my datasets.** 

Some projects are going to have one-line inputs and outputs, others are going to need attachments and use the entire context window. 
Whether you bill users for management of larger datasets, or just make it easier for us to pull them from places like s3, is up to you. 

**11) Be secure.** 

I may be mostly testing with fake or anonymized data, at least to start with, but if/when my project moves into production, 
many companies can’t even onboard your tool if you don’t have SOC2. 

Ideally, I can put real datasets into your system without worrying that I’m risking company secrets, or creating more work for the compliance team, 
or, worst of all, having to switch to a different product, because the client won't let us use the one we've been using for all prior development. 

**12) Make it easy for me to compare experiments.** 

A lot of eval tools make simplistic assumptions, like that the size of the datasets will always be exactly the same, 
when you want to compare experiments. And yes, this would be ideal, but also, this is the real world, and 
sometimes you just don’t get a response from Bedrock, so a data point is null. 

If my dataset is big enough, this shouldn’t block me from analyzing the experiment. If you’re trying to include comparison tooling, 
don’t block me from analyzing my data if the experiment is slightly imperfect, 
just report the relevant metrics (e.g. the number of samples in each dataset, error bars on replicates, number of replicates run, etc). 

**13) If you're going to include built-in metrics, make sure they make sense.** 

Have tool tips with explanations. I shouldn't have to join your slack group just to ask if 'average accuracy' is using a mean or a median. 

Make it possible for me to toggle the display of these metrics on and off. 

**14) Have a UI that's nice enough for me to screenshot and show to execs.** 

Ideally, I can do a live demo and walk them through what we're learning, while showing off your dashboards. 
If all goes well, everybody gets a wow factor, and a win. 




