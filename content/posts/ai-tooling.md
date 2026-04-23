---
title: "Ai Tooling"
date: 2026-04-23T15:07:40-07:00
draft: false
---
# Transitioning to using AI tools

Despite working in the applied AI field for the last couple of years, I’ll admit that for a while I was resisting using it in my daily life, or my coding. This post is about transitioning to comfortably using AI, while leaving room for growth. 

At work, I found early on that LLMs could be extremely helpful for analyzing data in minutes, which would otherwise take a human hours or even days. But I have concerns about privacy, I have a lot of friends who are vehemently against AI (for various reasons I won’t go into here), and I didn’t have great ideas about use cases in my personal life where I thought AI could really help (and wouldn’t steer me in the wrong direction). For some things, it still felt better to ask humans for advice. 

## Using AI in my non-coding daily life

One of my a-ha moments about “when is AI really useful?” came when I realized asking Claude meant not having to ask an ex boyfriend about rigging up Ethernet for a real-time music class. Thank you, Claude! So empowering! 

On the other end of the spectrum, one of my more disappointing applications was trying to use Claude for shopping for a new wallet. Failure modes: similarity search on images just didn’t work. I had to keep iterating on descriptions of what I wanted vs. what I didn’t. It kept ignoring my requests about price ranges. So it was about as helpful as asking strangers on the internet for advice on brands and products, or maybe even less so. The women in some of my slack groups will happily recommend their favorite products, with detailed reasoning, and even go hunt down products closer to my specifications.

More recently, and somewhere in the middle on a scale of “works great!” to “nevermind”, I’m using Claude and a tool called OpenEvidence to assist with research for a friend’s cancer treatment. It’s been especially helpful for summarizing what’s happening in the world of oncology since I switched to working full-time in software, and for comparing concepts and drugs. But one area where all AI seems to fail is the deep analysis of biomedical research literature. When I read the primary papers on PubMed myself, I notice a lot of nuance that otherwise gets lost. So much of reading the literature is about knowing how to spot what’s implied vs. what’s actually shown, and identifying the open questions that the authors don’t name. AI isn’t quite there yet, though to some extent it’s at least able to validate what’s known vs. unknown when I ask if something has been shown in other studies (and it can give citations to support that). 

Today, I’m asking Claude to help me fix Hugo so all my blog posts show up the way they’re supposed to on the site. :-) 

## Switching to AI-assisted coding

In the last year, I’ve consulted with a few startup clients that were moving so fast, 
I reluctantly found that I couldn’t possibly 

a) make sense of their codebase or 

b) keep up with them and get my work done, without switching to AI tooling. 

Some tools I’ve found most useful day-to-day:
- Warp terminal (hooray for smart autocomplete with git!)
- Cursor (mixed results, but mostly decent)
- Claude code (also mixed results, but mostly good)
- Coderabbit (also mixed results, can be noisy if not configured properly)
- Synk and Dependabot (not necessarily using LLMs, but security automation FTW) 

## Plan mode is your friend

I’m still not using agents a lot, because I find that I’d rather supervise a little more, 
and clean up afterwards a little less. So I still mostly keep Cursor and Claude in plan mode, 
and only turn them loose after I’ve finalized reviewing and steering what’s going to happen. 
And I still mostly ignore Warp’s suggestions for bugfixes (it doesn’t seem to be configurable 
in the ways that I would want). 

## Code reviews with AI

I find working with Coderabbit somewhat less stressful than the old style of code reviews 
from humans - Coderabbit nitpicks and makes suggestions that might be irrelevant, 
but I have no qualms about saying ‘ignore’ or ‘I’ll fix that in a separate PR’ and moving on. 
Coderabbit might be insistent, but it’s not going to be angry, or call me names. 
In the past, I had been in more than one unpleasant argument over code reviews. 
That mostly improved with experience (I had to learn a lot of things the hard way). 
With the help of AI to check for obvious mistakes, and coding agents to help fix them,
I have more bandwidth to think about the questions I'm trying to answer when I'm creating or
evaluating AI features, and human reviewers can focus on the bigger picture. 

