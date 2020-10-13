---
title: "Test Patterns for Data Engineering"
date: 2020-10-13T12:45:27-07:00
draft: true
---

Coming from a background in bench science, or what we affectionately referred to as "wetlab", I like to test everything I do, and I like my tests
to be fast and representative of what I expect to find when I run things "for real". 

Most people I've met who are newer to data engineering find that it's not immediately obvious how to write and run tests for data things. 
This post is about that. 

#1. What to test? 

todo: #I think I blogged about this before? 

**Test at least three: positive, negative, missing/unknown cases** 

When dealing with data, these are the cases I usually try to cover with tests: 

- thing meets my expectations (test should always succeed)
- thing is very wrong (code should always throw an error)
- thing is missing or just kind of wrong (to error or just log usually depends on scale) #todo: figure out how to do a footnote with md
- often: also check that code handles duplicates gracefully

footnote: Sometimes at scale you're better off just logging some types of errors or warnings, rather than actually causing your program 
to stop. 


# Unit tests
<todo: what’s a unit test>
Usually, testing a single method

Often using static data, e.g. an example file. 

ok but how do I write one for database operations without a database? what about s3 buckets?

# Integration tests
<todo: what’s an integration test>

Wherever possible, test on actual data. Ideally, pull fresh data and test on that. 

Things worth testing: 
- configurations to do certain types of operations
- table inserts, joins, updates
- logic that spans more than 1 operation (sequences of operations)

## How to do it:

There are several options. Here are some common ones:
 
1. Make a whole “mock” database, maybe in a docker container
2. Set up some other database that’s sorta similar in dialect, e.g. sqlite, maybe in a docker container 
3. If it’s a table, sometimes just mock it with a file or pandas
4. Make an actual test table in a real database, do some stuff, and then delete it (setup and teardown)
5. Make a whole test cluster (for e.g. airflow or pachyderm)

_What’s good about mocks:_

Not much, in my experience. But it can be better than nothing. 
A mock will, at a minimum, fulfill the purpose of forcing you to doublecheck your logic, at least while you’re writing the test. 

_What’s bad about mocks:_

Testing with a mock is usually an exercise in redundantly creating extra work and checking nothing useful. 
It won’t be automatically updated if the dependencies or deployment environment(s) change. And those are the things that usually break. 

Other considerations:
- If you're doing anything at scale, you're usually running in the cloud, which means you can’t always run a mock db locally like you can with postgres or mysql
- Permissions & security considerations can be major blockers. 
- Cost - especially if these tests are going to run on a lot of data or very frequently

#Regression tests

So you’ve finally got your stuff working, how do you make sure nobody (including Future You) accidentally breaks it? 

What kinds of things usually cause things to break?

- missing/renamed/swapped parameters
- deprecations in your dependencies
- major shifts from baseline
- slow drift
- changes to assumptions you made that were ‘temporary’
