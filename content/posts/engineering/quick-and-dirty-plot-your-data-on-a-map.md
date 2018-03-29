---
title: "Quick and dirty: plot your data on a map with python"
draft: false
author: Samantha G. Zeitlin
---


Once upon a time, I looked at a couple of data sets that involved geographical data. I wanted to actually plot the data on a map, so I had to do some shopping around for easy ways to do this quickly with python. 


----------


## What I wanted to do ##

One of the data sets provided zipcodes, which I was able to convert to latitude and longitude (more on this below). At a minimum, I knew I wanted to be able to plot: a) location, b) a number value and text label, c) multiple colors designating groups of data points, e.g. 'high' or 'low' values for a particular variable, which ideally could be toggled on and off. 

I tried looking at the various options for google maps, and just felt overwhelmed by the choices. My data was already in pandas dataframes, so I didn't want to convert it to json, or whatever. Really what I wanted was just a simple python wrapper for the API, even if I'd have to switch to something else later.  

The most difficult question is of course this one: *How much interactivity will I need?* I don't know, maybe more in the future, but to start with I just wanted to get something on a map. Minimal interactivity required, at least initially. 


----------
## What I used ##

After exploring a myriad of available options, I settled on an open-source library called [pygmaps][1], which seemed like it could do what I needed. But it was a little bit out of date, so when I went to try using it, I got some errors. I had to edit the source to remove a method that I didn't need, in order to get rid of one of the requirements that I couldn't find anywhere (it looks like this has since been fixed in [pygmaps-ng][2]). 

To convert my zipcode column into latitude and longitude coordinates, I used [this free zipcode database][3], and incorporated that back into my dataframe using pandas (more on that below). 


----------
## Zipcode lookup ##

To find the zipcodes for the data points in my dataframe, I just wanted to match on zip code and return the latitude and longitude as additional columns in my existing dataframe. 

Essentially, this can be done in a one-line [join][4]. Pandas now has this built in, but it helps to understand how it works in SQL because the arguments are that same style. 

```python

zips = pandas.read_csv("zipcode.csv")

zippier = zips[['zip', 'city', 'state', 'latitude', 'longitude']]

mappable = pandas.merge(mydata, zippier, how='left', left_on='ZipCode', right_on='zip', sort=False)

```

----------
## Divvying up the data: High, Medium, Low ##

I played around with different ways to do this. Quartiles and terciles are pretty easy, and it makes sense to do it this way if your data is normally distributed. For some of the stuff I did, that worked. You can either feed it the fractions or the number of bins you want. 

If your data is not a normal distribution, however, it might make more sense to set up your own thresholds to display more meaningful segments that actually correspond to 'high' vs. 'low'. Ultimately, this was more meaningful for some of the variables I was examining. This is why I always look at histograms before I do anything else. 

```python
quartiles = pandas.qcut(df['mycolumn'], [0, .25, .5, .75, 1])

#sometimes useful to check the counts to make sure this worked as expected:
quartiles_counts = pandas.value_counts(quartiles)

#another way to do the divvying
terciles = pandas.qcut(df['othercolumn'], 3, retbins=True, labels=['low', 'middle', 'high'])
```

----------
## Assigning colors to groups ##

Hexadecimal time! 

If you ever saw [my old website][5], you'll immediately know: it's not a secret that I love color. 

So I was mildly frustrated when I was talking to a designer who was very concerned about whether there might be colorblind people looking at the maps I was making. 

Ultimately, I looked at a variety of [color palettes][6], and chose to use maximum contrast, where brighter shades were assigned for 'high' values, and darker shades were assigned for 'low' values. (For those who make a lot of charts, it's nice to know that seaborn shows examples with [a colorblind palette][7]). 

Having picked the colors I wanted, I had to assign them to the appropriate segments of the data. First, I made a dictionary with the flags and the colors. Then I wrote a 1-line function to match the values. 

```python
color_codes = {'low':'660000', 'middle':'990000', 'high':'FF0000'}

def color_picker(terciles, color_codes):
    '''Convert 'low' 'middle' or 'high' tercile flags into hexadecimal color codes. 
    high is brightest, low is darkest.
    
    (list of str, dict of str) -> (list of str)
    
    >>> color_picker(terciles, color_codes)
    ['FF0000', '660000','990000'...]
    
    '''
    return [color_codes.get(x) for x in terciles]

df['colors'] = color_picker(df['terciles'], color_codes)
```

----------
## Format labels ##

I wanted the markers on my map to be labeled, so when I click on them I can see what they are. Formatting the labels turned out to be a bit of a pain in the neck, so I just hacked something together. The trick ended up being that it was easiest to deal with getting the data out of the dataframe by using the itertuples() method. 

```python
def format_labels(df):
    '''
    Each df row is a list of str, float, float, float
    Convert to str for display on map. 
    
    #somewhat lame but ok for now 
    
    '''
    formatted = []

    for row in df.itertuples():
        text = "Marker: {0} <br/> Value: {1} </br> Zippyness: {2}".format(row[4], row[5], row[6])
        formatted.append(text)

    return formatted
```
----------


## Generating the map ##

Finally, after all that, I was able to incorporate my data into a map. I followed the pygmaps example almost exactly. I didn't immediately understand what was going on, so I wrote my methods with names to clarify which sections corresponded to which features on the map. And then I made a map! 

And then I did it a few more times, and realized this is something I might use fairly often. Maybe you will, too. 

```python
#initialize map
mymap = Map()

app1 = App('non', title="Part1")
mymap.apps.append(app1)

app2 = App('part', title="Part2")
mymap.apps.append(app2)

def add_legend():
    '''
    hard-coded labels for groups of markers.

    '''

    part1_legend = DataSet('part1', title='Part1 (red)', key_color='#FF0000')
    app1.datasets.append(part1_legend)

    part2_legend = DataSet('part2', title = 'Part2 (blue)', key_color = '#0000FF')
    app2.datasets.append(part2_legend)

    return part1_legend, part2_legend 

def add_markers_from_df(non_legend, part_legend, df):
    '''
    Extract and apply latitude and longitude columns from df.

    (df) -> appropriate columns

    add_marker(lat,long,title,color,text)

    where color = hexadecimal code without hashtags
    title and text must be strings 
    title shows on mouseover, text shows on click
    note that df.itertuples treats the index column as column zero 

     '''

    for row in df.itertuples():
        temp = row
        part1_legend.add_marker([temp[1], temp[2]],title=temp[4], color=temp[5], text=temp[3])

df = pandas.read_csv("my_data.csv")
add_points_from_df(df)
pt = [33.0000, -117.0000]
mymap.build_page(center=pt, zoom=10, outfile="map_test.html")
```




  [1]: https://pypi.python.org/pypi/pygmaps/0.1.1
  [2]: https://github.com/Permafacture/pygmaps-ng
  [3]: http://www.boutell.com/zipcodes/
  [4]: http://www.w3schools.com/sql/sql_join.asp
  [5]: http://samzeitlin.com/Sam%20Zeitlin%20Publications.html
  [6]: http://www.color-hex.com/color-palettes/
  [7]: http://web.stanford.edu/~mwaskom/software/seaborn/tutorial/color_palettes.html?highlight=colorblind
