---
title: "Recursion excursion"
draft: false
author: Samantha G. Zeitlin
---


More than once, and probably not for the last time, I have done a technical interview for which I was underprepared. 
I feel like no matter how much I try to prepare, I am always underprepared for technical interviews. 

I'm going to tell you about a time I was underprepared for a few reasons, including:

a) It was the first interview where I was asked to write more than a couple lines of recursive code 

b) in front of 3 people

c) For some reason, for this position, it didn't occur to me that I was meeting with the software team and doing a technical interview of that sort at all. 
As I discovered after arriving onsite, my understanding of the role was murky: I thought I was being recruited for a different subset of my skills. 
Also, as has happened to me repeatedly and will probably happen again, although I specifically asked about the structure of the interview, 
critical pieces of information were not communicated to me. 

Nevertheless, I tried.  

I failed. 

I came home and spent the last several days thinking about why that was so difficult. In some ways, it was a very good interview question. And I understood the question. 

But I got stuck because I am not great at writing code with people watching me. Or even with other people in the room. Especially in the afternoon. 


----------


**I write my best code exactly the same way I do my best writing: first thing in the morning, alone.** 


----------


One thing I know I need to do, but did not do in this case, is ask my interviewers to not interject suggestions unless I ask them a direct question. 

I've noticed that in many technical interviews, if I ask for confirmation that I'm going in the right direction, I get no response one way or the other. 

Worse than that, sometimes when I'm in the middle of writing something, I'll be interrupted and told that I should fix something else. 

Sometimes the corrections are useful, but that's almost irrelevant, because inevitably they derail my thought process. 

I first identified this as a problem while practicing writing code in front of a friend. I finally screwed up the courage to politely to ask her to please shush so I could hear myself think. 

And that was surprisingly difficult for me to do in a friendly, low-pressure environment. 

It's even harder to do in an interview setting. 


----------


Once I get stuck on something, I really need to take a break. A physical break from the computer. 

This is not something you get to do in an interview. 

So I came home and worked on the problem, and thought about why I got stuck. Here is what I figured out. Maybe it will be helpful for you, too. 


----------

**The question: merge two sorted lists, any length, can be empty**

My interpretation of this question was *Oh, it's just the second half of merge sort!*

When I looked at my old solution for merge sort, however, I was splitting the two unsorted lists and iterating over them differently than if they were already sorted. 

When I looked over my notes on merge sort from my Algorithms class, the traditional solution is always a recursive one. 

Recursion has been something I've used very little in my data science activities. Iteration, yes, plenty. Recursion usually doesn't make sense for most of the things I've done. So while I've done some as part of coursework and interview practice, I hadn't done enough for it to become fun. 

As I looked back over what was confusing to me, I broke down the problem into very small pieces. 

Some of the courses I've taken used some kind of interactive 'stepper' to highlight sections of code and walk through the iteration of simple programs. These never worked well for me because the UIs were inevitably terrible. 

Eventually I realized what works better for me is simply looking at output and adding print statements. Ideally, graphs are good, even if I have to draw them out by hand. 


----------


I wrote three very simple programs for myself to try to understand why I was getting stuck, and ultimately try to understand recursion a little better than I did before. 


 **1. Recursive Copy**

        [code lang="python"]
        def recurse_copy(oldlist, stop, newlist, i):
    
            """ Copy one list to a new list.
   
                 (list) -> (list)
    
            >>> recurse_copy([1,2,3,4,5])
           [1,2,3,4,5]
    
            """
    
            print i, newlist

            while len(newlist) < stop:
                i += 1
                newlist.append(oldlist[i])
                recurse_copy(oldlist, stop, newlist, i)

            return newlist



        oldlist = [1, 2, 3, 4, 5]
        newlist = []   
        stop = len(oldlist)
        i = -1
        recurse_copy(oldlist, stop, newlist, i) [/code]

The output looks like this:

        [code lang="bash"]
        -1 []
         0 [1]
         1 [1, 2]
         2 [1, 2, 3]
         3 [1, 2, 3, 4]
         4 [1, 2, 3, 4, 5]  [/code]

