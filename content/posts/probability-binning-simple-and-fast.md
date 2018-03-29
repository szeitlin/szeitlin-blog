Recently, I've done a few data science coding challenges for job interviews. My favorite ones included a data set and asked me to address both specific and open-ended questions about that data set. 

One of the first things I usually do is make a bunch of histograms. Histograms are great because it's an easy way to look at the distribution of data without having to plot every single point, or get distracted by a lot of noise. 

**How traditional histograms work:** 

A histogram is just a plot with the number of counts per value, where the values are divided into equally-sized bins. In the traditional histogram, the bins are always the same width along the x-axis (along the range of the values). More bins means better resolution. Fewer bins can simplify the representation of a data set, for example if you want to do clustering or classification into a few representative groups. 

**A histogram with ten bins:**

![Screen Shot 2016-11-03 at 11.08.45 AM.png](/site_media/media/2bbce00ca1f11.png)

**The same data with 3 bins:**

![Screen Shot 2016-11-03 at 11.08.52 AM.png](/site_media/media/31efd826a1f11.png)

**Original implementation:** 

First, I used matplotlib to get the bin ranges, because that was easy. Then I applied those as masks on my original dataframe, to convert the data into categories based on the bin ranges. 

[code lang="python"]
    def feature_splitter(df, column, bins=3):
        """
        Convert continuous variables into categorical for classification.
        :param df: pandas dataframe to use
        :param column: str
        :param bins: number of bins to use, or list of boundaries if bins should be different sizes
        :return: counts (np.array), bin_ranges (np.array), histogram chart (display)
        """
        counts, bin_ranges, histogram = plt.hist(df[column], bins=bins)

        return counts, bin_ranges, histogram

    def apply_bins_as_masks(df, column, bin_ranges):
        """
        Use bin_ranges to create categorical column

        Assumes 3 bins

        :param df: pandas dataframe as reference and target
        :param column: reference column (name will be used to create new one)
        :param bin_ranges: np.array with ranges, has 1 more number than bins
        :return: modified pandas dataframe with categorical column
        """

        low = (df[column] >= bin_ranges[0]) & (df[column] < bin_ranges[1])
        med = (df[column] >= bin_ranges[1]) & (df[column] < bin_ranges[2])
        high = (df[column] >= bin_ranges[2])

        masks = [low, med, high]

        for i, mask in enumerate(masks):
            df.loc[mask, (column + '_cat')] = i

        return df

[/code]

This worked well enough for a first attempt, but the bins using a traditional histogram didn't always make sense for my purposes, and I was assuming that I'd always be masking with 3 bin ranges. 
 


----------


Then I remembered that there's [a different way][1] to do it: choose bin ranges by equalizing the number of events per bin. This means the bin widths might be different, but the height is approximately the same. This is great if you have otherwise really unbalanced classes, like in this extremely simplified example, where a traditional histogram really doesn't always do the best job of capturing the distribution: 

![Screen Shot 2016-10-24 at 10.08.35 AM.png](/site_media/media/353f269ca2201.png)

**When to use probability binning:** 

Use probability binning when you want a small number of approximately equal classes, defined in a way that makes sense, e.g. combine adjacent bins if they're similar. 

It's a way to convert a numeric, non-continuous variable into categories. 

For example, let's say you're looking at user data where every row is a separate user. The values of specific column, say "Total clicks" might be numeric, but the users are independent of each other. In this case, what you really want to do is identify categories of users based on their number of clicks. This isn't continuous in the same way as a column that consists of a time series of measurements from a single user. 

I used to do this by hand/by eye, which is fine if you don't need to do it very often. But this is a tool that I've found extremely useful, so I wanted to turn it into a reusable module that I could easily import into any project and apply to any column. 

[The code I wrote is here][2]

**The actual process of getting there looked like this:** 

*Step 1:* create an inverted index

*Step 2:* write tests and make sure that's working

*Step 3:* use plots to verify if it was working as expected (and for comparison with original implementation)

For the simple case yes, but on further testing realized I had to combine bins if there were too many or they were too close together.

*Step 4:* combine bins 

*Step 5:* use the bin ranges to mask the original dataframe and assign category labels

[code lang="python"]
    def bin_masker(self):
        """
        Use bin_ranges from probability binning to create categorical column

        Should work for any number of bins > 0

        :param self.df: pandas dataframe as reference and target
        :param self.feature: reference column name (str) - will be used to create new one
        :param self.bin_ranges: sorted list of new bins, as bin ranges [min,   max]
        :return: modified pandas dataframe with categorical column
        """
        masks = []

        for item in self.bin_ranges:
            mask = (self.df[self.feature] >= item[0]) & (self.df[self.feature] < item[1])
            masks.append(mask)

        for i, mask in enumerate(masks):
            self.df.loc[mask, (self.feature + '_cat')] = i
            self.df[self.feature + '_cat'].fillna(0, inplace=True) #get the bottom category
[/code]

*Step 6:* try it in the machine learning application of my choice (a decision tree - this will go in a separate post). Check the accuracy score on the train-test-split (0.999, looks good enough to me). 
 
*Step 7:* write more tests, refactor into OOP, write more tests. 

*Step 8:* Add type hints and switch to using a public data set and pytest. Fix some stupid bugs. Write this blog post. Start preparing a package to upload to pypi for easier portability. 





  [1]: http://onlinelibrary.wiley.com/doi/10.1002/1097-0320(20010901)45:1%3C37::AID-CYTO1142%3E3.0.CO;2-E/full
  [2]: https://github.com/szeitlin/probability_binning/blob/master/probabinerator.py