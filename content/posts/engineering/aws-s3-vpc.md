---
title: "More AWS things I learned the hard way: S3 best practices and VPCs"
date: 2018-12-02T16:29:47-08:00
draft: true
---
After starting my current role at Denali Publishing/Triller, I had a decision to make. 

Set up Airflow again? Or try something new?

I had been hearing about this new, local product called Pachyderm. More on that in a separate post.

To make a long, mostly whiny story short, as part of my current role, I've been doing a lot more AWS things
to help support my team. 

Some of the things I've learned along the way are probably not obvious if you, like me, are relying
mostly on AWS docs and other people's advice, so I thought I'd collect some of them here (separate from the Pachyderm post).

**Best practices for storing big data on S3**

1. Think about your bucket structure, and coalesce 

For example. One of the things I ran into in my previous role was how hard it can be
to find a specific file in s3 if your file naming isn't set up the right way. 

Although S3 is not a real filesystem, you can almost treat it like one, but it can take a little
bit of finagling if your code isn't set up to help with this issue. 

So I recommend against, for example, putting dates in your filenames, like so:

Don't do this: *s3://mybucket/2018-12-02_file-1.csv*

I also recommend against using whatever the default output is if you're writing out from a cluster,
for example, with spark. Most cluster systems will by default write out 1 file per partition or node,
which means you end up with a gazillion tiny files of different sizes and it rarely makese for storage
or for later usage. 

Instead, I recommend grouping, coalescing, and compressing your files in a way that makes sense so you'll be able to find
them easily later. So I'd say to add slashes to artifically group your files by year, month, and day, and coalesce
them down into, say, 1 file per day or per hour (depending on how much data you have). 

Do this instead: *s3://mybucket/2018/12/02/file-1.gz*

2. Think about your bucket policies and locations

Although new S3 buckets are now global, up until very recently they were restricted to certain regions for a variety
of reasons - availability, price, and latency are the main ones. 

So if you're working with legacy buckets, remember that some AWS services will still restrict access if you don't
pass the correct region to go with the bucket (ask me how I know this after spending a couple of days
tracking down an AccessDenied error from EC2?).

Until recently, setting up strict bucket policies was sort of optional, but thanks to another recent change
in security measures, now you'll basically have to set explicit policies or you're going to find yourself 
locked out of your own buckets. 

And don't forget that if you use any kind of encryption, if you're trying to access those buckets from
another account, you have to use custom KMS keys, and create an IAM role that has access to your encryption keys. 

**Some things I learned about VPCs**

As part of the Pachyderm setup, I also had to l