---
title: "Against Demo Driven Development"
date: 2025-08-08T11:17:15-07:00
draft: false
---
Some folks love doing demo days, but I find it sometimes gets in the way of actual work, creates more work in the long run, 
and/or can be downright demoralizing (especially to backend teams). Here's why. 

**What is demo-driven development?** 

• Building something specifically to be able to show it off

• Rushing to get stuff in before an arbitrary deadline

• A way to get people motivated by an audience (positive) or shame (negative)

**Why do some people like doing demos?**

It can be fun to do a successful demo and get attention for your work. 
It can be very satisfying to get to a point where the work becomes visible and usable. 

**Why am I against developing to the demo?**

• It’s like teaching to a test, rather than teaching the concepts. 
Looks great, smells bad. And the long-term consequences are similar: lower quality outputs. 

• **Not everything is demo-able.** Especially for backend teams, 
it can make our work seem easier or less essential than it is. 
Walking through how the code works, or showing off the outputs, isn’t as accessible 
to a wide audience as frontend UI/UX can be. 

• Demo-driven development **tends to encourage hacky solutions**/skipping engineering best practices, 
particularly doing things like putting off writing tests, which creates tech debt. 
It’s far too tempting to create temporary stopgaps just for the demo, 
which may or may not ever get upgraded to a ‘real’, maintainable solution. I've worked at multiple places where someone's hackathon project is in production - and when 
that person is long gone, now it's your problem. 

• Demos can be stressful because they're often treated like an (artificial) emergency, 
i.e. *“Drop what you’re doing and make a demo!”* And now you've been interrupted and derailed from what 
you were focused on, it's going to take even longer to get back to where you were doing
before the demo day distraction disrupted your flow. 

**Having ranted about that, demos are necessary for feedback.** 

It's great to show off your work internally to coworkers, as a team, 
when it makes sense to get feedback. Not on an arbitrary schedule. 

Customer feedback on a more finished demo/alpha/beta release is usually the next step. 

**Why is customer feedback important?**

Without it, you’re just guessing what your customers want. 
It’s too easy to assume your new feature is the right feature, that it works correctly, and that it’s obvious how to use it. This is rarely the case. 

**Why is feedback dangerous/often misused?**

• It can be very tempting to overfit on feedback from a small number of customers, 
assuming they’re representative of everyone. They rarely are. 

• It can be tempting to come up with customizations to suit every little thing 
you hear in feedback. Don’t do this. Just because someone mentions it, 
doesn’t mean it’s a good idea, or what anyone else needs or wants. 

• It’s common to start adding new requirements based on customer feedback, 
and it’s too easy underestimate how much extra work incorporating feedback might entail. 
We often don’t know until we start trying to make the changes, 
what else might break, or how long it will actually take. 

• It’s rarely a good idea to change requirements late in the initial rollout of a new feature. 
Especially if you’ve got any semblance of regular releases, 
it’s often better to just put it out there as-is, collect as much feedback 
and telemetry as you can, and then decide how to prioritize improvements for the next version. 



