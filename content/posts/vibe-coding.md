---
title: "Vibe Coding"
date: 2025-07-24T10:23:20-07:00
draft: false
---

### Some observations on vibe coding

I get a lot of questions about working with LLMs. Something I hear people discussing a lot is whether AI-generated code is 
better, or worse, or just more evil than human-generated code. I don't think it's an either/or question. To me, it's just another tool:
like most tools, there are ways to use them for good, or as weapons. 

I think vibe coding is great if you need to write a one-off script that isn't intended to be 
part of production code. For example, I asked Claude to help me come up with ways to generate 
fairly large test data sets for my last project, and it decided to write me a script to do it. 
This worked beautifully for what I needed, and saved me a ton of time. 
I did have to iterate on the prompt a bit to get it to do what I wanted, 
and that was a little nerve-wracking, so I saved off the different versions of the code 
(because sure enough, sometimes it got worse in ways I didn’t expect). 

I've noticed that vibe coding (or even just AI-assisted coding) can be terrible if the code needs to be extensible 
or integrated into a larger codebase, and the person giving the instructions 
doesn't know what to ask for/doesn't iterate in the right ways.

I've seen a lot of failure modes, but the main ones are *exactly that same ones we see from 
beginning-intermediate human coders*:

a) The code is spaghetti/not modular enough (this seems to be the default) 
unless you explicitly request for it to be modular,

b) There are usually no tests unless you ask for them, and even then they’re minimal/weird, 

c) Terrible problems with inconsistent naming on variables that should be the same across files,

d) Weird/outdated tool choices (like using networkx to make diagrams instead of mermaid.js),

e) The author tends to write too much code all at once, 

f) The author doesn’t ask clarifying questions or give you choices before diving into execution. 
 
All of this makes debugging much harder.

In discussions with other senior/principal/staff level engineers, 
we've all agreed that reviewing vibe-coded stuff is actually harder 
and takes more time than reviewing human-written code, because you have to look for 
different things, and it's almost like another skill set. 
Part of what makes it harder is that at first glance, vibe-coded stuff often looks 
pretty reasonable, but when you dig deeper there are usually weird gaps and edge cases 
that were missed. 

For example, multiple times now, I’ve seen models create inconsistent naming across modules. 
This is the sort of thing that humans tend miss in review (myself included!), unless you know to look for it. 

Of course it makes sense - the training data consists of a massive corpus of code from the 
internet, including millions of tutorials, GitHub gists, and Stack Overflow answers. 
Most of these examples are not at all like the real-world enterprise code behind complex, 
production-grade systems. 

Also, the model works off of immediate context and the current prompt. 
So when you ask it to work on a second file, it doesn't refer back to the 
variable names from the first file. Without being explicitly reminded, 
it can easily generate inconsistencies.

Overall I'd say a good practice is to treat vibe coding output the same way you'd 
treat a junior engineer on your team: supervise carefully, give lots of feedback, 
and take the time to make sure you're not creating more work for your team in the long run.

Special shout-out to Bushra Anjum for contributing to this post!