And if we want to check the value of oldlist at the end, it's still there:

        print oldlist
        [1, 2, 3, 4, 5]


Super simple, nothing confusing about that at all. So then we step it up a notch. 


----------


**2. Recursive move**

Same idea, but this time we can pull from the old list.  

        [code lang="python"]
    
        from collections import deque

        def recurse_move(oldlist, stop, newlist,i):
    
            """ Move items from one list to another. 

                 (list) -> (list)
    
            >>> recurse_move([1,2,3,4,5])
           [1,2,3,4,5]
    
           """
    
            print newlist

            while len(newlist) < stop:
                newlist.append(oldlist.popleft())
                recurse_move(oldlist,stop,newlist,i)

           return newlist 




        oldlist=deque([1,2,3,4,5])
        newlist=[]
        stop=len(oldlist)

        recurse_move(oldlist,stop,newlist,i)   [/code]

This time I got rid of the index, but the output looks the same. 

        [code lang="bash"]
        []
        [1]
        [1, 2]
        [1, 2, 3]
        [1, 2, 3, 4]
        [1, 2, 3, 4, 5] [/code]

But this time, oldlist is empty:

        print oldlist
        deque([])


----------


**3. Recurse count exits**

So I was working on my solution and creating bugs and trying to fix bugs, and noticing that I wasn't sure how to track down exactly what was going wrong. The approaches that always worked for me with iteration weren't working. Sometimes the loop seemed to go through more times than I expected, and I wasn't sure why. 


----------


One thing that confused me was what happens if you try to put any code after the recursive statement. In the classes I took, we never did this, and when I tried to do it in my own code, the output wasn't what I expected. 

        [code lang="python"]
        from collections import deque

        def recurse_count_exits(oldlist, stop, newlist,i):
    
            """ Move items from one list to the next, 
            while counting entrances (i) and exits ("exiting"). 

            (list) -> (list) 

            """
    
            print i, newlist
            while len(newlist) < stop:
                newlist.append(oldlist.popleft())
                i+=1
                recurse_count_exits(oldlist,stop,newlist,i)

            print "exiting"




        oldlist=deque([1,2,3,4,5])
        newlist=[]
        stop=len(oldlist)
        i=-1

        recurse_count_exits(oldlist,stop,newlist,i) [/code]

The output is somewhat counterintuitive, in my opinion. I expected it to look like this:

       [code lang="bash"]
       -1 []
       exiting
       0 [1]
       exiting
       1 [1,2]
       exiting
       [..]   [/code]

But instead, it looks like this: 

        [code lang="bash"]
        -1 []
        0 [1]
        1 [1, 2]
        2 [1, 2, 3]
        3 [1, 2, 3, 4]
        4 [1, 2, 3, 4, 5]
        exiting
        exiting
        exiting
        exiting
        exiting
        exiting [/code] 

So really, two things were surprising to me. 

 1. I didn't understand why 'exiting' was being printed all at the end like that. 
 2. I didn't understand why 'exiting' was being printed 6 times, instead of 5. 

Ultimately, it boiled down to one thing: *I was expecting the recursive call to act more like a return statement*, i.e. I was thinking that whatever came after it would be ignored. 

I didn't realize that the exiting print statement was essentially being 'saved' each time the loop executed. 

That 'extra' print statement comes from the last time through the loop, when it checks whether the length is less than the stopping criteria, and then exits. 

I also ran into a wacky thing where I was getting the right results (as verified with print statements), but my return value was coming back empty. I was able to fix it, but I still don't completely understand how that would happen. (If I figure out why, I may come back later to edit this post to include that.) 

So ultimately, it took me a while, but I came up with [a solution][1], complete with unit tests. It may not be the most pythonic or pretty, but it works. 

(And I realized afterwards that I could have done a simple iterative solution to this version of the question, because it's not actually merge sort and it didn't actually have to be recursive.) 


----------


*

 - live
 - fail
 - learn
 - blog about it so I don't forget

*


----------


 


  [1]: https://github.com/szeitlin/python-practice/blob/master/merge_sorted_lists.py