## Psychological challenges

I have friends who despise AI and absolutely refuse to adopt it, 
and who complain bitterly about how the job they love is already gone. 
I’ll be honest, sometimes I miss the deep flow of solving a problem with writing code from scratch. 
I can always still do that if I really want to (on my own time). 
But mostly I’m relieved of the burden of having to remember or look up specific syntax, 
and I can just focus on solving the problem at hand. 

Don’t get me wrong, 
I don’t feel like all those years learning were a total waste - 
I still need to know a lot about how code works. I still have to apply best practices, 
and think carefully about architecture. I still see a lot of places generating reams of 
spaghetti code with AI tooling, and then not knowing how to dig themselves out of it. 

With that in mind, I think the future is more about figuring out how to make 
"vibe coding” quality better, and improving processes for ensuring that what gets into production 
is maintainable and extensible. These were the same problems I saw all the time before AI, too.

The main thing I've ended up doing with my teams is adapting the same practices 
I was already using with junior/intermediate coders: 

- getting everyone to understand and agree on why code quality matters, 
- thinking carefully about architecture before implementation, 
- teaching the difference between good tests and not-useful tests (for example: I still hate mocks and try to avoid them whenever possible), 
- adding evals for things that rely on LLMs, 
- using tools like Coderabbit to help with code reviews, 
- making PRs that are small enough for a human to reasonably review, 
- getting everyone to agree on what requires human review, and what to look for when you're reviewing code you didn't write.

## A different kind of flow

For my friends and colleagues who are really struggling with using AI for software development, 
I think it’s a mix of 

a) distrusting the tools, 

b) change is hard, and 

c) shifting from typical IC “I can be heads-down in the flow” mode much of the time, 
to leaning more on skills and a persona of “I have to delegate, review, redirect, and collaborate”. 
For me, it's more like when I did cancer research - a lot of the tooling I was using could be treated
more like a black box. I don't know how to build a confocal microscope from scratch, and I don't need to. I just need
to know enough about how it works to be able to use it, and troubleshoot what's going on if something isn't working as expected.

In that sense, I’m finding my research, teaching, management, and teamwork skills are more useful when working with AI. 

As a researcher, I was always surprised at the spectrum of reactions people would exhibit when new technology became available. 
There were always some luddites, who refused to even try anything new, and some early adopters, 
who leapt at the chance to try the hottest new thing. 

I’ve always tried to weigh the trade-offs and look for the use cases where I can see a clear benefit. 
Sometimes it’s very obvious that the new thing solves a problem I’ve always had. 
Sometimes it feels like a privacy or security risk, or an unnecessary expense. 

As a teacher, manager, and team member, I’ve had to level up my communication skills and my patience, 
and all that effort is definitely paying off when I’m using AI. When working on the cancer research I mentioned above, 
I briefly considered writing a new claude.md file, because for lack of a better word, it kept ‘mansplaining’ at me. 
I had to tell it what I knew already, and what I actually needed explained, because it was so annoying. 
But I was able to steer it to give me what I needed, partly by leaning on my prompt engineering skills, 
for example, making the request more specific, and giving it more context about what I already know. 
And partly just through trying to be patient, the same way I would with a colleague who might be info
dumping on me rather than answering what I actually asked. :-|

## The future

I won't try to predict what will happen in the far future with AI. 
I’ve read and watched enough sci-fi to know it could be bright 
(Star Trek! Universal basic income and replicators for everyone!) 
or dark (Terminator! SkyNet!). 

I don’t want to even try to predict what’s going to happen in the next six months. 
But I’m happy to report that working with AI tools for coding can be fun, and productive, 
and worthwhile. I was able to do the same work alone in two months using AI tools that 
last year took three times longer with a whole team. 
That might be partly because the AI mostly does what I tell it to do - 
and it’s less likely to talk over me in meetings. ;-)  

