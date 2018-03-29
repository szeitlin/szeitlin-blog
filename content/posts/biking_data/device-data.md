---
title: "Working with device data"
draft: false
date: 2015-04-30
tags = ["device data", "bike data"]
author: Samantha G. Zeitlin
---


In continuing my series on [investigating bike data][1], I ran into some interesting aspects of working with device data. 

I have some experience with devices, thanks to my many years of working in research labs. This post is about the fun of hunting down what's working and what's not. 

## Things to consider when working with devices ##

 1. Are you using the device yourself?
 2. Are you interacting with the user(s) (directly or indirectly)? Or not at all?
 3. What is the device *designed* to do? Are you using it for its intended purpose?
 4. How well does the device actually work? Generic measurables might include: sensitivity, specificity, accuracy, precision, battery life
 5. What else is being measured?
 6. Measured how?
 7. How are data stored? How much data can it store? How does it connect to other devices/data stores?

In the case of a bike computer, I have been looking at:

Aggregated/cumulative (average speeds, calories) vs. realtime 
• altitude • distance • speed • cadence •

Measured using: • internal clock • GPS • barometric pressure • cadence magnet •

----------

On the first pass through, I just looked at aggregated/cumulative values. More recently, I looked at the 'realtime' data. This meant I had to re-do [the script to parse the raw XML][2], and it had to be even more robust, because the computer automatically deletes data to save space, but I wasn't sure whether that meant whole days went missing, or whole months, or just parts of trips. 

The main advantage of parsing the raw data yourself is that you know your dataframe is going to be tidy. 

----------

This time around, I had two years' worth of data to compare, which made things a little more interesting. 

![Screen Shot 2015-08-07 at 4.19.23 PM.png](/site_media/media/e9189f583d5a1.png)

This file is a great example of how two distributions can be quite different in some aspects (bimodal in 2013, vs. almost gaussian in 2014), but the averages are quite similar, arguably not significantly different. 


----------

## Leverage granularity of real-time data using generators ##

I wanted a pipeline to process the data into manageable units, for two purposes. (1) to make plots to look at the degree of variability, and (2) to feed into outside APIs, like Google Maps.  

The [code][3] structure looks like this:

**splitter**: split altitudes by date
yield list of (distance, altitude)

**filter**: check for sequential distances
(if distance goes down, something’s wrong)
yield filtered list of (distance, altitude)

**df_maker**: call splitter and filter
convert to data frame
yield data frame 

**plot_maker**: call data frame maker
a whole series of plots! 

----------

![Screen Shot 2015-08-07 at 4.30.48 PM.png](/site_media/media/7621b7123d5c1.png)

Some of the plots looked fine, but many had varying degrees of inconsistent problems. 


----------
## The path to enlightenment (when you can’t walk it yourself)  ##

Initially, I wanted to look at altitude over time, but I realized that datetime objects were adding unnecessary complexity. So instead I did distance vs. altitude, which revealed that the source of the noise seemed to be related to altitude. 

When I find unexpectedly noisy data, I go through a checklist that looks something like this:

Possible sources of ‘noise’:

1) developer error (parsing error? grouping wrong?)

2) device failure (sensor problems)

3) user error 

Unless the user tells me they know they always forget to turn the computer off when they get on Caltrain, or that they've dropped it repeatedly from a great height, I look at other factors first. Namely, my own mistakes, the age of the device, other environmental issues (is it not waterproof enough? when was the last time it was out in the rain?). 

----------
## When in doubt, validate using orthogonal methods ##

I had been thinking about trying out the Google Maps API, and here was my perfect excuse. 

There is a python wrapper for their REST (REpresentational State Transfer) API (Application Programming Interface). The python wrapper helps to construct the URL and submit the request, as well as helping to parse and display the response. 

I ran into limits on the allowed length of the URL, though, because I was trying to submit entire paths of (lat,long) tuples from whole days worth of data. I realized I could shorten the request URL by simply removing duplicates from the paths, since the bike computer reports the location even if the altitude hasn't changed at all. 

![Screen Shot 2015-08-07 at 4.47.05 PM.png](/site_media/media/b1c1b7343d5e1.png)

I was relieved to see that although the bike computer seemed to be dying, it wasn't working too badly before it died. 



  [1]: {{< ref "biking-data-from-xml-to-plots-revised.md" >}}
  [2]: https://github.com/szeitlin/biking_data/blob/master/xml_feb26_2015.py
  [3]: https://github.com/szeitlin/biking_data/blob/master/14April_googlemaps_api.ipynb
