---
title: "Postgres With Docker"
date: 2019-10-08T15:03:46-07:00
draft: true
---

Recently, someone asked for help with setting up postgres in docker and connecting to it with python.

While helping this person, I realized this is something that should be fairly straightforward with a
simple set of instructions, but there aren't a lot good beginner tutorials out there. So I decided
to write this up because I'm sure it's something other people would also find useful. A few years ago
I wouldn't have been able to do this even with a lot of googling (this time I only had to google a few things!).

----
# Some beginner advice, before we get started on the actual steps

If you're doing database infrastructure stuff for the first time, don't worry about security.
Don't change the name of the default database, and don't set up a user and a password.
Just use the defaults for everything.

Keep things as simple as possible. Make sure you can get the thing running and connect to it.
There's no data in there yet anyway, so it doesn't matter if it's secure!

Most times, you'll tie yourself up into knots trying to figure out if your problem is authentication or
authorization, when actually you don't have anything configured correctly, so the first time through,
just skip that stuff and add it later.

Another tip: make sure you don't have another database instance running on your system. For example, if you 
installed postgres on your mac with homebrew, make sure that's been shut down, just to avoid confusion. 

---

# Step 1. Get set up with docker and make sure you can run the postgres container

1. Install docker if you don't have it already (I didn't have it on my current laptop at home). #todo: add link here

Docker has great documentation, I recommend reading it. You really only need to know a few commands
to get started. 

2. Get the postgres image: `docker pull postgres:alpine` #todo add output there

Alpine is just a very lightweight operating system. 

3. Check the name by running `docker images`  #todo add output here 

4. Start the container: #todo: add command here


----

# Step 2. Log into the running container with bash and psql

This is basically just a sanity check, but you'll probably want it anyway. 

1. In a separate terminal window, log into the running container like this:

`$ docker exec -it some-postgres bash`

You should see a prompt that looks something like this: 

`root@5be3bfd7d2b6:/#`

2. At the prompt, connect with the postgres command-line interface, which is called *psql*. 

`root@5be3bfd7d2b6:/# psql -U postgres`

3. Now we can check a couple of things. First, check if there's a database there. 

`postgres-# \l`               *#lowercase L is for 'list'*

4. Make sure you can connect to the default database. 

`postgres-# \c postgres`    *# c is for connect, and postgres is the database name*

----

# Step 3. Connect to the database using python

1. In a third terminal window, fire up a conda environment. #install anaconda if you don't have it

`conda create -n postgres-test python=3 psycopg2 ipython jupyter notebook`

Conda has great documentation, I recommend reading it: #link here

Psycopg2 is the name of the library we'll use to connect to postgres. I always install ipython and jupyter notebooks
because I almost always end up using them for development and/or debugging. 

2. Start up that environment:
 
`conda activate postgres-test`

You should see your prompt change again, so now it should show the environment name: #todo add this

3. Start ipython (or jupyter). 

`ipython`

Then `import psycopg2` 

If ^this step gives an error, the package isn’t on your path. Run `!conda list` to see if psycopg2 is in the list
of packages that are in your environment. 

If ipython is not in the environment, conda will pull it from elsewhere on your machine. 
So ipython will run, but the path will be wrong, and you’ll be confused.

4. Finally, connect to the database. Note that the documentation for psycogp2 is not completely up to date, and 
there is more than one way to do this that may or may not work depending on your situation. 

`conn = psycopg2.connect(host="0.0.0.0", port=5432, database="postgres", user="postgres", password="postgres")`

This should fail because you need to change the default password. 

`OperationalError: FATAL:  password authentication failed for user "postgres"`

5. Go back to the terminal where you connected with psql. Now you can change the default password to something simple 
 (again, we're just trying to get it set up the first time!)
 
 `ALTER USER postgres with password 'test';`

It should return `ALTER ROLE` to indicate that it worked. If you want to, you can also list the users on 
the database (#todo fill in how to do this or a link to the docs)

6. Now you should be able to actually connect using your new password:

`conn = psycopg2.connect(host="0.0.0.0", port=5432, database="postgres", user="postgres", password="test")`

After that, you'll have to create a cursor, and then you can create some tables, run queries, etc. 



