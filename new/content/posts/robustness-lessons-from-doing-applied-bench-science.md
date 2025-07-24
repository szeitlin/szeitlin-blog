---
title: "Robustness: lessons from applied bench science"
draft: false
author: Samantha G. Zeitlin
---


Inspired by a couple of [great posts by Michael Gibson][1], I want to talk about what robustness means to me, as someone coming from a science background. 

I started working in a "wetlab" doing benchwork cancer research when I was in high school (I was 16). I learned early on that mistakes are:

- normal
- avoidable
- necessary. 

That may sound paradoxical, so I'll explain. Some failures will always happen: the phone rings and you drop something. That can happen to anybody. But you can take safeguards to prevent disaster, like making sure all your tubes are labeled and capped tightly, so if you drop them, nothing gets lost. And some failures are informative, like when (notice I don't say 'if') an experiment doesn't work out the way you expected. Mistakes will be always educational if you designed your experiment correctly. 

I'll give a positive example. When I was a postdoc, I had a student who accidentally added ten times the amount of antibody we normally used. It was an expensive mistake, but an informative one, because we ended up seeing something we might not have seen otherwise. And then we went back and did further experiments with that observation in mind. 

## Controls ##

Good experimental design is all about [controls][2]. This is essentially what you're doing when you write tests for your code, but I don't see as much discussion of designing control experiments outside of biology. 

Synthetic chemists, for example, might use controls in some methods, but the possibilities are usually somewhat limited. 

In testing your code, typically you know what kinds of things might go wrong, and you can test for certain types of exceptions by using examples of the kinds of output that might be good or bad. 

In biology, the possibilities are always endless. I can't think of a better way to explain it than that biology is the original infinite variable system. 

**A really well-designed experiment is going to show you something new, even if your hypothesis is wrong.** 

It's not just [A/B testing][3], although most experiments should include at least one component that is essentially an A/B test: 1 negative control (in triplicate), 1 sample (in triplicate), and at least 1 positive control (also in triplicate). 

Often, you'll learn more from making sure you have the right positive controls (my experiment is measuring what I wanted to measure!) than from having a bunch of uninformative negative controls (of course there is no band on the gel if I don't load anything in that well). 

This kind of background has a lot of implications for testing code, which may not be obvious if you don't know what kinds of things a bench scientist might have done all day before she starting writing code full-time.  

First, it means that someone coming from biology is probably pretty good at thinking both about expected results and what kinds of failures might happen. 

We also tend to be pretty good at building models that will be both deep (specific to our system) and broad (generalizable to other applications).

Perhaps most importantly, we're very aware of, and good at describing, what assumptions we're making. 
 
## Assumptions ##

Lately I've been watching lecture videos about [Bayesian methods][4], trying to figure out how to explain to people why I worry about using approaches like these. 

Bayesian approaches are very popular with the machine learning crowd, and improvements in computational power make it possible to apply them in better ways than when they were originally invented. 

Still, [Bayes requires the assumption that the variables are truly independent][5], which in my opinion, never applies in biology, where everything is connected. Biology is like a sweater constructed out of a single, really convoluted, piece of yarn. Pull on any one place, and you can find it's connected to everything else. 

I think much of life is this way, and making the assumption at the outset that your variables are independent may be a huge and unnecessary risk. Best case scenario, you can treat all variables as independent and it won't affect the outcome. Worst case scenario, you're going to make the wrong conclusions about antagonizing variables, mistakenly attribute effects that are actually due to feedback loops, and/or miss out on making important connections. 

To give another example of how machine learning approaches are different from wetlab experiments, resampling a large dataset using methods like [bootstrapping][6] is not that different from what we always did with imaging large samples of cells on dishes, but what we were doing was more like [fixed split sampling][7] (without replacement). 

And we can argue about it if you want, but anyone who has thought deeply about so-called Frequentist methods knows that [p-values][8] are less important that the quality of the data and the test you used to compare samples. 

