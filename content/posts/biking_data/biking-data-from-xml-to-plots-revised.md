---
title: "Biking data from XML to analysis, revised"
draft: false
date: 2015-08-07
tags: ["device data", "bike"]
author: Samantha G. Zeitlin
---


*Am I getting slower every day?* 

If you've ever been a bike commuter, you've probably asked yourself this question. Thanks to these little devices we can now attach to ourselves or our bicycles, we can now use our own actual ride data to investigate these kinds of questions, as well as questions like these:

 - If I'm going to work from home one day a week, which day would maximize my recovery?
 - Do I tend to ride faster in the morning or the evening? 


----------


Last year, I wrote [a few posts][1] about learning how to parse a set of Garmin XML data from 2013 and analyze it using pandas, matplotlib, and [seaborn][2]. This year I redid the same analyses, with a new installment of data from 2014. 

This new and improved version is both prettier and more interesting, thanks to having more data, and more experience with pandas and seaborn (not to mention that pandas and iPython notebook have both been updated a few times). In this series of posts, I'll show what I did to improve on my initial attempts. In later posts, I'll present some new analyses of higher-density time series data, which include detailed 3D location information in the form latitude, longitude, and altitude. 


----------

## First, get a rough idea of what is going on

One of the first questions we wanted to ask was about relative speeds in the city vs. suburbs, and morning vs. evening. 

Last year I made [this plot][3], roughly separating city vs. suburbs based on the length of the trips. 

This year I used time of day to get better separation. 


```python sns.set(style="ticks") ```
```python sns.jointplot("hour", "average_mph", data=filtered) ```

![avg_mph_jointplot.png](/site_media/media/e4d627b8c5131.png)

And that gave me a clear idea of what might work, but this kind of plot is not very easy to look at if you're not a data person. 


----------
## Clarify relevant questions

So to make it a little clearer, and be able to ask better questions, I wrote a simple helper function to add a flag for the four main categories I wanted: morning city, morning suburbs, evening city, evening suburbs. 

On further revision, I added a couple of extra flags for two kinds of 'outliers': one I called 'evening later' for when Caltrain was delayed, plus 'other' for those random data points that were probably due to the Garmin device being on or off when it shouldn't be, aka, user error. 

Then I used a list comprehension to apply that to the 'hour' column in my dataframe, which I had previously generated using the awesome built-in datetime handling that pandas makes so easy. Then I made a better plot with seaborn. 

```python   
     def leg_definer(hour):
        """
        (int) -> (str)
    
        Helper function to identify trip legs by hour, i.e.
             6 AM: first leg (to Caltrain) - morning_city
             7 AM: second leg (to work) - morning_suburb
             4 PM (16): 3rd leg (return to Caltrain) - evening_suburb
             5 PM (17): 4th leg (return home) - evening_city
             later - evening_later (Caltrain delays, etc)
             other hour: other
    
        >>> leg_definer(6):
        'morning_city'
    
        """
    legref = {6:"morning_city", 7:"morning_suburb", 16:"evening_suburb", 17:"evening_city", 9:"other", 11:"other", 12:"other", 15:"other", 18:"evening_later"}
    return legref[hour]
    
    filtered["leg_flag"]=[leg_definer(hour) for hour in filtered["hour"]]
    
    g = sns.lmplot("day", "average_mph", filtered, hue="leg_flag", fit_reg=False)
    g.set(xticks=[0,5,10,15,20,25,30], ylim=(5,24))
 ```

![2014_avmph_day_lmplot.png](/site_media/media/25e3a19ec5151.png)

And I think that's pretty cute, but it doesn't really show any meaningful patterns, because we're looking at all the months on top of each other (day here is coming from the date, aka 'day of the month'). 

----------
## Focus on how to see what you're looking for

I realized grouping by weekday was more likely to be interesting. And then I got caught by one of those random little pandas gotchas: weekday is a method, not a datetime attribute. So it's item.weekday(), not item.weekday (so it's different from month, day, or hour). 

I also had to use a plotting trick of adding horizontal 'jitter' to make it easier to see all the dots on the scatterplot that would otherwise be overlapped. 

```python
filtered["weekday"]=[item.weekday() for item in filtered["zoned"]]

sns.set_context("talk")
g=sns.lmplot("weekday", "average_mph", filtered, hue="leg_flag", x_jitter=0.15, fit_reg=False)
g.set(xlim=(-1,6), ylim=(5,24))
```

![2014_avgmph_weekday_flagged.png](/site_media/media/b84c398ac5181.png)

This plot is starting to make more sense. Now, we can start making some observations and generating new hypotheses (which may or may not match up with our previously qualitative impressions). 

 - Suburbs have higher average speeds (gold and red dots) than city *(hypothesis: traffic)*
 - Morning city is much faster than evening city *(hypothesis: traffic)*
 - Morning suburb is a bit faster than evening suburb *(hypotheses: tired? slope? wind?)*
 - Fewer rides on Thursdays (weekday 3) make sense, since this cyclist usually works from home on Thursdays (but not always). Interestingly, Thursday rides seem to cluster toward the faster end *(hypothesis: taking Wednesday off to recover makes Thursday's ride easier)*


----------
## Sometimes a different type of plot works better to get your point across

Now, it seemed like the relevant finding was that Mornings were generally faster than Evenings, and I decided to focus on the Suburbs rides since they were less vulnerable to the confounding (!) effects of traffic. 

I chose a violin plot to show the distributions more clearly. I hadn't done this quite this way before, but it's actually very easy to create a plot object, and add a couple of subplots. Then I tweaked it a little more: I adjusted the range of the axes, as well as getting rid of the tick-marks along the edge, to make it less cluttered. (Also, I didn't know how to add a title to a plot, so I had to look that up!)

```python
f, ax= plt.subplots()
g = sns.violinplot(evening_suburb["average_mph"], evening_suburb["weekday"], color="Blues")
g = sns.violinplot(morning_suburb["average_mph"], morning_suburb["weekday"], color="Yellow")
g.set(ylim=(10,24))
title("Morning(yellow) vs. Evening(blue) Suburb")
sns.despine()
```

![2014_morning_vs_suburb.png](/site_media/media/bafb74eac51b1.png)

At the end of the day, I think this plot makes it pretty clear that Morning rides have higher average speeds than Evening rides. Which made me wonder: if we plot the route on a map, can we find out if the road is actually slightly inclined, such that it's actually downhill in the morning, and uphill at night? The incline must be minimal, since this cyclist perceives it as being 'flat'. 

Sure enough, a rough estimate of the route using this awesome tool at [cycleroute.org][4] gives a plot that looks something like this:

![Screen Shot 2015-03-07 at 3.18.48 PM.png](/site_media/media/482a5698c5201.png)

Next time: Plotting the measured velocities over the distance of the actual route. 


  [1]: {{<ref "bike-data-from-xml-to-plots.md" >}}
  [2]: http://web.stanford.edu/~mwaskom/software/seaborn/
  [3]: http://codrspace.com/site_media/media/73752cba2ef31.png "this plot"
  [4]: http://cycleroute.org "Cycle Route"
