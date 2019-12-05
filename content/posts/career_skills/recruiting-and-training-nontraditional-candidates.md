---
title: "Recruiting and Training Nontraditional Candidates"
date: 2019-11-19T10:29:00-08:00
draft: true
---


# Question: How come we don't have more diversity at our company? 

This is one of those posts, I'm writing it because I keep hearing people asking the same questions
over and over. I hear these questions at meetups and in Slack groups every week, and I hate seeing people 
trying to reinvent the wheel when it's really not necessary. 

 ## Answer: You haven't tried that hard. 
    
For the purposes of this blog post, let's go with the hypothesis that there are plenty of nontraditional candidates out there
like me. We didn't major in computer science, but we learned how to code and we actualy enjoy it. We have tons of 
transferrable skills. You should be hiring more people like us. 

### Things to try:
        
  - *Try actively encouraging nontraditional candidates to apply.* 
  Reach out to people in your network and personally invite them. 
  Go to meetups, get involved in the communities. Help out by mentoring, be more visible. 
        
  - *Try rewriting your job descriptions*
  Textio and tools like that are a nice idea, but it's not good enough. 
  Word replacements alone are not going to fix structural problems in the ad itself, or in your hiring process. 
  
  1. Think very hard about what you actually need. 
  2. Break out essential vs. nice-to-have skills. 
  3. Emphasize what process and support systems the company provides for candidates transitioning from other roles or fields. 
     - Do you have training and development stipends?
     - Do you send people to Grace Hopper every year? 
     - Do you have employee resource groups, or an inclusion squad? 
  4. Describe what candidates can expect in their first few months there. What does onboarding look like? How are employees evaluated?
            
  - *Try changing your interview process*
 Your one-size-fits-all coding test never worked that well, you just didn't know it because nobody measures false negatives in recruiting. 
 
  If you want to know how bad your recruiting process is, track down some of the people you rejected, and see where they ended up
  1 or 5 years later. You might be surprised to consider why they were able to succeed in spite of you. Maybe you want to think
  more about how to take advantage of that pool of candidates you previously discounted. 
  
  If you're doing things like setting a hard 20-minute limit on a particular problem, and rejecting candidates
  because they took 5 or 10 minutes longer to finish it, you're losing out on a lot of good candidates. 
  
  Rather than insisting on live coding tests as teleconferences with Coderpad, consider offering a take-home option instead. 
  
  If you're offering a pairing exercise, train your interviewers in how to pair productively. 

                  
# Training Junior or Nontraditional Candidates

Not all nontraditional candidates are really junior, but most of us have gaps. I had a lot of transferable skills
when I first started in software, but I didn't know what they all were. I had at least heard of some things I hadn't done yet,
but there were also plenty of things I didn't know that I didn't know. There still are. 

I’ve trained a LOT of junior people, starting from way back in my scientific career, and my process is basically this: 

a) Train the first one of each cohort well, so they can help train the ones who join later. This makes your job easier, 
and teaching others is a great way for them to cement what they just learned. 

b) For more complicated things in lab, I've always used the classic "they watch me do it once, I watch them do it once, 
then they do it on their own when I'm not around". Software is generally easier. And most people code better when you're
not looking over their shoulder. 

Show your existing code, and walk people through it so they understand
your thought process. Similarly, when it's time for their code reviews, do it in person. Let them explain their thought
process and what they were trying to do, before you jump all over them demanding a bunch of changes. 

c) Write everything down, so they can look stuff up and get more done if you're not around. 
Encourage them to improve the documentation as they use it. 
The more people who contribute, the better your instructions will be. 
 
 I have a terrible memory, so I prefer written instructions
 to verbal, and I take notes whenever anyone is telling me how to do something. 
 I encourage everyone who works with me to do the same. 
 
 This isn't specific to junior or nontraditional candidates, but for example someone who has never used git in production before,
 could benefit from a cheatsheet of commands they'll use the most. Why not help them with that? 
 
 Even for people who have more experience, if they're switching platforms (e.g from AWS to GCP or Azure), 
 or picking up new tools (like docker), just collecting the links your team uses the most for frequently-asked questions
 can also save a lot of time and help people get going faster. 
 
 ## The kinds of things that are useful to have written down:
 ### Onboarding:
 - How to set up a new computer with 
 
    a) all the recommended tooling (Homebrew, github, Xcode, etc.) so they don't have to reinvent that wheel
    
    b) access to all the services/databases/software they will need, so they don't have to wait for the permissions they'll need. 
    
 - Where to find information (Confluence, JIRA, google docs folders, etc)
 - Who to ask about what - for example, org chart, and who owns what repos

It doesn't take much, but it makes a huge difference to keep this stuff up to date. Do expect your new hire to update the docs
with any changes. Don't expect them to go hunting for all this information on their own. Note that you can't expect a new hire
to read your mind, regardless of how senior they are. 

### Other docs you should have

For example, for a data science team, you should have docs that include:

   - where the databases are
   - data dictionaries for any frequently-used tables and/or dashboards
   - instructions for any common tools and infrastructure (kubernetes,docker-compose, AWS, ETL tools, etc.)

Your docs should be organized, so a new person doesn't get overwhelmed. I recently heard a story about
a company that handed a new person a giant list of links and docs, 
and half the links led nowhere because the list hadn't been maintained, and this person just felt completely lost. 
We want to avoid that scenario. 

d) Give a new person a small, discrete project to start with. Something that you know will result in a quick win. 
Really map out in detail what all the steps should be, and the timelines. Don't expect them to guess how to proceed. 
Do expect them to take longer than you might have expected at first. However long you think it's going to take, 
multiply that by at least 3. Maybe 10. If they finish it faster, everybody's happy. If they finish it on time, they've learned
a lot, and so have you. 

*Don't expect them to approach the problem the way you would.* You hired this person because they are different from you. That
 means you have to communicate with them about how they prefer to work. It's helpful if you can offer advice on what you 
 might do. They may incorporate your advice in ways you didn't expect. 

e) Once they've been there a little while, be a little bit unavailable sometimes, so they can start doing things on their own. 
Don’t be afraid to tell them to look on stackoverflow/try a little more before they ask you.  

f) Focus on teaching them how to teach themselves, because that’s a more transferrable skill anyway.

This one can be tricky. If you're hiring mostly PhDs, some will already have very mature self-teaching skills, but 
not everyone does. Or they'll be overwhelmed by adjusting to the culture shock of a new environment. 

Note that everyone has different learning styles. Some people need to read, others to listen, still others need diagrams
or just to practice. Some people need to study in a quieter space (both audio and visual quiet). Some need to do new things
in the morning, others at night. If you want to level up your team, pay attention to these differences, and cultivate 
what works for each person. If your team is actually diverse, it won't always be the same. 

**Leveling up**

I think the main difference between junior and senior is knowing what’s known/been done before, 
and what’s really novel or unique to your system. This is true in science and in software. 

Senior people usually have a better grasp of what’s available and where to look for resources. 

Really good senior people always look around first before reinventing the wheel, 
and even if they have to do something novel, they look for related things to build from and inform their process.

Another difference between junior and senior people is that junior people 
typically spend a huge amount of energy doubting themselves and second-guessing every move they make. 

Senior people have usually had more experience with failing and surviving failure, 
so you have to make everyone feel psychologically safe. Junior people don't become senior people unless they 
feel comfortable asking for help. 

They have to know that even if they screw up, it will probably cost some time, 
and it might even cost some money, but it's probably not going to cost anyone their job if they screw up once in a while. 

