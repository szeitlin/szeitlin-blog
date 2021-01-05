---
title: "Test Patterns for Data Engineering"
date: 2020-10-13T12:45:27-07:00
draft: true
---

Coming from a background in bench science, or what we affectionately referred to as "wetlab", I like to test everything I do, and I like my tests
to be fast and representative of what I expect to find when I run things "for real". 

Most people I've met who are newer to data engineering find that it's not immediately obvious how to write and run tests for data things. 
It's different enough from writing unit tests for web apps that there are some pitfalls to be aware of. This post is about that. 

#1. What to test and why? 

I've blogged about this [before][1], but that post is more of a 'tips and tricks' post. 
This post is more about the nuts and bolts.   

----

There are several great reasons to write and run automated tests. These are the ones I usually repeat to remind myself and others why it's worth doing:

1) You're already testing when you check your code manually, you're just doing it the slow way. 
2) It's actually faster to automate tests early and often. 
3) Tests require that your code is modular. If you're struggling to write tests, it may mean you
need to simplify your code. 
4) Tests require that you understand how your code actually works. It's a great way to doublecheck your logic and assumptions. 

**Test for these: positive, negative, missing/unknown cases, duplicates** 

When dealing with data, these are the cases I usually try to cover with tests: 

- This thing meets my expectations (test should always succeed). I use these the most with new libraries to make sure I understand how 
they work (it also makes my code easier for other people to understand), 
and for regression tests/ahead of refactoring. 

```python
    import uuid
   
    def make_token_dict():
        """Returns a dictionary with key "token" and a new UUID as its value"""
        test_token = uuid.uuid1()
        return {'token': test_token}

    def test_valid_token_found():
        """Check that the config_dict token object is a valid UUID object"""
        config_dict = make_token_dict()
        token = config_dict.get('token')
        assert isinstance(token, uuid.UUID)
```

- This thing is very wrong (code should always throw an error if this happens)

```python
   def test_missing_token_throws_error(self):
       """We always expect there to be a token in the config_dict"""
       empty_config_dict = dict()
       with self.assertRaises(KeyError):
           empty_config_dict.get('token')
```

- Something is missing or just kind of wrong, but it's handled correctly. To error or just log usually depends on scale: 
sometimes you're better off just logging some types of errors or warnings, rather than actually causing your program 
to stop.

```python
    import logging
    
    def test_optional_thing_missing_does_not_raise_error():
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
        results = count.values()
        assert  list(results) == [1,2]        

    def test_drop_duplicates():
        fake_data = {('a',1), ('b', 2), ('b', 2)}
        count = Counter(fake_data)
        result = set(count.values())
        assert  result == {1} 
```


# Unit tests

*What's a unit test?* 

When I'm talking about unit tests, I'm talking about testing a single method, often using static data, e.g. a hard-coded dictionary. 
All the examples shown above are unit tests. 

*Ok but how do I write one for database operations without a database? what about s3 buckets?*

You don't. For that, you need integration tests. 

# Integration tests

*What's an integration test?*

An integration test bridges across multiple methods, classes, or services. 

```python
    import s3fs
    
    def test_list_my_bucket_years():
        """Using correct credentials, connect to s3 and confirm list of years there"""
        src_bucket = "my_bucket"
        conn = s3fs.S3FileSystem(anon=False, profile_name='my_company')
        years = conn.ls(src_bucket)
        assert years == ['my_bucket/2017',
                         'my_bucket/2018',
                         'my_bucket/2019',
                         'my_bucket/2020']
```

Wherever possible, test on (copies or samples of) actual data. Ideally, if it's for data pipelining, 
your code should be able to pull fresh data and test on that. 

If your code needs to be able to backfill historical data, you should have a reference data set. 
Typically I use files that represent samples of 
data sources, and whenever I update the code, I pull a fresh sample file, and make sure the updated code 
works on the new data and is also still backwards-compatible. 

Things worth testing: 
- configurations to do certain types of operations

- table inserts, joins, updates

- logic that spans more than 1 operation (sequences of operations)

## How to do it

