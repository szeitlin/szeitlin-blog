---
title: "Data pipelining with pandas"
draft: false
date: 2016-01-02
tags: ["pandas", "python"]
author: Samantha G. Zeitlin
---


For better or worse, when you're dealing with data pipelines of varying shapes and sizes, sometimes you need to combine objects that don't match up evenly. 

For example, if you want to apply a condition via lookup, sometimes it makes sense to just do a merge. This creates a new column in your data table, and then you can use that for reference. 

This is an extremely simple example to show what I mean: 

```python
    import pandas
    table = pandas.DataFrame({'Existing Column':['apples', 'oranges']})
```

![Screen Shot 2016-01-02 at 7.51.21 PM.png](/site_media/media/580ab176b1cd1.png)


    `reference_table = pandas.DataFrame({'Reference Column':['apples', 'lemons']})`


![Screen Shot 2016-01-02 at 7.52.29 PM.png](/site_media/media/777ea54eb1cd1.png)



    `merge = pandas.concat([table,reference_table], axis=1)`

![Screen Shot 2016-01-02 at 7.53.22 PM.png](/site_media/media/9c799854b1cd1.png)


    `merge['Result Column'] = merge['Existing Column'] == merge['Reference Column']`

![Screen Shot 2016-01-02 at 7.54.37 PM.png](/site_media/media/bf4f535ab1cd1.png)


----------


That works fine, especially if you don't need to do a complicated merge. 

However, if your problem meets the following criteria, you might be stuck looking for a better solution:

 - If you have a list of several conditions, each of which is only expected to apply to a small subset of rows in your table
 - If the list of conditions may vary in length, and you don't know in advance how long it will be
 - If you don't want to deal with NaNs, which tends to be a problem if your reference table is much smaller than your target table
 - If you don't want to worry about dropping column names each time you go through the loop, which tends to be a problem if you have any duplicate column names being created during the merge (and if any of the dropping fails, you end up with 'col_x_x' and 'col_x_y', etc. And that's, ugh, in my opinion, best avoided)
 - Your data set isn't too huge
 - You don't mind if the process isn't the fastest, because accuracy matters more for your purposes


Then you might want to try this solution.


----------


The general structure looks like this:

 **Step 1. Create list of masks**

Iterate through your reference material to create masks. The mask is how you apply the conditional logic to a whole dataframe at once. It's sort of like a filter. 

**Step 2. Apply masks**

Iterate through the masks, applying each one to your target dataframe. Keep in mind that if your masks are not unique in all aspects, unless you build in extra checks, you might risk overwriting some values, if there are any overlaps. This approach worked for my purposes because I knew that all the masks were unique by definition. 

I also recommend that you write and run tests for these methods, to make sure the masks match what you expect, and that all the masks were applied as expected. You also might want to test to make sure there are no NaNs at the end, if you care about that sort of thing, in case your masks don't fill all the rows in all the columns. 


```python
    def create_masks(reference_df, target_df):
        """" Apply conditional logic to create masks and append them to a list for use later """

        listofmasks = []

        for x in reference_df.index:
             #simple example, you can chain other set logic here as needed
    
             mask = (target_df['ref_col'] == reference_df.loc[x, 'ref_col']) 
             listofmasks.append(x, mask)

        return listofmasks


   def apply_masks(reference_df, target_df, listofmasks):
       """ Use conditional logic to update target dataframe """

       for x, mask in listofmasks:
    
         #make sure something matches your criteria 
         if target_df[mask].shape[0] > 0:    

        
            second_mask = (target_df['ref_col2'] > reference_df.loc[x, 'ref_col3']):  

            both_masks = mask & second_mask
        
            result = reference_df.loc[x, ‘result_col’]

            # finally, update the appropriate rows in the dataframe 
            #np.where (here, if this, else fill) is fine if you're not iterating

            #If iterating, use masks again, otherwise you risk overwriting 
            target_df.loc[both_masks,'target_col']= result

        return target_df
```


Obviously, you might not want to always update the same column, so I actually combined this with dynamic naming. 
To do that, I created and added a name to each tuple that contains the masks. 
That way, the name also gets passed into the method, 
so it's available when the mask is applied, so I can create new columns or update existing ones as appropriate. 
