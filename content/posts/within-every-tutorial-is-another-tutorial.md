Things I learned while following [this tutorial][1] on how to build reusable models with scikit-learn. 

 1. When in doubt, go back to pandas. 
 2. When in doubt, write tests. 
 3. When in doubt, write helper methods to wrap existing objects, rather than creating new objects. 


----------
## Ingesting "clean" data is easy, right? ##

Step 1 of this tutorial began with downloading data using [requests][2], and saving that to a csv file. So I did that. I've used requests before, I had no reason to think it wouldn't work. It looked like it worked.

Step 2 was to read the file into pandas. I've read lots of csv files into pandas before, so I had no reason to think it wouldn't work. 

It [didn't work][3]. 

I double-checked that I had followed the instructions correctly, and then checked a few more times before concluding that something was not quite right about the data. 

I went back and did the easy thing, just printing out the response from requests. 

After some digging, I figured out that `response.content` is not the same as `response.text`. 

The tutorial said to use `response.content`, but `response.text` seemed to have actually parsed the strings.

Even with that fix, pandas was refusing to read in more than the first row of data, due to a couple of problems: 

 - pandas wasn't finding the line terminators (nothing special, just `'\n'`)
 - pandas wasn't finding equal numbers of items per row

Unexpectedly, when I went back to what I usually do, just plain old `pandas.read_csv`, this time going directly from the url, and including the column names, that actually worked. 

So it was actually better, and a lot less code, to completely skip using `requests`. 

----------
## Testing always gets me unstuck ##

I really liked the end-to-end structure of this tutorial, and was frankly embarrassed that I had so much trouble getting the initial ingestion to work. 

I liked that the tutorial gave me an excuse to walk through how the author actually uses scikit-learn models in production. With the data firmly in hand, the data visualization steps were easy - they worked as advertised, and anyway I'm very familiar with using `seaborn` to make charts in python. 

I had never created a Bunch object before, so that was new for me. That seemed to work, but then the next steps again failed, and I had to back up a few steps. 

I wasn't sure what the problem was, so I did what I always do with complicated problems, and wrote some [tests][4] to rule out user error and make sure I understood what the code was doing. That helped a lot, and identified what was actually broken. 

The problem: how to apply `LabelEncoder` to help convert categorical data, and `Imputer` to help fill missing data, to multiple columns. 

Because the idea was to do this in the context of a `Pipeline` object, the author demonstrated how to create our own Encoder and Imputer objects, with multiple inheritance. I understand the goal of this: take advantage of the nice clean syntax you get from making a Pipeline. But it was failing at the `fit_transform` step, and it wasn't obvious why. 

The `fit()` and `transform()` steps both seemed to be working individually and sequentially, and it wasn't easy to figure out how the `fit_transform` step was supposed to do anything more than chain them together. 

After banging my head on this at the end of a long day, even going back to the original scikit-learn source code in an effort to design tests to help me figure out what was wrong, I decided to sleep on it. 


----------
## Simple and working is better than complicated and broken ##

I seriously considered writing tests for our custom Encoder and Imputer objects, but then it dawned on me that I really didn't need to do that. I decided that the Pipeline functionality was so simple that I didn't really need it, so I just stripped the objects down into [simple functions][5] to run the `fit` and `transform` steps, which was really all I needed anyway. 

That got me through the rest of the steps, so I could practice pickling a model and re-loading it, which seemed to work just fine. 

I don't know if the scikit-learn folks have plans to extend these methods, or if everyone normally does these kinds of acrobatics to encode and impute on multiple columns - normally I would just use pandas for that, too. 


  [1]: http://blog.districtdatalabs.com/building-a-classifier-from-census-data/
  [2]: http://requests.readthedocs.io/en/master/
  [3]: https://github.com/szeitlin/labor-force/blob/master/data/0912_2016_census_from_UCI.ipynb
  [4]: https://github.com/szeitlin/labor-force/blob/master/test_create_bunch.py
  [5]: https://github.com/szeitlin/labor-force/blob/master/sklearn_categorical.py