### There are several options. Here are some common ones:
 
**1. Make a whole test database, i.e. a copy of your real database.** 

**Pro:** You can insert and change data without worrying about messing up your real data.

**Cons:** Have to automate keeping the copy up to date, and/or 
you may end up with extra code to keep schema consistent with your real database. 
It can also get expensive if your database is big, so you'll probably want to only have samples, rather than full tables. 

**2. Set up a lightweight local database that’s sorta similar in dialect, e.g. sqlite, maybe in a docker container.**

**Pro:** You can insert and change data without worrying about messing up your real data. This is the approach
used most commonly with ORM frameworks like Django. You might want to check out something like [testcontainers][2] 
for dockerized versions of some commonly-used databases.

**Cons:** same as (1), plus it can take a while to populate, if your database gets big, plus dialect differences
can lead to confusion. 

**3. If it’s a table, just mock it with a file or pandas.**

**Pro:** This works nicely for things that fit in memory, and I do it a lot for non-SQL things. 

**Cons:** You may have to replace the file, or add additional files, if the table changes a lot. 

**4. Make an actual test table in a real database, do some stuff, and then delete it (setup and teardown)**

**Pro:** This is my preferred method for working with large databases. It's the closest you'll get to testing 
in a setup that mimics what will happen when you do it for real. 

**Cons:** It can take some finagling to set up credentials etc. the first time, and you may not be allowed to do it
depending on your CICD system. It can also make your tests take longer to run. 

**5. Make a whole test cluster (for e.g. airflow or pachyderm)**

**Pro:** As with having a test database, it means you can muck around with abandon and feel pretty confident that you 
won't break anything too important. 

**Cons:** Same as for a test database, it's another thing you have to set up and maintain. It's easy for the test cluster to 
fall behind the real one, if you don't have everything automated so it's easy to apply changes to both 'test' and 'prod'. 
It can also get expensive. 

_What’s good about mocks:_

Not much, in my experience. But it can be better than nothing. 
A mock will, at a minimum, fulfill the purpose of forcing you to doublecheck your logic, 
at least while you’re writing the test. 

_What’s bad about mocks:_

Testing with a mock is usually an exercise in redundantly creating extra work and checking nothing useful. 
It won’t be automatically updated if the dependencies or deployment environment(s) change. 
And those are the things that usually break. 

Take-home points:

- If you're doing anything at scale, you're usually running a distributed database in the cloud, 
which means you can’t always run a copy of your database locally like you can with Postgres or MySQL.

- Permissions & security considerations can be major blockers for running real integration tests in CICD systems. 
It can be risky to give your test environment access to your production databases. 
If you're going to do this, it's best to 
have your tests use a separate namespace or create their own tables. 

- If you're running in the cloud on a real database, costs can add up, 
especially if your tests are going to run on a lot of data, or very frequently. 

# Testing ETL

These days, batch and streaming ETL generally have the same steps, it's only the batch size that differs. 
Ingest the data ('Extract'), do something to it ('Transform'), write it back out ('Load'). 

So how it testing ETL different from other kinds of testing?

ETL testing is sort of like any other kind of integration testing, except that it generally has to always run in the same order. 

1. **Simplify, simplify, simplify.**

    *If you need to mock your ETL in order to test it, it's too complicated.* 
    
    You can mock the database, and you may have to, but don't use mocks to test the actual steps. 

2. **Test at the interfaces.** 
    
    Test the data going in and out of each step. 
    
    Usually you'll want an assert making sure your raw data looks as expected, before you do anything to it. 
    Then you run your code, and assert that it looks the way you want. 
    
3. **Test obvious things.**

    Are my columns in the right order? Are they the right data type? 
    Did we get the right number of rows back out? 
    Are we handling nulls correctly? 
    Is everything formatted correctly at the end?
    
# Regression tests

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

---
Thanks to Adam Laiacano and Deron Aucoin for helpful comments on the first draft of this post. 



[1]: https://szeitlin.github.io/posts/engineering/test-driven-data-pipelining/
[2]: https://github.com/testcontainers/testcontainers-python
