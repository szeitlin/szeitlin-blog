---
title: "Test-driven data pipelining"
draft: false
date: 2016-02-08
tags: ["pandas", "testing", "python"]
author: Samantha G. Zeitlin
---


## When to test, and why:

• Write a test for every method. 

• Write a test any time you find a bug! Then make sure the test passes after you fix the bug. 

• Think of tests as showing how your code should be used, and write them accordingly. The next person who's going to 
edit your code, or even just use your code, should be able to refer to your tests to see what's happening. 

• Think of tests as the way you'll make sure things don't break later when you have to refactor.

• It's perfectly okay to write the name of the test first, and then figure out how to write the rest later. In fact, sometimes it helps to write the test so that you know it will fail, and then use that to write better code. That's *test-driven development*. 

```python
    def test_whether_examples_return_likes(self):
        pass 
```        

• **Give your test a MEANINGFUL name.**

The name should say exactly what the expected behavior is. 

```python
    def test_savings_meets_minimum_requirement(self):
        savings.pct = calculate_savings()
        self.assertGreater(savings.pct, 5)
```

• **Tests should be independent of each other.**

If you're thinking about writing a test, first check whether a similar test already exists. Don't duplicate existing tests, because that can create confusion when looking at how many tests fail (creating the impression that things are more broken than they actually are).

## What to Test

• **Start with user stories**. What do they expect to see? Test for that.

```python
        def test_user_visits_landing_page(self): 
    	    self.assertIn(title, landing_page)
```

• Confirm expected data types

```python
	def test_answer_dict_creation(self):
            named = answer_dict()
    	    self.assertTrue(isinstance(named, dict))
```

• Confirm expected attributes on objects

```python
	def test_profile1_has_no_names(self):
            self.assertEqual(len(profile1.names), 0)
    
        def test_profile2_has_three_names(self):
            self.assertEqual(len(profile2.names), 3)
```

• **Features** you haven't finished writing yet (Test-Driven Development)

```python
	def test_user_horoscope_is_accurate(self):
            prediction = None
            self.assertEqual(reality, prediction)
        
```

It's okay (and faster) to group assertions together in one test if they all refer to the same object:

```python
    for name, lookup in get_answers(question):
        self.assertTrue(isinstance(name, str))
        self.assertTrue(isinstance(lookup, dict))
        self.assertTrue(isinstance(lookup[name], pd.DataFrame))
        self.assertIn('answer_name', lookup[name].columns)
```            

• **Test pipelines** sequentially and swap in positive controls for all variables except the one you're testing. Then in the final tests, test the whole pipeline and use only test data. You might want to do this for more complicated features. It ends up looking something like this:

```python
	def test_query_returns_objects(self):
            actual_obj_list = query()
            self.assertEqual(set(expected_obj_list), set(actual_obj_list))
    
        def test_make_dataframes_from_query_objects(self):
            expected_obj_list = query()
            query_obj_dataframe= pd.DataFrame.from_records(expected_obj_list.values())
            self.assertTrue(isinstance(query_obj_dataframe, pd.Dataframe))
   
        def test_query_returns_objects_and_makes_dataframes(self):
            actual_obj_list = query()
            query_obj_dataframe= pd.DataFrame.from_records(actual_obj_list.values())
            self.assertTrue(isinstance(query_obj_dataframe, pd.Dataframe))
            self.assertIn('total success', query_obj_dataframe.columns)
```

•**Write tests for how to handle expected obstacles and failures**

Write tests for things like "test_data_cleaning" and "test_handle_missing_values". Don't expect to rely on inserting a debugger every time something breaks. If the same piece of code breaks more than once, you've already wasted time by not writing a test. 

**Don't**

• Don't test too many things in one test, unless you have sufficient coverage of all the supporting parts. The whole point of unittests is to help isolate the causes of problems, particularly when you change things later, i.e. to help speed up refactoring and adding new features. 

• Don't write useless tests. If the test fails and tells you nothing about why it failed, you did it wrong. 

• It's generally considered poor form to put assertions in main code. Assertions are best used in testing. If you want to check for something in the code, use an if statement. However, if a condition is expected to only occur if something has gone horribly wrong, you should raise a custom exception. This can be tremendously helpful for debugging, for example, if database queries are failing. 


Don't do this:
```python
    def assertNoErrors(self, resp, msg=''):
        return self.assertEqual(len(resp['messages']['error']), 0, msg)
```        

Better:
```python
    def assertNoErrors(self, resp, msg=''):
    	try:
	    self.assertEqual(len(resp['messages']['error']), 0)
        except AssertionError:
            return resp['messages']['error'] 
            
```

**Running tests**

 1. Run tests locally. Whether you're just running unit tests, or django tests, or using some other library (nose, pytest, etc.), you can run single tests, whole test folders or the entire test suite. 
 2. Set up and run automated tests through something like Jenkins. Keep in mind that Jenkins may not be using the same database that you're using locally. 
 3. Test manually both locally and remotely. 
 4. Get someone else to test manually both specifically (black-box testing) and randomly (smoke-testing). 
