---
title: "Test Patterns for Data Engineering"
date: 2020-10-13T12:45:27-07:00
draft: true
---

Coming from a background in bench science, or what we affectionately referred to as "wetlab", I like to test everything I do, and I like my tests
to be fast and representative of what I expect to find when I run things "for real". 

Most people I've met who are newer to data engineering find that it's not immediately obvious how to write and run tests for data things. 
This post is about that. 

#1. What to test and why? 

I've blogged about this [before][1], but that post is more of a 'tips and tricks' post. This post is more about the nuts the bolts.   

----

There are several great reasons to write and run automated tests. These are the ones I usually repeat to remind myself and others why it's worth doing:

1) You're already testing when you check your code manually, you're just doing it the slow way. 
2) In that sense, it's actually faster to automate tests early and often. 
3) Tests require that your code is modular and, well, testable. If you're struggling to write tests, it might mean
you need to simplify your code. 
4) Tests require that you understand how your code actually works. It's a great way to doublecheck your logic and assumptions. 

**Test for these: positive, negative, missing/unknown cases, duplicates** 

When dealing with data, these are the cases I usually try to cover with tests: 

- This thing meets my expectations (test should always succeed)

```python
   def test_valid_token_found():
       config_dict = {'token': 'asdflkj348sak'}
       token = config_dict.get('token')
       assert isinstance(token, str)
```

- This thing is very wrong (code should always throw an error if this happens)

```python
   def test_invalid_token_throws_error(self):
       empty_config_dict = dict()
       with self.assertRaises(KeyError):
           empty_config_dict.get('token')
```

- Something is missing or just kind of wrong, but it's handled correctly (to error or just log usually depends on scale) 

```python
    import logging
    
    def test_optional_thing_missing():
        fake_data = {'a':1, 'b':2, 'd':4}
        results = fake_data.get('c',3)
        logging.warning("key 'c' was missing")
        assert results == 3
```

- Check that code handles duplicates the way you want

```python
    
    from collections import Counter
    
    def test_keep_duplicates():
        fake_data_list = [('a',1), ('b', 2), ('b', 2)]
        count = Counter(fake_data_list)
        assert set(count.values()) == {1,2}        

    def test_drop_duplicates():
        fake_data = {('a',1), ('b', 2), ('b', 2)}
        count = Counter(fake_data)
        assert set(count.values()) == {1} 
```

*Note: Sometimes at scale you're better off just logging some types of errors or warnings, rather than actually causing your program 
to stop.* 


# Unit tests

*What's a unit test?* 

When I'm talking about unit tests, I'm talking about testing a single method, often using static data, e.g. a hard-coded dictionary. 
All the examples shown above are unit tests. 

*Ok but how do I write one for database operations without a database? what about s3 buckets?*

You don't. For that, you need integration tests. 

# Integration tests

*What's an integration test?*

An integration test bridges across multiple methods, classes, or services. 

<todo: add example here>

Wherever possible, test on (copies or samples of) actual data. Ideally, if it's for data pipelining, 
your code should be able to pull fresh data and test on that. 

If your code needs to be able to backfill
historical data, you should have a reference data set. Typically I use files that represent samples of 
data sources, and whenever I update the code, I pull a fresh sample file, and make sure the updated code 
works on the new data and is also still backwards-compatible. 

Things worth testing: 
- configurations to do certain types of operations

<todo: add example here>

- table inserts, joins, updates

<todo: add example here>

- logic that spans more than 1 operation (sequences of operations)

<todo: add example here>

## How to do it

### There are several options. Here are some common ones:
 
1. Make a whole “mock” database, maybe in a docker container

<todo: add example here>

2. Set up some other database that’s sorta similar in dialect, e.g. sqlite, maybe in a docker container 

<todo: add example here>

3. If it’s a table, sometimes just mock it with a file or pandas

<todo: add example here>

4. Make an actual test table in a real database, do some stuff, and then delete it (setup and teardown)

<todo: add example here>

5. Make a whole test cluster (for e.g. airflow or pachyderm)

<todo: add example here>

_What’s good about mocks:_

Not much, in my experience. But it can be better than nothing. 
A mock will, at a minimum, fulfill the purpose of forcing you to doublecheck your logic, at least while you’re writing the test. 

_What’s bad about mocks:_

Testing with a mock is usually an exercise in redundantly creating extra work and checking nothing useful. 
It won’t be automatically updated if the dependencies or deployment environment(s) change. And those are the things that usually break. 

Other considerations:

- If you're doing anything at scale, you're usually running a distributed database in the cloud, which means you can’t always run a mock database 
locally like you can with postgres or mysql

- Permissions & security considerations can be major blockers for running real integration tests in CICD systems. 
It can be risky to give your test environment access to your production databases. If you're going to do this, it's best to 
have your tests use a separate namespace or create their own tables. 

- If you're running in the cloud on a real database, costs can add up, 
especially if your tests are going to run on a lot of data, or very frequently. 

#Regression tests

So you’ve finally got your stuff working. Congratulations! 

*How do I make sure nobody (including Future Me) accidentally breaks it?* 

You can't. Stuff will break. 

What kinds of things usually cause stuff to break?

- Changes to assumptions you made that were ‘temporary’
- Missing/renamed/swapped parameters
- Deprecations in your dependencies
- Unannounced changes from upstream (also known as, "whoops we forgot to tell the data team")
- Major shifts from baseline
- Slow data drift


[1]: https://szeitlin.github.io/posts/engineering/test-driven-data-pipelining/