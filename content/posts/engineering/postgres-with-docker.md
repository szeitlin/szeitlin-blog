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
installed postgres on your mac with homebrew, make sure that's been shut down, just to avoid confusion when you 
try to log in. 

---

# Step 1. Get set up with docker and make sure you can run the postgres container

1. [Install docker](https://docs.docker.com/v17.12/install/) if you don't have it already 
(I didn't have it on my current laptop at home). 

Docker has great documentation, I recommend reading it. You really only need to know a few commands
to get started. 

2. Get the postgres image: `docker pull postgres:alpine` 

Alpine is just a very lightweight operating system. 

3. Check the name by running `docker images`. 

You should see `postgres` under `REPOSITORY` and `alpine` under `tag`.  

4. Start the container: `docker run postgres`

Your output should look something like this:

```$ docker run postgres
The files belonging to this database system will be owned by user "postgres".
This user must also own the server process.

The database cluster will be initialized with locale "en_US.utf8".
The default database encoding has accordingly been set to "UTF8".
The default text search configuration will be set to "english".

Data page checksums are disabled.

fixing permissions on existing directory /var/lib/postgresql/data ... ok
creating subdirectories ... ok
selecting default max_connections ... 100
selecting default shared_buffers ... 128MB
selecting default timezone ... Etc/UTC
selecting dynamic shared memory implementation ... posix
creating configuration files ... ok
running bootstrap script ... ok
performing post-bootstrap initialization ... ok
syncing data to disk ... ok

Success. You can now start the database server using:

    pg_ctl -D /var/lib/postgresql/data -l logfile start


WARNING: enabling "trust" authentication for local connections
You can change this by editing pg_hba.conf or using the option -A, or
--auth-local and --auth-host, the next time you run initdb.
****************************************************
WARNING: No password has been set for the database.
         This will allow anyone with access to the
         Postgres port to access your database. In
         Docker's default configuration, this is
         effectively any other container on the same
         system.

         Use "-e POSTGRES_PASSWORD=password" to set
         it in "docker run".
****************************************************
waiting for server to start....2019-09-25 16:50:07.799 UTC [42] LOG:  listening on Unix socket "/var/run/postgresql/.s.PGSQL.5432"
2019-09-25 16:50:07.815 UTC [43] LOG:  database system was shut down at 2019-09-25 16:50:07 UTC
2019-09-25 16:50:07.824 UTC [42] LOG:  database system is ready to accept connections
 done
server started

/usr/local/bin/docker-entrypoint.sh: ignoring /docker-entrypoint-initdb.d/*

2019-09-25 16:50:07.890 UTC [42] LOG:  received fast shutdown request
waiting for server to shut down....2019-09-25 16:50:07.893 UTC [42] LOG:  aborting any active transactions
2019-09-25 16:50:07.897 UTC [42] LOG:  background worker "logical replication launcher" (PID 49) exited with exit code 1
2019-09-25 16:50:07.897 UTC [44] LOG:  shutting down
2019-09-25 16:50:07.911 UTC [42] LOG:  database system is shut down
 done
server stopped

PostgreSQL init process complete; ready for start up.

2019-09-25 16:50:08.005 UTC [1] LOG:  listening on IPv4 address "0.0.0.0", port 5432
2019-09-25 16:50:08.005 UTC [1] LOG:  listening on IPv6 address "::", port 5432
2019-09-25 16:50:08.008 UTC [1] LOG:  listening on Unix socket "/var/run/postgresql/.s.PGSQL.5432"
2019-09-25 16:50:08.021 UTC [51] LOG:  database system was shut down at 2019-09-25 16:50:07 UTC
2019-09-25 16:50:08.026 UTC [1] LOG:  database system is ready to accept connections
```

----

# Step 2. Log into the running container with bash and psql

This is basically just a sanity check, but you'll probably want it anyway. 

1. In a separate terminal window, log into the running container like this:

First, run `docker ps` to get the container ID. 

Then `$ docker exec -it <container ID> bash`

`-it` means interactive terminal 

You should see a prompt that looks something like this: 

`root@5be3bfd7d2b6:/#`

2. At the prompt, connect with the postgres command-line interface, which is called *psql*, 
 using the default username, which happens to also be `postgres`.

`root@5be3bfd7d2b6:/# psql -U postgres`

`-U postgres` means "with username as postgres"

3. Now we can check a couple of things. First, check if there's a database there. 

`postgres-# \l`               *#lowercase L is for 'list'*  

You should see something like this:

```
postgres-# \l
                                 List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges   
-----------+----------+----------+------------+------------+-----------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
```

4. Make sure you can connect to the default database. 

`postgres-# \c postgres`    *# c is for connect, and postgres is the database name* 

Here's what it looks like if it works:

```
postgres-# \c postgres
You are now connected to database "postgres" as user "postgres".
```

----

# Step 3. Connect to the database using python

1. In a third terminal window, fire up a conda environment. (To do this the way I did, you'll have to install anaconda 
if you don't have it already.) 

`conda create -n postgres-test python=3 psycopg2 ipython jupyter notebook`

Conda has [great documentation](https://docs.anaconda.com/anaconda/), I recommend reading it. 

Psycopg2 is the name of the library we'll use to connect to postgres. 

I always install ipython and jupyter notebooks
because I almost always end up using them for development and/or debugging. 

2. Start up that environment:
 
`conda activate postgres-test`

You should see your prompt change again, so now it should show the environment name: 

`(postgres-test) ~/postgres-docker$`

3. Start ipython (or jupyter if you're doing more elaborate things). 

`ipython`

Then `import psycopg2` 

If ^this step gives an error, the package isn’t on your path. Run `!conda list` to see if psycopg2 is in the list
of packages that are in your environment. 

If ipython is not in the environment, conda will pull it from elsewhere on your machine. 
So ipython will run, but the path will be wrong, and you’ll be confused. If that happens, exit out of ipython, 
run `conda list` again, 
and make sure you have what you need. If any packages are missing, you can activate the conda environment and then 
`conda install <packagename>` or `pip install <packagename>`. I generally use pip as a fallback for anything conda 
can't find. 

4. Finally, connect to the database. Note that the documentation for psycogp2 is not completely up to date, and 
there is more than one way to do this, some of which may or may not work, depending on your situation. 

`conn = psycopg2.connect(host="0.0.0.0", port=5432, database="postgres", user="postgres", password="postgres")`

This should fail because you need to change the default password. 

`OperationalError: FATAL:  password authentication failed for user "postgres"`

5. Go back to the terminal where you connected with psql. Now you can change the default password 
  to something simple (again, we're just trying to get it set up the first time!).
 
 `ALTER USER postgres with password 'test';`

It should return `ALTER ROLE` to indicate that it worked. 

6. Now you should be able to actually connect using your new password:

`conn = psycopg2.connect(host="0.0.0.0", port=5432, database="postgres", user="postgres", password="test")`

After that, you'll have to create a cursor, and then you can create some tables, 
and run queries, as described in the basic usage section of [the psycopg2 docs](http://initd.org/psycopg/docs/usage.html).

Later, **don't forget to create a new user role, and change your password to something that's actually secure**, 
before you deploy your new app in the cloud, collect underpants, and profit! 



