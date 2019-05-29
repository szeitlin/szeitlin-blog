---
title: "Python_oop"
date: 2019-05-24T13:29:53-07:00
draft: false
---

I frequently hear Python referred to as a 'scripting' language, because it's not compiled.
Unfortunately, for this reason, a lot of people seem to assume you can't write 'real' programs with it. 
This post is about moving beyond using Python as a scripting language. I'm assuming you're already comfortable with
basic python data types and methods. 

_Note: Most of the content here is specific to Python 3. If you're just learning 
Python now, don't learn Python 2, it's being deprecated and many current 
libraries already stopped supporting it._ 

# What is OOP and why you should learn it

OOP stands for Object Oriented Programming. It's a way to create more structure in your code. 
More structure means your code is easier to extend, and easier to test. 

When I first started learning OOP, I found it kind of confusing, and since then I've taught a few 
other people how it works, but I never had great references or textbooks to use for reference. So I'm 
making my own. 

----

I'm going to start with a very simple example, related to food. Let's start with dessert, because life is short.

#`__init__`

```python
class Sweets:

    def __init__(self):
```

Let's create a _class_ to keep track of all the different kinds of 
desserts we want to make. The class keyword in python is not capitalized, but the name of the class is. 

A class name is a noun, and usually something that refers to a group, or 
something that can be grouped. For example, you could have a Flock class or a 
Bird class. There's usually not much point in making a class
unless you know it's going to have multiple copies or versions of an object type. 

The first thing we'll do is write an `__init__` method to _initialize_ an object using our class
definition. 
This special double-underbar or 'dunder' method will let us set default values for _attributes_. 
I've never seen a class without one. Usually, if you can't think 
of anything to put in the `__init__` method, or you don't need
a set of methods attached to an object, those are hints that you might not need to make a class. 

In this case, the `__init__` method can take inputs to define each of our different types of dessert. 

