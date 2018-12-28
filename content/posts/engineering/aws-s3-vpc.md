---
title: "More AWS things I learned the hard way: S3 best practices and VPCs"
date: 2018-12-02T16:29:47-08:00
draft: false
---

To make a long, mostly whiny story short, as part of my current role, 
I've been doing a lot of fighting with AWS to help support my team. 

Some of the things I've learned along the way are probably not obvious if you, like me, are relying
mostly on AWS docs and other people's advice, so I thought I'd collect some of them here.

**Best practices for storing big data on S3**

1. Think about your bucket structure

One of the things I ran into in my previous role was how hard it can be
to find a specific file in s3 if your file naming isn't set up to make this easy. 

Although S3 is not a real filesystem, you can almost treat it like one, but it can take a little
bit of finagling to write your code to help with this issue. 

So I recommend against, for example, putting dates in your filenames, like so:

Don't do this: *s3://mybucket/2018-12-02_server-1_file-1.csv*

Why not?

Here's the scenario: let's say you're looking for a specific file from server 13 on Nov 12th. 
But you can't grep for it because the file naming conventions changed at some point 
and nobody's sure what the structure was at this particular point in time. 

In order to make sure it exists, find out how big it is, and copy it to your machine, 
you now have to list your *entire* bucket. 

This is going to take a while. Like, probably minutes if your
data has been accumulating for a few years, especially if you have a lot of files. 

In fact, the list
might be so long that you won't be able to scroll through it all, you might have to write it out 
to a file and then search through that. 

I say this from experience, having worked with legacy log files that were stored this way. 


----
2. Coalesce

I recommend against using whatever the default output is, if you're writing out from a cluster,
for example, with something like spark. 

Most cluster systems will by default write out 1 file per partition or node,
which means you end up with a gazillion tiny files of different sizes and it rarely makes sense for
any downstream usage. 

Instead, I recommend grouping, coalescing, and compressing your files. 

3. Add slashes into your filenames. 

This (artifically) groups your files by year, month, and day. 

Then you can coalesce them down into, say, 1 file per day or per hour
(depending on how much data you have). 

**I recommend a structure more like this:** *s3://mybucket/2018/12/02/platform_name/file-1.gz*

Now, when you list your bucket, you can easily jump to the date and platform you want, and 
download a minimum number of files that meet your criteria. 

----
4. Think about your bucket policies and locations

Although new S3 buckets are now global, up until very recently they were restricted to certain regions for a variety
of reasons - availability, price, and latency are the main ones. 

So if you're working with legacy buckets, remember that some AWS services will still restrict access if you don't
pass the correct region to go with the bucket (ask me how I know this after spending a couple of days
tracking down an AccessDenied error from EC2...).

Until recently, setting up strict bucket policies was sort of optional, but thanks to another recent change
in security measures, now you'll have to set explicit policies or you're going to find yourself 
locked out of your own buckets. 

And don't forget that if you use any kind of encryption, if you're trying to access those buckets from
another account, you have to use custom KMS keys, 
and create an IAM role that has access to your encryption keys. 

----

**Some things I learned about VPCs**

As part of the Pachyderm setup (see separate post about that), 
I had to set up a connection to our Redshift instance, which 
lives on a separate account from our kubernetes cluster.
 
I tried following the instructions in the AWS docs, because it seemed pretty straightforward, but
as with my experience trying to set up cross-account access for EMR (see separate post about that), 
it just didn't work. 

Again, I couldn't 
figure out why because I wasn't getting any useful feedback like error messages or logs that could
point me toward what I was missing. 

After a lot of digging around in docs and asking for help from a variety of people online, 
I finally found someone who was willing to help me troubleshoot (thanks, Drew Davies!). 

What I ended up having to do was set up a new, custom VPC for Redshift. 

***Hint 1: AWS doesn't really want you to use the default VPC for anything.*** 

It seems like the default VPC is there mostly as a way to make it easy to get started prototyping, 
but for production it's of limited utility because there are a lot of features that 
just don't work with the default VPC. (In this regard, it's similar
to how they won't let you use default encryption on s3 with cross-account access.) 

So to solve my problem, I had to create a new VPC for Redshift, 
update the IAM roles, and redeploy Redshift inside the new VPC. All of that worked as described
in the AWS docs. 

Then I had to create the peering connection, 
create new security groups, 
and add the CIDR blocks to the routing tables. 

The AWS docs were ok for getting me this far. I had to do a bit of reading about CIDR blocks. 

Then I logged into the kubernetes cluster and tried to access the database, but it didn't work. 

***Hint 2: You have to turn on DNS resolution for the peering connection.*** 

Finally, with Drew's help, we figured out that I needed to 
go into a hidden menu and click a box for DNS resolution on the peering connection. 
I had to do this on *both accounts*. 

Then I had to wait a while before it propagated. 

This is another thing that's frustrating about AWS - they 
don't do a great job of telling you what you can expect might happen instantaneously vs. what might take
a few minutes. 

This was all poorly documented and I genuinely don't understand why it's not the default 
when you're setting up a peering connection between two VPCs. 

After all that, I heard another friend struggling with the same problem, which is why I wanted to write
this up. Sorry it took so long for me to publish it!
