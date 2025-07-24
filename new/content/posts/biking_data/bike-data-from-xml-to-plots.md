---
title: "Biking data from XML to analysis, part 1"
draft: false
author: Samantha G. Zeitlin
---

I was looking for some fun time series data to hack on. Turns out [bike computers][1]  provide a great way to interface between your friends' unfounded modesty and their actual rides. 

One friend was kind enough to donate some data for my entertainment. This friend wears spandex, rides a titanium frame road bike, and sweats a lot. I knew he was a strong cyclist. He's also relatively consistent, which meant the data he gave me wasn't too terribly noisy. But everyone forgets to turn on the computer sometimes, or forgets to charge the battery.

Garmin has an app that lets you export data from the puny bike computer and, I guess, view it. But I wanted to do more analysis, so I tried a few things. Exporting the data as regular CSV seemed to work at first, but when I went to view the data, it was missing most of the information I wanted, like time and distance. 

Eventually I realized the only way to get the values I wanted was to export as XML, which I had heard was not fun to parse. 

A snapshot of the file looks like this:
```XML
<?xml version="1.0" encoding="UTF-8" standalone="no" ?>
<TrainingCenterDatabase xmlns="http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.garmin.com/xmlschemas/ActivityExtension/v2 http://www.garmin.com/xmlschemas/ActivityExtensionv2.xsd http://www.garmin.com/xmlschemas/FatCalories/v1 http://www.garmin.com/xmlschemas/fatcalorieextensionv1.xsd http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2 http://www.garmin.com/xmlschemas/TrainingCenterDatabasev2.xsd">

  <Folders/>

  <Activities>
    <Activity Sport="Biking">
      <Id>2013-06-11T23:18:21Z</Id>
      <Lap StartTime="2013-06-11T23:18:21Z">
        <TotalTimeSeconds>1669.7500000</TotalTimeSeconds>
        <DistanceMeters>14122.1464844</DistanceMeters>
        <MaximumSpeed>11.1599998</MaximumSpeed>
        <Calories>575</Calories>
        <Intensity>Active</Intensity>
        <Cadence>0</Cadence>
        <TriggerMethod>Manual</TriggerMethod>
        <Extensions>
          <FatCalories xmlns="http://www.garmin.com/xmlschemas/FatCalories/v1">
            <Value>0</Value>
          </FatCalories>
          <LX xmlns="http://www.garmin.com/xmlschemas/ActivityExtension/v2">
            <AvgSpeed>8.4576416</AvgSpeed>
          </LX>
        </Extensions>
      </Lap>
      <Lap StartTime="2013-06-12T00:42:37Z">
```

Unexpectedly, the links in the file that were supposed to tell me the schema were all outdated (this bike computer is not exactly the newest model). So I hunted around a bit and found I could use [lxml objectify][2]. This let me parse the XML, starting with the root. Then I could "walk" along the tree to figure out what was where. 

In practice, without a useful map of the schema, "walking the tree" was more like hiking the Appalachian Trail (by which I mean, full of rocks) than a pleasant stroll. Eventually, I found [this file][3], which helped somewhat. 

Even with more of a map, the structure seems strange. Some values were nested for no apparent reason (maybe that's typical for XML? I don't know). Some basic calculations for obvious things (like average speed) were added separately as "Extensions", like an afterthought. 

```python
import pandas
from lxml import objectify
path = "2013_xml.tcx"
parsed = objectify.parse(open(path))
root = parsed.getroot()
root.Activities.Activity.Lap.descendantpaths()
```

Which told me the actual structure looks more like this: 
 
```
[u'{http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2}Lap',
 u'{http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2}Lap.TotalTimeSeconds',
 u'{http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2}Lap.DistanceMeters',
 u'{http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2}Lap.MaximumSpeed',
 u'{http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2}Lap.Calories',
 u'{http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2}Lap.Intensity',
 u'{http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2}Lap.Cadence',
 u'{http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2}Lap.TriggerMethod',
 u'{http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2}Lap.Extensions',
 u'{http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2}Lap.Extensions.{http://www.garmin.com/xmlschemas/FatCalories/v1}FatCalories',
 u'{http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2}Lap.Extensions.{http://www.garmin.com/xmlschemas/FatCalories/v1}FatCalories.Value',
 u'{http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2}Lap.Extensions.{http://www.garmin.com/xmlschemas/ActivityExtension/v2}LX',
 u'{http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2}Lap.Extensions.{http://www.garmin.com/xmlschemas/ActivityExtension/v2}LX.AvgSpeed']
``` 

And just to make it more fun, in some cases, the data was the "value", in some cases it was the "text", in some cases it was the "pyval" (python-friendly version of otherwise deeply nested values). In some cases, where the values were "text" that meant they were strings when I needed floats. So I had to drill down, and then drill down some more, and convert everything, and it still isn't obvious to me why they structured it this way. But I parsed out the things I wanted and wrote them to lists:

```python
for activity in root.Activities.Activity:
    for lap in activity.Lap:
        StartTime.append(lap.values()[0]) 
        TotalTimeSeconds.append(float(lap.TotalTimeSeconds.text))
        DistanceMeters.append(float(lap.DistanceMeters.text))
        MaximumSpeed.append(float(lap.MaximumSpeed.text))
        Calories.append(float(lap.Calories.text))
        
        kids= lap.Extensions.getchildren()
        avgspeed = kids[1].AvgSpeed.pyval       #use pyval to get rid of nested brackets 
        AvgSpeedList.append(avgspeed)
``` 

Of course that was just a first pass, and I quickly realized things were still not very pretty. I got rid of extra decimal places, and converted each list to a pandas Series so I could concatenate them together into a big dataframe. For example:

```python
AverageSpeed = pandas.Series(AvgSpeedList)
AverageSpeed = AverageSpeed.round(2)

#join Series as columns in a new dataframe
df = pandas.concat([StartTime, TotalTimeSeconds, DistanceMeters, \
MaximumSpeed, Calories, AverageSpeed], axis=1)

#rename the columns to something useful
df.columns = ['StartTime','TotalTimeSeconds', 'DistanceMeters', \
'MaximumSpeed', 'Calories', 'AverageSpeed']
```

Finally! Now the data table looked more like this: 

```
StartTime	   TotalTimeSeconds	DistanceMeters	MaximumSpeed	Calories	AverageSpeed
2013-06-11T23:18:21Z	 1669.75	 14122.15	 11.16	          575	         8.46

```
But as I'm finding with these low-level data science tools, just getting numbers into a table isn't going to tell you much, and every different question you want to ask, every plot you want to make, means making additional tables, usually with a lot more rearranging. (More on that in [part 2][4]) 
  


  [1]: http://www.garmin.com/en-US "Garmin"
  [2]: http://lxml.de/1.3/objectify.html "LXML objectify"
  [3]:  http://www8.garmin.com/xmlschemas/TrainingCenterDatabasev2.xsd "tcx schema"
  [4]: {{<ref "biking-data-from-xml-to-plots-part-2.md" >}}
