---
title: "Things I learned about zip files"
draft: false
date: 2015-01-15
tags: ["unix", "python", "zip"]
author: Samantha G. Zeitlin
---


In an effort to advance my python skills, I spent some time slowly pecking away at [the puzzles on pythonchallenge][1]. I got stuck on most of the challenges, and either had to search for a hint, or ask for help from a friend, or both. This latest one was particularly instructive, and it had to do with zipfiles. 

I thought I knew what zip files were. I have used them since grad school, for transferring folders via email, and for compression. I used various utilities and command-line tools to deal with zipping and unzipping. But I never needed to know how they worked. 

Then I got stuck for a while because I was looking specifically for a pythonic solution for zip files. 


----------


**Things I Learned and How I Learned Them**


----------


**1. Pydoc != online documentation for some libraries**

For some python modules, the docstrings are great, and save you the work of having to hunt for the right version of the online documentation. Sometimes the docstrings are actually even better than the docs. 

If you do this:

    pydoc zipfile.is_zipfile

You'll get this:

    zipfile.is_zipfile= is_zipfile(filename)
    Quickly see if a file is a ZIP file by checking the magic number.
    
    The filename argument may be a file or file-like object too


----------


I had gotten out of the habit of checking docstrings, because sometimes the docstrings are nonexistent, and then your best bet is to: 

 1. Ask google 
 2. Find the source code, and hope it's really easy to
    understand
 3. Ask friends if they know, or if they can recommend something more usable

 
----------


 **2. Sometimes wikipedia fills in all the stuff the documentation skipped over.** 
 
Some things [I needed to know][2] were actually easier to find out about on wikipedia. 

I did not know that there is such a thing as a [magic number][3], and that the one for ZIP actually spells out PK, for Phil Katz, the author of PKZIP. 


----------


**3. It’s not actually cheating to use unix tricks.** 

The command “file” will give you information about the filetype. So if you download something and you’re not sure what it is, or you just want to verify that it's what you thought it should be (say, before you decompress it), try this first. 

    file myfile.zip

returns something like this:

    myfile.zip: Zip archive data, at least v2.0 to extract


----------


A friend recommended this nice tool called [xxd][4], which gives you a hex dump of a file (even on Mac OSX!). 

This can be useful if you suspect there is text hidden in a file that is otherwise only binary or not human-readable. 


----------


**4. Some older modules haven’t been updated in a long time.** 

The zip file format was invented ~20 years ago (1993), which means it doesn’t contain a way to work with these chunks of data in memory. So you have to save the whole thing to a file in order to do anything. 

It turns out that *file-like objects* can be a pretty vague way to describe what kind of input a method can handle. And the error messages don't say what I really needed to hear, which was something like: 

*Please stop trying to give me a urllib2 response, I only eat files!* 


----------


Also, unlike more modern Python modules, there were not any examples of how to use the methods. So eventually I figured out that all I had to do was this: 

```python
    import urllib2
    import zipfile

    #do what you normally do with a webpage
    response = urllib2.urlopen("http://target_URL.zip")
    body = response.read()

    #write it to a file, or you'll be screwed 
    with open("target.zip", 'wb') as myfile:
        myfile.write(body)

    #confirm that it's actually a zip file
    print zipfile.is_zipfile("channel.zip")

    #create a zip file object instance, so you can use the zipfile class methods
    myfile = zipfile.ZipFile("channel.zip")

```
----------
 **5. Code Review.** 

After reading the original version of this post, one friend commented that I should I should do it [his way][5], with StringIO. 

Another friend emailed me this code block, which actually answered my original question about how to do it in-memory. As usual, the real lesson here is, if you don't know the name of something, it's hard to know how to look it up. 

```python
  import io
  import sys
  import urllib2
  import zipfile

  if __name__ == '__main__':
    zip_url = "http://somefile.zip"

    response = urllib2.urlopen(zip_url)
    body = response.read()

    byte_buffer = io.BytesIO(body)

    myfile = zipfile.ZipFile(byte_buffer)

    print myfile
    print zipfile.is_zipfile(byte_buffer)

```

  [1]: http://pythonchallenge.com
  [2]: https://en.wikipedia.org/wiki/Zip_(file_format)#Structure
  [3]: https://en.wikipedia.org/wiki/Magic_number_(programming)
  [4]: http://linux.die.net/man/1/xxd
  [5]: https://gist.github.com/ods94065/e8bb54570d170e97b19b
