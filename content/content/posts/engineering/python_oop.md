---
title: "Python_oop"
date: 2019-05-24T13:29:53-07:00
draft: true
---

I frequently hear Python referred to as a 'scripting' language, because it's not compiled.
Unfortunately, for this reason, a lot of people seem to assume you can't write 'real' programs with it. 
This post is about moving beyond using Python as a scripting language. 

# What is OOP and why you should learn it

OOP stands for Object Oriented Programming. It's a way to create more structure in your code. 
More structure means your code is easier to easier to extend, and easier to test. 

When I first started learning OOP, I found it kind of confusing, and since then I've taught a few 
other people how it works, but I never had great references or textbooks to use for reference. So I'm 
making my own. 

I'm going to start with a very simple example, related to food. Let's start with dessert, because life is short.

#`__init__`

```python
class Sweets:

    def __init__(self):
```

Let's create a _class_ to keep track of all the different kinds of 
desserts we want to make. The class keyword in python is not capitalized, but the name of the class is. 

A class is a noun, and usually a group. There's usually not much point in making a class
unless you know it's going to have multiple copies or versions of an object type. 

The first thing we'll do is write an `__init__` method to _initialize_ our class. This special double-underbar or 'dunderbar' 
method will let us set default values for _attributes_. I've never seen a class without one. Usually, if you can't think 
of anything to put in the `__init__` method, that's a hint that you might not need to make a class. 

In this case, the `__init__` method can take inputs to define each of our different types of dessert. 

The _self_ argument is a default reference that python uses to keep track of what _instance_ of the class we're talking about.
So each time we create a new Sweets object, it will have its own attributes, which we refer to by using _self_ within
the class methods. This will become clearer, hopefully, as we go along. (Note: I found _self_ rather clunky and confusing
when I first started learning this, so I'll do my best to clarify.)

Let's add some _attributes_ into our `__init__`. Attributes are like adjectives, since usually they're used to describe the class
or the instances in the class. 

```python
class Sweets:

    def __init__(self, sweetness:str, crunchiness:str, stickiness:str):
        self.sweetness = sweetness
        self.crunchiness = crunchiness
        self.stickiness = stickiness
```

Here, I've added some arguments into our `__init__` method. Note that I'm using type hinting to indicate that they're
all strings (str). Then I convert those inputs into _attributes_ by saving them onto _self_ with names. So here's how you use that:

First, I'm going to _instantiate_ a baked_donut, which is an _instance_ of the Sweets _class_.

```python
baked_donut = Sweets(sweetness='high', crunchiness='low', stickiness='low')
```
Let's check that our baked_donut is the type we expect:

```
> type(baked_donut)
__main__.Sweets

> isinstance(baked_donut, Sweets)
True
```

And now let's check that our inputs were saved onto the baked_donut _instance_ of the Sweets _class_.

```
> baked_donut.sweetness
'high'
```

The advantage of doing it this way, is now we can create other dessert objects with different attributes. 

```python
ginger_cookie = Sweets(sweetness='medium', crunchiness='high', stickiness='low')
```

And we can add methods onto the class, which all the instances can use. 

```python
class Sweets:

    def __init__(self, sweetness:str, crunchiness:str, stickiness:str):
        self.sweetness = sweetness
        self.crunchiness = crunchiness
        self.stickiness = stickiness
        self.eaten = False
        
    def was_eaten(self):
        self.eaten = True
```

# More specific classes: inheritance

So now let's say we want to add a specific method onto only a subset of Sweets. One way we can do that is by 
inheriting or _subclassing_ from Sweets. 

```python
class Cookie(Sweets):

    def crumble(self):
        self.size = 0
```
So now the Cookie _class_ inherits the `__init__` method and the `was_eaten()` method from the Sweets _class_. And we 
added a new method. 

We want our crumble method to reduce the size attribute down to 0. But what was it originally?

We want to add a new attribute, size, into the `__init__` method for Cookie that was not in Sweets. 

To do that, we use `super()`. 
Super refers to the _parent_ or _base_ class that we're inheriting from. In this case, we'll going to run the parent (Sweets)
`__init__` method first, and then add the size attribute. 


```python
class Cookie(Sweets):

    def __init__(self, sweetness, crunchiness, stickiness):
        super().__init__(sweetness, crunchiness, stickiness)
        self.size = 10

    def crumble(self):
        if self.eaten == False:
            self.size = 0
        elif self.eaten == True:
            print("It's gone!")
```

This part is a little confusing sometimes, so I want to break it down a little more. 

The arguments being passed into the Cookie `__init__` method are the inputs you're entering. 

Then we pass them to the `__init__` method that was inherited from the Sweets class, which is why we have to 
list them again.  

To use this with inputs, we instantiate a new cookie object:

```python
c = Cookie(sweetness='high', crunchiness='high', stickiness='low')
```

And then we can check that both our inherited attributes and methods, 
as well as our new attributes and methods, are all there on our new object:

```
> c.size
10

> c.sweetness
'high'

> c.was_eaten()
True

> c.crumble()
"It's gone!"
```

# A note on multiple inheritance

1. **Avoid it.**

Multiple inheritance gets messy and confusing. If you need to do it, think hard about changing your design. 

2. **If you can't avoid it, remember the MRO: method resolution order.** 

If you have methods with the same name in your class and in one or more parent classes, the local one is used first, and then 
the parent. 
Beyond that, I recommend trying to check the MRO using the  `.__mro__` attribute, as described ![elsewhere](https://www.programiz.com/python-programming/methods/built-in/super).

# A note on composition

Composition is another term you'll hear, as in 'composition is better than inheritance'. Composition just means
that one object or class knows about another one, but doesn't inherit from it. 

Here's a very simplified example of the type of design I've used before:

```python
class DataCleaner:
    def __init__(self, inputdata):
        self.raw = inputdata
        self.cleanup_method()
        
    def cleanup_method(self):
        #do some stuff here, deal with nulls, etc. 
        return dataframe

class DataPipeline:
    def __init__(self, inputdata):
        self.inputdata = inputdata
        
    def first_step(self):
        dataframe = DataCleaner(inputdata)
        
    def second_step(self):
        #reshape, flatten, etc. 
```

So in this case, DataPipeline uses the DataCleaner class as a way to _encapsulate_ some code and pass it around in a more
readable way. It also makes it easier to reuse the DataCleaner class, as well as making it easier to 
write and run tests for the DataCleaner class separately from the DataPipeline class. 

Here are a couple of other references that might help you as you start to use classes in python:

![one](https://www.thedigitalcatonline.com/blog/2014/08/20/python-3-oop-part-3-delegation-composition-and-inheritance/)
![two](https://codefellows.github.io/sea-python-401d4/lectures/inheritance_v_composition.html)