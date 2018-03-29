Here is a story about an interesting interview question and how I approached it. 

The company in question wasn't interested in actually looking at my code, since I apparently tried to answer the wrong question. 

> Given a deck of n unique cards, cut the deck c cards from the top and perform a perfect shuffle. A perfect shuffle is where you put down the bottom card from the top portion of the deck followed by the bottom card from the bottom portion of the deck. This is repeated until one portion is used up. The remaining cards go on top.


> Determine the number of perfect shuffles before the deck returns to its original order. This can be done in any language. A successful solution will solve the problem for 1002 cards and a cut size of 101 in under a second even on a slow machine.

I looked at that and did what they tell you to do for interviews, and coding in general, especially when you don't know where to start: start with the naive, simple approach. 

Step 1. make_deck

    [code lang="python"] cards = [x for x in range(1,n+1)] 
[/code]

Step 2. def shuffle(cards,c):

[code lang="python"]
   """
   :param: c, where to cut the deck (int)
   """
    top = cards[0:c]
    bottom = cards[c:]

    stopping_criteria = min(len(top), len(bottom))

    newstack = deque()

    for i in range(stopping_criteria):
        newstack.append(top.pop())
        newstack.append(bottom.pop())

    if (len(top)==0) and (len(bottom)==0):
        return newstack

    elif len(top) > 0:
        newstack.extendleft(top)
    elif len(bottom) > 0:
        newstack.extendleft(bottom)

    return newstack
   [/code]

Step 3. def shuffle_recursive(cards, c, shuffle_count):

[code lang="python"]

    """
    shuffle until the original order is restored, and count as you go.
    assuming for now that original order is sequential and first card is always 1.

    :param n: deck size to pass to shuffle function (int)
    :param c: cut size to pass to shuffle function (int)
    :param newstack: variable to hold the list during shuffling
    :return: (newstack (shuffled list), shuffle_count (int)) as a tuple
    >>> shuffle_recursive([1,2,3,4,5], 3, 0)
    4
    """
    newstack = shuffle(cards,c)

    shuffle_count +=1

    if list(newstack) == [x for x in range(1, len(cards)+1)]: #stopping criteria
        return shuffle_count

    else:
        return shuffle_recursive(list(newstack), c, shuffle_count)

[/code]

So I did that, and was surprised to get a recursion depth error. 

Then I realized it only works up to the max recursion depth of 999.

Also, it was obviously too slow. 

So I did some profiling, and found that the majority of time was spent in these 3 lines:

[code lang="python"]
   for i in range(stopping_criteria):
        newstack.append(top.pop())
        newstack.append(bottom.pop())
[/code]

And that kind of surprised me, since I thought the whole point of deque() is that it's supposed to be faster. 

So then I spent some time thinking about how I could possibly make the code go faster. 

Ultimately I ended up directly creating the interleaved bottom part of the deck, and then added the top. I noticed that the tricky part was dealing with the leftover cards. I also noticed that it took a lot fewer iterations to get back to the starting order if I reversed the top cards before I put them back. 

Then I hooked that up to run iteratively, so I could control the number of times it ran, for debugging, etc. 

The code is [here][1] if you want to see what I did. 

I wrote a [bunch of tests][2] while I was doing this, like I always do, and I couldn't help noticing that there were some weird edges cases that never worked. 

I tried to read some [advanced math articles][3], which led me to understand that the weird edge cases I was seeing were probably harmonics. 

Then, because I'm really a data scientist at heart, I wanted to see what that looked like. 

I wrote a couple of [methods][4] to help me [visualize][5] the results.

Overall, I'd say it was a great coding challenge, really interesting and I learned a lot. 

However. When I went to turn in my work, the response was less than encouraging. 

I wrote:

> I came up with a simple, very slow (10 second+ run-time) solution fairly quickly, and then spent 3-4x more time coming up with a 10x faster solution.

> What I have right now meets the requirement for 1002 cards with cut size 101 in under a second on my mac laptop (see below - not sure what you define as a "slow machine"?).

And the reply came back: 

> What answer did your solution arrive at for the test case? Is is 790034? That's not correct, so if that's the case you should take another look. It should only take a tenth of a second or so.

Apparently I was so annoyed at the way this exchange ended that I deleted both my response (let's consider it redacted) and theirs. I said something about how if the point was that it was a coding exercise, maybe they'd want to see my code even if I got a different answer (I did)? 

They said I should have known I wasn't supposed to try to actually make the decks based on how the question was worded. 

I did not know that. I'm not sure why it's so hard to just ask a straightforward question instead of including, as part of the challenge, that I should be able to read your mind. 

Anyway, they did not want to see my code. 

Shortly thereafter, I asked a friend who is more of an algorithms person and he said "Oh yeah, all you do is write the equation for a single card to get back to its original position, and then you have the answer."

Of course, I found that confusing, because based on what I did, I don't think it's really that simple. I think it depends on how you do the shuffling, e.g. whether you reverse the top half when you add it back on. Which the original question said nothing about. 

And some cards (as the edge cases show) will take a much longer time to get back to their original position, depending on where you cut the deck and how many shuffles you do. 

So, my shuffles might be imperfect, and my ability to read interviewers' minds hasn't improved much. But hey, those harmonics are pretty interesting. 





  [1]: https://github.com/szeitlin/shuffles/blob/master/shuffle.py
  [2]: https://github.com/szeitlin/shuffles/blob/master/test_shuffle.py
  [3]: http://statweb.stanford.edu/~cgates/PERSI/papers/83_05_shuffles.pdf
  [4]: https://github.com/szeitlin/shuffles/blob/master/explore_shuffle.py
  [5]: https://github.com/szeitlin/shuffles/blob/master/06162016_plot_shuffle_harmonics_SGZ.ipynb