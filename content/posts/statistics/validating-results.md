---
title: "Validating Results"
draft: false
date: 2016-04-15
tags: ["experimental design"]
author: Samantha G. Zeitlin
---


I don't believe truth is a finite value. Truth is what we know right now. Every ten years or so, a major discovery gets overturned. Scientists are just people, and we're wrong a lot. 

So one of the scariest things about doing research, or predictions, is trying to convince yourself, and other people, that what you think you've discovered is 'real'. 

Or at least real enough, right now, to be believable. Whenever I do a project, I hope my findings will stand the test of time, at least long enough to be useful. 

One piece of advice that has always stuck with me is that there's no such thing as the perfect experiment (or model). No matter how well you do it, no matter how many controls you do, no matter how many replicates, every approach has limitations. It might be biased in ways you know about, and in ways that are not obvious because of variables you don't know about yet. 

How do we get around that, and generate solid insights without wasting a lot of time?

 1. Start from what is known. Don't reinvent the wheel. Trust, but verify. 
 2. Design your experiments wisely. 
 3. Use orthogonal approaches to cover your bases, and test your assumptions.
 4. Get input from other people. 
 

----------

## Start from what is known. ##

### Read Everything ###
When I was in college, the Chair of my Department was big on reading. He gave us 2 thick textbooks the summer before our senior seminar with him, and told us to read them cover to cover. Then when we wrote our final papers, he told us to read every paper we could find on our subject of choice. 

It sounds ridiculous, but it's great advice. If you don't know what's been done before, how do you know you're actually doing something new? If it's been attempted before, how do you know you won't make all the same mistakes? How do you know you're not missing out on all kinds of tips and tricks that might save you a lot of time and confusion? 

###Trust but verify###
Perhaps most importantly, if there's some way to verify your assumptions, like say if someone has done part or all of your project before, try to get your hands on their results. You're going to want to know how your results compare with theirs. Can you understand why your results might be different from what they reported? Have you improved on previous methods? Are you able to recapitulate their results using their methods? Using yours? Maybe their results are completely unreproducible. In that case, you shouldn't be trying to make your approach look like theirs. Or maybe your methods aren't very robust, in which case you have more work to do. 

## Design your experiments wisely ##

###Pick two###

Choose at least two approaches. It's never a good idea to base a major conclusion on a single measurement, or even a single type of measurement made in triplicate. 

Ideally, it's best to have a handful of orthogonal approaches. Then if the conclusions from each of these are consistent, you can feel pretty confident about your overall conclusion.  
 
### Have a testable hypothesis###

Do you know what you expect? Try examining your assumptions, and turn those into hypotheses. Are you trying to confirm a known result? Then you are testing whether you can reproduce that result. Set boundaries on how exact your answer should be. Does it have to be perfect? Or within 5%?  It really can be that simple. 

### Know the pros and cons of the approaches you choose###

Maybe you're debating about the best way to get data into your system. Your options are things like: 

a) scan PDF files and have a 3rd party library parse them into text

b) have someone type in the values by hand

c) pay for access to a 3rd party database 

The advantage of using the PDF files is that it's probably the cheapest solution. The disadvantage is that the parsing probably won't be perfect, and will require some additional validation, probably by a person, possibly by a person writing code to check the results. 

Having someone type in the values by hand may be more accurate, but it depends on the person. You'll probably still need a second person, or some other method, to check for typos. 

Paying for access to a 3rd party database might be the most expensive, but it also might be the most scalable long-term. 

It also depends on whether the data is going to be used as samples (for experimentation, where there might not be a 'right answer'), vs. as reference data (where you need the data to be as stable and accurate as possible). 

### Design an experiment that will let you see things you didn't know to look for###

In the example above, options (b) and (c) might provide additional insights that (a) won't give you. Computers only know to look for what you tell them, but people tend to notice everything. Databases often contain additional data that you didn't think you would need, but which might be interesting to you and relevant to your project. Choosing your data sources and process of collection can provide additional insights that you might otherwise miss out on. 

### Sample selection###

####Choose samples that represent:####

 **Positive controls:** known responders. Examples that reproducibly support your original hypothesis.

 **Negative controls:** known non-responders. Examples that reproducibly do not fit in your target category. They should be examples of things that cannot respond for different reasons. These are perhaps the most important to get right, especially in multivariate systems. If you're not sure what to use, they can be "leave-one-out", if the thing you're leaving out is critical to the event you're observing. 

For example, if you were doing a PCR to detect DNA in a sample of water, your negative controls include: 

 1. a sample of a different piece of DNA in water
 2. sample of clean water
 3. a sample that lacks the polymerase enzyme for the detection reaction
 4. a sample that lacks the oligonucleotide primers specific for your target DNA

 ** Edge cases:** examples of things that you know are hard to identify

To use the PCR example again, this might include a sample that you know contains your target DNA, but with a rearrangement that destroys half of it. 

Edge cases are critical for determining the sensitivity and selectivity of your approach. It's also essential to set your metrics based on whether you want to include or filter out certain types of edge cases. 

 **Main samples:** examples of what you expect to occur most commonly, which contain your target category and which can be sorted or otherwise identified (if only you can get the right methods and models in place!). Usually this is a mixed population, and you have some hypotheses about what variables might play a role in segmentation, even if your hypothesis is just "there is more than one sub-population in this group." (Hint: if you look carefully, there is usually more than one sub-population in a group)


###Sample size###

Choose samples that are big enough to be representative. For edge cases, sometimes one is enough. 
For positive and negative controls, you usually need a few, to check for variability within the populations, and also to compare against your main sample. But it all depends on the distribution of your system. If it's not a normal distribution, or your controls are Gaussian but your main samples are not, you're going to need a bigger sample to train your model, if you want it to perform well in real tests. 

It's also worth thinking about how your test population and controls, which are usually static, will represent the real thing, which might be streaming or otherwise changing over time. Are there known variables, like season, that might require you to periodically update your test samples? Your model can't account for what it hasn't seen. 

###Metrics to evaluate whether it worked or not###

Before you begin any experiment, think about how you're going to evaluate what you observe. If you have a hypothesis, your metric for success might be whether your data are consistent with your hypothesis. If you don't, maybe you have a threshold for what you'd consider a believable observation. How are you going to measure that? Is it going to affect the sample sizes you choose for your test populations (probably)? 

## Get input ##

Ask other people to discuss the models you're considering. Look at what other people have done in similar situations. Review your work with interested parties, while it's still in progress, so you can make modifications if any of your assumptions are wrong, if new insights become available, or if any of the priorities have changed. 

And then when you think you're done, review it again. And again. Get other people to help you look for possible mistakes. Everybody makes mistakes. It doesn't mean you're not working hard or not good at your job. Sometimes it just means you're too close to the problem, or you've been looking at it too long. Make sure to build time into your process so you can take a break, even if it's just to sleep on it for one night, and then look everything over again with fresh eyes. 

##You might still be wrong##

Always remember that you might be wrong. Always re-examine all your assumptions, and all the shortcomings of the approaches you've used. Sometimes this will open up new avenues for investigation, or help you shore up your findings. Sometimes someone else will come to you with evidence that you've made a mistake. There will be bugs in your code. That's ok. Just take a deep breath and see what's changed with this new information. 

Ultimately, all you can do is your best, and then you have to let it go. And you have to be ok with that. If you're not ok with knowing that you're human and imperfect, you'll be paralyzed with fear and unable to do anything that hasn't already been done before. That's ok, it just means doing this kind of work is probably not the right path for you. 