But if you're going to insist on p-values (as most scientific reviewers do), you're much better off using a 0.01 - 0.001 cutoff (and a result with a p-value of 0.05 should never be taken as standalone proof of anything). 

But keep in mind, no one experiment is ever perfect. Usually the best way to understand a system is to use a collection of experiments applying orthogonal methods. 

All of these issues relate to the robustness of the results, or what scientists typically refer to as [reproducibility][9]. Those of us with an academic science background have spent a lot of time thinking about [uncertainty][10], and not just academically. We really do want to design our experiments to be meaningful long-term. We really do want other people to be able to use our results. 

So with this in mind, I'm fascinated by how engineers, and especially software engineers, talk about robustness. I love the way Michael Gibson broke these levels down. 


## Real-life robustness ##

[This post about uptime][11] reminds me of what we had to do with our cell cultures, and what happened if a piece of large equipment broke down. 

With cell cultures, typically I made frozen stocks. To do that, you need to have a minimum number of cells, because they have to be at a certain density to freeze safely without forming too many ice crystals. 

The time component is essential. Growing up enough cells to freeze a minimum amount might take a day or two, or a week, or more. Similarly, thawing out cells to start a fresh culture typically requires at least overnight for the cells to sit down on the dish, or otherwise recover from the shock of coming out of deep freeze. 

So what does uptime mean? If your cells suddenly died, or if your incubator broke down, your experiment might be ruined. Best case scenario, if you had frozen stocks and another incubator to use, you'd be up and running on another attempt within a day or two. Worst case scenario, as happened to me in 2007 during [the huge fires in San Diego][12], a 90-day human stem cell experiment would be ruined, and you'd run out of funding and never be able to try it again. 

Another example of a large equipment breakdown that happens periodically in every wet lab is a freezer failure. Best case scenario, there's someone around when it happens and the contents can be transferred into another lab's freezers until you can get yours repaired or replaced. Worst case scenario, expensive and sometimes irreplaceable reagents will be ruined. 


----------


## The science of making code more robust ##

This [other post][13] Michael wrote about the frequency of bugs in code got me wondering about how my coding skills measure up now, and what I can do to improve my coding habits. I laughed at the point he made about when TDD is appropriate (I had to look this acronym up, it means 'test-driven development'). 

To some extent, I think I've reached the point where my code projects might benefit from more structured testing and code review. But many of the projects I'm working on are data science projects, where I'm mostly doing data exploration. This means I'm running single functions, looking at the output, and iterating a lot as I decide what to do next. They're not really 'programs' and I'm not sure anyone would ever run this code that way. It is interesting to think about how to make re-usable modules out of portions of these projects, though that's only useful if they're not full of bugs. 

Am I up to the 99% correct level? ![Maybe][14]


  [1]: http://codrspace.com/mchlgibs/
  [2]: http://en.wikipedia.org/wiki/Scientific_control
  [3]: http://en.wikipedia.org/wiki/A/B_testing
  [4]: http://en.wikipedia.org/wiki/Bayesian_probability
  [5]: http://blogs.cornell.edu/info2040/2012/10/30/bayes-theorem-in-machine-learning/
  [6]: http://en.wikipedia.org/wiki/Bootstrapping_(statistics)
  [7]: http://gerardnico.com/wiki/data_mining/resampling
  [8]: http://www.statsdirect.com/help/default.htm#basics/p_values.htm
  [9]: http://blog.scienceexchange.com/2013/10/reproducibility-initiative-receives-1-3m-grant-to-validate-50-landmark-cancer-studies/
  [10]: http://www.apolloschildren.com/blog-item.php?id=27
  [11]: http://codrspace.com/mchlgibs/five-9s/
  [12]: http://www.sdfirefacts.com/index.cfm?Section=15&pagenum=175&titles=0
  [13]: http://codrspace.com/mchlgibs/
  [14]: http://imgs.xkcd.com/comics/correlation.png