The _self_ argument is a reference that python uses to keep track of which 
_instance_ of the class we're talking about.
So each time we create a new Sweets object, it will have its own attributes, 
which we refer to by using _self_ within
the class methods. This will become clearer, hopefully, as we go along. 
(Note: I found _self_ rather clunky and confusing
when I first started learning this, so I'll do my best to clarify.)

Let's add some _attributes_ into our `__init__`. Attributes are like adjectives, 
since usually they're used to describe the class
or the instances in the class. 

```python
class Sweets:

    def __init__(self, sweetness:str, crunchiness:str, stickiness:str):
        self.sweetness = sweetness
        self.crunchiness = crunchiness
        self.stickiness = stickiness
```

Here, I've added some arguments into our `__init__` method. Note that I'm using type hinting to indicate that they're
all strings (str). Then I convert those inputs into _attributes_ by saving them onto _self_ with names. 
So here's how you use that:

First, I'm going to _instantiate_ (create) a baked_donut, which is an _instance_ of the Sweets _class_.

```python
baked_donut = Sweets(sweetness='high', crunchiness='low', stickiness='low')
```

Note that you don't have to add `self` when you create the object, the python runtime does that for you 
automagically in the background. 

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

The advantage of doing it this way, is now we can create other dessert objects 
with different attributes. 

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

So now let's say we want to add a specific method onto only a subset of Sweets. 
One way we can do that is by 
inheriting from or _subclassing_ Sweets. 

```python
class Cookie(Sweets):

    def crumble(self):
        self.size = 0
```
So now the Cookie _class_ inherits the `__init__` method and the `was_eaten()` method from the Sweets _class_. So Cookie can
use those methods, even though you don't see them here, and we don't have to write them out again. 

And, we added a new method. We want our crumble method to reduce the size attribute down to 0. But what was it originally?

We want to add this new attribute, size, into the `__init__` method for Cookie that was not in Sweets. 
We can just do that, and it would look like this:

```python
class Cookie(Sweets):

    def __init__(self, sweetness, crunchiness, stickiness):
        self.size = 10

    def crumble(self):
        if self.eaten == False:
            self.size = 0
        elif self.eaten == True:
            print("It's gone!")
```

But now, since we created a new `__init__` method, Cookie will run this local `__init__`, 
and it will _not_ run the `__init__` that was in Sweets. 

With this version of the code, we can't use `sweetness`, `crunchiness`, `stickiness`, or `eaten`, 
because this version of the Cookie class didn't initialize any of those attributes, 
so it doesn't know what they are. This is not really the behavior we expected. 

```
raw_cookie = Cookie(sweetness='high', crunchiness='low', stickiness='low')

> raw_cookie.sweetness
AttributeError: 'Cookie' object has no attribute 'sweetness'
```
____
# Super() is superior

What if we want to use all the attributes that are defined in the Sweets `__init__` method, AND add new attributes 
specific to Cookie?
 
To do that, we use `super()`. 

Super refers to the _parent_ or _base_ class that we're inheriting from. 

In this case, we're going to run the parent (Sweets)
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

Then we pass them to the `__init__` method that was inherited from the Sweets class, 
which is why we have to list them again. We don't have to list self again. 

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

# Multiple inheritance

Multiple inheritance happens if you want to inherit from more than one parent class. The only time this really makes 
sense is if the two classes provide very different functionality. So here's an example where it could be useful:

```python
class Box:
    def __init__(self):
        self.side = 4

class Chassis:
    def __init__(self):
        self.wheels = 4

class ModelTrain(Box, Chassis):
  
    def __init__(self):
        super(ModelTrain, self).__init__()
        
    def blow_horn(self):
        print('choo choo!')
```

Note that I did it this way to make sure the `__init__` methods get called for both of the parent classes, 
as described in more detail [in the answers to this StackOverflow question](https://stackoverflow.com/questions/3277367/how-does-pythons-super-work-with-multiple-inheritance). 

Having said that, if you're considering using multiple inheritance, be very careful. Here's my advice on that:

1. **Avoid it.**  
Multiple inheritance gets messy and confusing.   
If you need to do it, think hard about changing your design.  
2. **Unique names are helpful.**  
If you still think it makes sense, or you have to use someone else's code and you can't change it, 
at least try to name your methods differently in the parent and children classes, if you can.   
Obviously, you can't do this with `__init__`, which is why you have to know about how `super()` works.  
3. **If you can't avoid it, remember the MRO: method resolution order.**  
If you have methods with the same name in your class and in one or more parent classes, 
the local one is used first, and then the parent.   
Beyond that, I recommend trying to check the MRO 
using the  `.__mro__` attribute, as described [elsewhere](https://www.programiz.com/python-programming/methods/built-in/super).

# Composition

Composition is another term you'll hear, as in 'composition is better than inheritance'. Composition just means
that one object or class knows about another one, but doesn't inherit from it. 

Here's a very simplified example of the type of design I've used a lot for data engineering:

```python
class DataCleaner:
    def __init__(self, inputdata):
        self.raw = inputdata
        self.cleanup_method()
    
    def fill_null_integers(self):
        """
        Helper method  
        """
        #todo: fill missing integers with 0

    def fill_empty_strings(self):
        """
        Helper method
        """
        #todo: fill missing strings with "None"

    def remove_bad_characters(self):
        """
        Helper method
        """
        #todo: replace '-' with '_'
        
    def cleanup_method(self):
        self.fill_nulls()
        self.fill_empty_strings()
        self.remove_bad_characters()
        ...
        return dataframe

class DataPipeline:
    def __init__(self, inputdata):
        self.inputdata = inputdata
        
    def first_step(self):
        self.dataframe = DataCleaner(self.inputdata)
        
    def second_step(self):
        #todo: reshape
        
    def third_step(self):
        #todo: flatten, etc. 
 
```

So in this case, DataPipeline uses the DataCleaner class as a way to _encapsulate_ some code and pass it around in a more
readable way. It also makes it easier to reuse the DataCleaner class, as well as making it easier to 
write and run tests for the DataCleaner class separately from the DataPipeline class. 

In this case, composition is arguably
better than inheritance. The DataPipeline class doesn't need to use what's in the DataCleaner class, it just has to 
be able to use the output of DataCleaner.cleanup_method(). 

# Sometimes, inheritance is actually simpler than composition. 

Here's our Cookie example again, 
but this time with composition instead of inheritance, so we don't have worry about using super() at all, which 
seems simpler at first:

```python
class Cookie:
    def __init__(self, sweetness, crunchiness, stickiness):
        self.description = Sweets(sweetness, crunchiness, stickiness)
        self.size = 10

    def crumble(self):
        if self.eaten == False:
            self.size = 0
        elif self.eaten == True:
            print("It's gone!")
```

But now when we want to access the attributes that came from Sweets, we have to do it via self.description, 
which gets kind of confusing, since we have to keep track of what's in there vs. what isn't:

```python
composed_cookie = Cookie(sweetness='high', crunchiness='low', stickiness='low')
```

```
> composed_cookie.description.sweetness
'high'
```
---
This is a big topic, so I'm just going to stop there for now. This is enough to get you started, at least. 
Future posts may include discussion on abstract base classes, metaclasses, mixins, etc. if that seems useful. 

Special thanks to Danek Duvall, Tom Marthal, and Jeremy Abramson for suggested clarifications on this post. 

---
Here are a couple of other references that might help you as you start to use classes in python:

[one](https://www.thedigitalcatonline.com/blog/2014/08/20/python-3-oop-part-3-delegation-composition-and-inheritance/)
[two](https://codefellows.github.io/sea-python-401d4/lectures/inheritance_v_composition.html)

