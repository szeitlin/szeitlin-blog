So I have some bike data that I parsed out of XML and put into a pandas dataframe. Most of the questions I wanted to ask required that the timestamp of each ride segment, or lap, be used as the index along the x-axis of a plot. 

**Non-obvious nuances of pandas datetime objects and indexes.**
----------------------------------------

 **You have to sort the dataframe by timestamps, before you can convert the timestamps to use as an index.** 

If you want to follow along, the .ipynb  is [here][1]. 

[code lang="python"]    
sorted_by_date = df.sort_index(by='StartTime') 

sorted_by_date['StartTime'] = sorted_by_date['StartTime'].apply(pandas.to_datetime)
[/code]


----------


 **If you want to truncate and resample the data for plotting, you have to resample first and truncate second.**

[code] StartTime	TotalTimeSeconds   DistanceMeters    MaxSpeed    Calories    AvgSpeed
2013-01-02 15:51:51	 1690.76	 14632.39	 12.05	 572	 8.65
2013-01-03 00:20:26	 1928.39	 15305.22	 12.34	 702	 7.94
2013-01-04 15:46:52	 1680.40	 14651.60	 12.28	 572	 8.72
2013-01-04 23:59:27	 1962.15	 15237.36	 11.43	 691	 7.77
2013-01-07 15:56:14	 1657.51	 14625.53	 12.02	 609	 8.82
[/code]


There were some days with multiple trips, and some days with only one trip. 

If I wanted to know, for example, the total Calories burned in a day, I needed to combine the trips from each day by resampling. Thankfully, pandas makes this really easy. 

[code lang="python"]
    days = df.resample('B') #B means business days

	TotalTimeSeconds   DistanceMeters   MaxSpeed   Calories   AvgSpeed
StartTime					
2013-01-02	 1690.760	 14632.39	 12.050	 572.0	 8.650
2013-01-03	 1928.390	 15305.22	 12.340	 702.0	 7.940
2013-01-04	 1821.275	 14944.48	 11.855	 631.5	 8.245

[/code]

But then I went to plot the data, and all the timestamps came out looking like this:

[code]
    2013-01-02 00:00:00
    2013-01-03 00:00:00 
[/code]

Which does not look so great on a plot. :(

I probably could have truncated the labels somehow, but instead of fighting with matplotlib any more than is already always necessary, I went back to figure out how to get rid of the 'times' in the timestamps. 

Turns out you can convert to whatever format you want, using a similar magic to the way resampling options are defined. Which gave me back what I thought I had already. 

[code lang="python"]
    days.index = days.index.values.astype('M8[D]')

    2013-01-02
    2013-01-03

[/code]

----------
I keep finding out the hard way that IPython notebook is a little too clever in that it hides a lot of ugliness for you, but matplotlib is stubborn and wants to be overly correct, so it shows everything, even the meaningless stuff. 


----------


So why bother doing all that? Because one of the plots I wanted to make was how many calories were burned per day. First, I just made a histogram, using the resampled 'days' data frame. The result was surprising: a lot lower than we might have expected. 

![calories.png](/site_media/media/92f0f1c82f0c1.png)
    


----------


The other plot I wanted to make was actually calories per day. This turned out to be harder than I might have expected. Even after getting rid of the extra 00:00:00, my first attempt came out looking kind of stupid, because there were way too many data points. 

![calories_by_day.png](/site_media/media/00e83fba2f0d1.png)

I wasn't sure how to truncate the data, so I thought I'd try a lazy approach again and do an SQL query to just randomly select a subset of the data, and limit it to less than half the data points. 

Note: I found out the hard way that once again, I had to reset the date(time) index to turn it into a column called 'index', or it got lost when I did the query. 

Then I turned it back into the index of the resulting dataframe, so I could use it as the labels for the x-axis. 

[code lang="python"]
    days2 = somedays.reset_index()   #note that I found this out the hard way

    q="""SELECT *
    FROM days2
    ORDER BY RANDOM()
    LIMIT 100"""

    subset = pandasql.sqldf(q, locals())

    date_subset = subset.set_index(['index'])     #put the index back where I wanted it
[/code]

![calories_day_better.png](/site_media/media/bc5d25bc2f121.png)

Thanks for reading this far! I also went on and did more in [part 3][2] and part 4.


  [1]: https://github.com/szeitlin/biking_data/blob/master/import-one-year.ipynb "here"
  [2]: http://codrspace.com/szeitlin/biking-data-from-xml-to-plots-part-3/ 