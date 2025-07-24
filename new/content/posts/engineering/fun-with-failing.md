
---
title: "Fun with text file encodings"
draft: false
author: Samantha G. Zeitlin
---


This post is about a couple of painful problems I've had with reading in text files. 

They're just text files, right? What could be hard about that? 


----------


**1. Fun with encoding**
------------------------

The problem: 

A friend sent me a dump of data from iTunes, as a table. 

*Just a text file.* 

She's on a Mac. I'm on a Mac. But when I went to read in the file, Python choked in a way I hadn't seen before. 

I tried everything I knew how to do. I tried adding options in pandas that had worked for me in the past with various kinds of tables and csv files, but none of it worked. I couldn't figure out what was wrong.

So I was doing: 

```python
    import pandas
    data = pandas.read_csv("Rawfile.txt", sep='\t')

```

And I was getting a giant mess of stuff like this:

    [\rTest Pattern #1111\t`l0u\xaeN\xf8S', '\tTest Pattern\t\tTechnical Electronic\t13149337\t432\t\t\t15\t\t2008\t9/15/08, 5:47 PM\t8/22/11, 6:37 PM\t242\t44100\t\tMPEG audio file\t\t\t\t\t\t\t\rTest Pattern #0000\t`l0u\xaeN\xf8S']

After banging my head against the wall for a while, I learned a few things. Here's what I learned. 

**Step 1**. Open the file in an old-school text editor. Newer ones, unfortunately, are too smart, and will not show you what you need to see. For example, use this command to view the file with no automatic conversion at all:

    vim -b Rawfile.txt

**Step 2**. Look at the top of the file. 

In my case, there was this [byte order marker][1] (BOM): 

> {ff}{fe} (*)

 

It turns out that UTF-8, the usual format for text files, doesn't have a BOM. This BOM happens to correspond to UTF-16. Pandas couldn't deal with that. 

NOTE: a friend wrote in and suggested this even better unix solution:

    >>> file myfile.txt
    Little-endian UTF-16 Unicode English text, with CR line terminators


----------


**Solution:** 

To get this file imported, then, I had to first read it in using the Python module called 'codecs'. And I had to add the argument for the universal end-of-line, like so, or it wouldn't read it as a table:

```python
    import codecs

    opened = codecs.open("All_iPod_Music_Cleaned_Up_031114.txt", 'rU', 'UTF16')

    df = pandas.read_csv(opened, sep='\t')
```

----------


2. Fun with invisible ink
-------------------------

Lesson learned: (NOTE TO SELF): *check your input file!* 

The problem: 

I wanted to try a simple twitter stream analysis. I got my API key, got a few tweets, and wrote the data to a file. It comes out in json form. 

I haven't done much with json. So when I started having problems, I assumed I was doing something wrong. 

I tried json.loads. Eventually, I was able to confirm that I was getting back the right kind of object (a Python dict), but I was also getting this error:

    raise ValueError("No JSON object could be decoded")

How was that possible? It was decoding but it was not decoding? 

I re-read the json module docs and tutorial, but it didn't help. 

I wondered if the json object had extra text at the end, so I tried the raw_decoder instead, but that gave me a different error (it was expecting a string, not a file). 


----------


What saved me? The same vim trick. 

    vim -b input_file.txt

This revealed a very sneaky problem. Somehow I had an extra carriage return in my test file, probably because I had manually copied and pasted two json objects from a much larger file. 

In vim, there should be a tilde (~) after the last line. Vim also shows you the number of lines at the bottom of the screen. In my case, it should have said '2L'. Instead, it said '3L'.

That ValueError? *An empty line*. 

I also learned another, better trick for checking from the command line in unix:

    wc -l input_file.txt   #wordcount, plus the option for number of lines. 

For future projects, adding "if not line: continue" may help. 


----------


(*) note: these were actually angled brackets, but because codrspace uses markdown, I converted them to curly brackets. 

  [1]: http://en.wikipedia.org/wiki/Byte_order_mark
