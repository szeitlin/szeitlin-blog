---
title: "Data Engineering Is Real Engineering"
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

That data engineers are not Real Engineers. 

I've also noticed that there are some serious misconceptions about how standard web development CICD practices should work
for data engineering, and it's because there's not enough understanding of how data engineering needs are different. 

## First, what is an engineer?

<to do: write this part>

##What data engineering has in common with other software engineering

- We use logging, just like everyone else

- We use debugging tools, just like everyone else

- We write and run tests, just like everyone else

- We use CICD, just like everyone else

- We use monitoring, probably more than you do

- We use containers, maybe more than you do

-  We use databases, a lot more than you do

##What makes data engineering its own thing

We are often, but not always, like a separate startup within a company. 
By that I mean, we usually do most, if not all, our own DevOps and product management. 
Our customers are usually all internal. We often have our own stack. 

Some of the tools we use are different. 

We have to know about a lot of different databases. 

Our databases are mostly usually columnar. 

We do a lot of ETL. 

We have to know all about streaming and cloud stuff. 
 We also do stuff in containers. 