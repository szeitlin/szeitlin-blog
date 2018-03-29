---
title: "Biking data from XML to analysis, part 4"
draft: false
author: Samantha G. Zeitlin
---


One of the main reasons this project turned out to be interesting is that time series data has all kinds of gotchas. I never had to deal with a lot of this before, because the sorts of time series I did in my scientific life didn't care about real-life things like time zones. We mostly just cared about calculating time elapsed. 

...tick...tick...tick

Anyway one thing I wondered about with the bike data was,  can we compare average speeds in the morning vs. the afternoon? But to do that, I first had to parse the datetime objects and put them in the right time zone. 

Since indexes are immutable in pandas, if you want to do any parsing on them, you have to do it with the information in a regular column. So I had to back up a step to before I made the timestamp into the index. 

I ended up using [dateutil][1] to do the parsing, and [pytz][2] to convert the timezone. 

[code lang="python"]
    import pandas
    from dateutil.parser import parse
    import pytz

    df = pandas.read_csv("sorted_by_date.csv", index_col=0)

    df['parsed']=[parse(x) for x in df['StartTime']]
    df['parsed'].head()

Out:
1 2013-01-02 15:51:51+00:00
2 2013-01-03 00:20:26+00:00
3 2013-01-04 15:46:52+00:00
4 2013-01-04 23:59:27+00:00

    df['zoned'] = [x.astimezone(pytz.timezone('US/Pacific')) for x in df['parsed']]
    df['zoned'].head()

Out:
1 2013-01-02 07:51:51-08:00
2 2013-01-02 16:20:26-08:00
3 2013-01-04 07:46:52-08:00
4 2013-01-04 15:59:27-08:00
5 2013-01-07 07:56:14-08:00
[/code]

That weird -08:00 on the end is the time zone adjustment. In San Francisco, we're 8 hours off from Greenwich Time (aka UTC). [This map][3] is kind of goofy looking, but it's very clear, and you can zoom in for more information. 


----------


Then it occurred to me that I could just plot the hours, before sorting, to have some idea what to expect. 

[code lang="python"]
    df['hours']=[x.hour for x in df['zoned']]
    
    import matplotlib.pyplot as plt
    import seaborn as sns

    sns.set_palette("deep", desat=0.6)
    sns.set_context(rc={"figure.figsize": (8,4)})

    df['hours'].hist() 
    plt.xlabel('hour of the day(correct timezone)')
    plt.ylabel('frequency')

[/code] 

![hours.png](/site_media/media/a95f951c2f081.png)

So that presented a hypothesis: maybe the way to have really high average speeds in the city is to ride really early, when there's no traffic. (I'll admit to having ridden that early myself, and let's just say if you want to go fast, it's either that or come home very late at night.) 



  [1]: https://labix.org/python-dateutil
  [2]: http://pytz.sourceforge.net
  [3]: http://www.worldtimezone.com/standard.html
