---
title: "Data Engineering Is Software Engineering"
date: 2020-10-15T09:47:10-07:00
draft: true
---

Recently, a coworker asked me what the difference is between data science and data engineering. 
She seemed to think that data engineering was “just analytics”, which is a definition I've often 
heard applied to data science, as well. 

After I got over my initial horror that she had been wondering this for months and hadn’t asked sooner, I started to explain: 

 > Data engineering is getting data, cleaning data, reshaping data, validating data, and loading it into databases. 
 > Data science is all of that, plus analyzing the data and figuring out how to display it in a way that makes sense, 
 and sometimes also building models and doing machine learning. 

She seemed somewhat enlightened by this answer, but I didn’t love it, because there's a lot more to it than that. 
So I wanted to write something here about what data engineers do all day, 
because I’ve noticed a belief in many engineering orgs that data engineers are somehow not doing “real” engineering.
And there's a lot of confusion about what data scientists do with regard to data engineering. 

I've also noticed that there are some serious misconceptions about how standard web development CICD practices should work
for data engineering, and it's because there's not enough understanding of how data engineering needs are different. So this post
will touch on that, too. 

## First, what is an engineer?

I like [this definition](https://www.careerexplorer.com/careers/engineer/): 

> An engineer uses science, technology and math to solve problems.

By that definition, analysts and data scientists are engineers, too. 

But plenty of orgs don't consider analysts or data scientists to be Real Engineers. 

Where Real Engineers == Software Engineers. 

## What's a software engineer?

From [this definition](https://www.thoughtco.com/what-is-software-engineering-958652)

> Software engineers use well-defined scientific principles and procedures to deliver an efficient and reliable software product. 

Ok, so data engineers definitely do that. But you could argue that the things we're building are not "a product". 

## What's a software product?

Software products might be business products. They might be things we sell.

Software products can also just be a catchall term for work product. They can include free and open-source software. 


## What data engineering has in common with other software engineering

- We use logging, just like everyone else

- We use debugging tools, just like everyone else

- We write and run tests, just like everyone else

- We use CICD, just like everyone else*

- We use monitoring, probably more than some software engineers

- We use containers, maybe more than some software engineers

- We use databases, a lot more than most software engineers

## What makes data engineering its own thing

The customers for data engineering are usually all internal. That's the major difference. 

But this is also true for another team of 
engineers who are essential to a software business: your devops team. You could just look at it as another form 
of backend infrastructure: the front end doesn't work without the back end. 
Similarly, many parts of the business are serving garbage, or not running at all, without data. 

We are often, but not always, like a separate startup within a company. 
By that I mean, we usually do most, if not all, our own devops and product management. 
This is partly because data teams usually have a separate tech stack. It's mostly because
devops teams traditionally aren't big enough to support a data team's separate stack
on top of everything a devops team normally does. I'm not saying this is how it should be, 
but it's where most companies fail to plan for sufficient resourcing. 

Some of the tools we use are different. For example, we have to know about, and typically have to support,
a lot of different databases, and at scale, our databases are columnar. We have to architect our tables
and queries while accounting for the potential 
cost of storing and retrieving data at scale. 

We do a lot of ETL. We have special tools that we use to automate
ETL. Some of these tools are basically their own ecosystem. At this point, I'm not 
really exaggerating when I say that Airflow is approximately on par with 
Django for how complex and specific it is, in terms of how much knowledge is needed to use and maintain it, even in a
'hosted' environment like Google Composer. 

We have to know all about streaming and cloud stuff. We have to understand distributed systems, and we have to know 
enough about all the infrastructure running our distributed systems that we can at least know what to google for, 
and who to ask, when we need help. 

We also use containers. We have to know how to use docker, and often kubernetes as well. Most modern
software engineering stacks use docker now, and many use kubernetes. But we also need to know, again, specialized
systems that use kubernetes to serve models and pipelines. These systems are still under rapid development, so 
it's always a moving target. We rarely get to just sit back and practice doing things we've done before. 

## Why our CICD has to be a little different from the usual setup for web development

For data engineering, integration tests are way more important than unit tests. Unit tests are great, 
and we use them, but most of the time we're working with distributed systems and databases, where state matters a lot. 
So we can test some things locally, but generally we need to be testing things on remote systems. 

Mocks don't work for everything, or are too much work to maintain. 

Test databases are good for some things, but can fall out of sync 
quickly if they're not set up with automation to constantly pull in current data. 

Then we get into a situation where we have to hit the 'production' databases in order to run meaningful tests,
or we have to have a whole system to clone the production databases, or reproduce production tables, which can get
expensive (in terms of both money and time). All of these
options also have security and privacy complications to consider. 

For ETL, it's usually necessary to have an additional kubernetes cluster just for testing data pipelines. 

This is such a big topic that I've got a whole separate blog post on it (coming soon).




