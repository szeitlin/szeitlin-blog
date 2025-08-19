---
title: "Remote Work Best Practices"
date: 2025-08-18T14:37:45-07:00
draft: false
---
Recently, I’ve been surprised to note how many companies aren’t just returning 
to offices (ugh, open offices are the worst!), 
but are still actively unwilling to do remote work well. 

Here are some hints for things that I’ve learned can be helpful, 
after working remotely for a few years at a variety of companies - 
some that were remote-first or remote-only, 
and some that didn’t have mature practices around it:

1. **Threaded chats are your friends.** 

Slack and similar group discussion apps are one of the most essential tools 
for working asynchronously. Many of us have dozens, if not hundreds of 
Slack channels and workspaces. 

Most work is asynchronous, in practice, 
even if you’re in the same time zone. People need step away for any number 
of reasons - none of us should be chained to our desks and keyboards and 
screens all day every day. It’s best to assume someone might get interrupted 
while writing or reading discussions. 

Make it easy to go back and get caught up.
For future you, and for everyone else. 

2. **Detailed PR descriptions are your friends.** 

Always put the full steps to reproduce. Pretend like it’s a customer support 
ticket: including the input, the output, and what you expect to happen next. 
I like to format mine this way for simplicity and efficiency:

- **What’s in this PR.** People can’t read your mind. And sometimes your code is unintelligible. That’s part of why we do code reviews and write comments and docstrings (!). 
- **Rationale for why it was done this way.** This is especially important in 
research-y areas like data science/AI, because it’s often very helpful to also 
list other things you tried that didn’t work. This can help head off 
well-intentioned “why didn’t you just ___” type questions, 
but also helps make our work more visible to people who think it must 
be easy just because we made it look pretty. 
- **What I didn’t do/what’s next.** This may be because you ran out of time, 
or stuff wasn’t working as expected, or you came up with ideas for other 
cool things to add that are currently out of scope. 

3. **Be specific.** This is a general piece of advice. 
Pick names for methods, projects, classes, etc. that are self-explanatory, 
and preferably, unique. 

If you’re referring to anything that can be linked, link it. 
In the doc, in the PR description, in the ticket, in your slides. 

4. **Documentation is a first-class citizen.** 

Don’t wait until the code is fully written before you start writing up 
the design docs or the README on how to use it. 

Do it as you go along, and get other people to test that the 
instructions work as described. 

Bonus: if you wrote good PR descriptions, 
some of that can become part of the README. 

6. **Meetings should be for questions that can’t be answered from reading alone,** 
like decisions that need to be discussed, or explanations 
that require hands-on demonstrations. 

Request that people come prepared for meetings, and make that easy for them. 
If at all possible, whenever someone new joins the project, 
give them all the documentation and code access ahead of time, 
so they can read up before the first meeting.

Meetings are not for saying out loud, 
or repeatedly, the things that are already written down. 

7. **Time management tips:**
- Unless it’s really short, don’t make me watch to a pre-recorded video 
in a live meeting, I can watch that on my own time.
- Regular check-ins can save everyone a lot of duplicated effort and confusion. 
- Do daily standups on Slack. It’s not that hard. 
It doesn’t even have to be at the same time for every person, or at the same
time every day. 
- Don’t rely on meeting in person as the only way to build trust - sometimes it’s not an option.
- For the love of all things, respect time zone differences. Don’t expect people to be online around the clock.  
- Keep calendars up to date. Save everyone the trouble of back-and-forth on scheduling meetings. 
- Let people know when you won’t be around during normal overlap hours. Especially if
you're out for an hour for coffee or lunch - don't assume everyone's on the same
schedule as you!
If someone needs to ask you a question, and you’re missing in action, 
we don’t know if you went out to walk the dog, or got hit by a bus. 
If we know when you’ll be back, that helps everyone on the team decide 
if we need to work around your absence (you’re out sick and need to rest), 
or wait until you get back (in half an hour). 



