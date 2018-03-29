One thing I wanted to do with this data set was experiment with plotting methods. I had already done some exploratory plotting with regular matplotlib, so I had some vague ideas about what I wanted to do. 

First I had to select out subsets of data to compare. I knew that there were two types of rides: shorter trips in the city, and longer trips in the suburbs. I was feeling lazy, so I just did a quick threshold with SQL. 

[code lang="python"]
    import pandas
    import pandasql

    import matplotlib.pyplot as plt
    import matplotlib 
    import seaborn as sns     #for prettier plotting 
    import numpy as np        #for binning

    %matplotlib inline    #IPython magic

    df = pandas.read_csv("updated_2013.csv", index_col=0)

    q="""SELECT *
    FROM df
    WHERE Miles <6"""

    city = pandasql.sqldf(q, locals())

    q="""SELECT *
    FROM df
    WHERE Miles >5"""

    suburbs = pandasql.sqldf(q, locals())

[/code]


----------

## Give that story a little more plot! ##

First, I used seaborn to make two histograms of the average speed, and plot them together in two different colors. Thankfully, the [seaborn tutorial][1] had exactly the right example for me to follow, but I'm going to explain a few things that were not obvious to me. 


----------


**Calculate the range for the binning** 

If you have more than one data set, this is done by concatenating the dataframes so you can treat the data as one big one. 

To do this, the example in the seaborn tutorial used this odd little thing called r_. I didn't know what that was, so I did some digging and found [this post][2] the most useful. I'll probably be able to remember it now that I know that it's similar to how slicing works in R. 

The actual bins come from using linspace to create an array of linearly spaced points. 

The normed=True argument is good here because I didn't want to worry about the size of the distributions (I knew they weren't the same). 


----------


**Show your colors!**

I had to look up what the colors were, because in the tutorial they don't tell you, and it wasn't obvious to me from the hex code, which color was which dataset. I also didn't know that you can add the label to the same command where you chose the data set, because initially the legend didn't show up at all. 

Ultimately, I had to add this ridiculously complicated (typical matplotlib) line to tell it to put the legend to the right a little bit. Otherwise who knows if there is a legend, because it is invisible. 

[code lang="python"] 
    max_data=np.r_[cityspeed, suburbspeed].max()
    bins= np.linspace(0, max_data, max_data+1) 
    plt.hist(cityspeed, bins, normed=True, color="#6495ED", alpha=0.5, label="city")      #blue
    plt.hist(suburbspeed, bins, normed=True, color="#F08080", alpha=.5, label="suburb")   #coral 
    plt.xlabel("Mph")
    plt.ylabel("Fraction")
    l = plt.legend(bbox_to_anchor=(1.05, 1), loc=2, borderaxespad=0.)   #show me the legend!

[/code] 

At the end of all that, I was pretty happy with how this plot turned out. 

It's not surprising that the suburb plot is relatively gaussian with little bit of a tail to the left. What surprised me was how high the average speeds were, even on the relatively short city rides. Personally, I don't like to ride that fast in the city, because most of the time it is too scary and/or impossible with traffic. But the timestamps give a little more insight into why that's not always impossible (more on that in [part 4][3]). 

![city_vs_suburb.png](/site_media/media/73752cba2ef31.png)


  [1]: http://stanford.edu/%7Emwaskom/software/seaborn/tutorial/plotting_distributions.html#basic-visualization-with-histograms
  [2]: http://stackoverflow.com/questions/18601001/numpy-r-is-not-a-function-what-is-it
  [3]: http://codrspace.com/szeitlin/biking-data-from-xml-to-plots-part-4/