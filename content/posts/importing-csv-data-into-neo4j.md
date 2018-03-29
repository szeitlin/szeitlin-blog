
Thanks to a friend who wants to help more women get into tech careers, last year I attended [Developer Week](http://www.developerweek.com), where I was impressed by a talk about [Neo4j](http://www.Neo4j.org).

**Graph databases** excited me right away, since this is a concept I've used for brainstorming since 3rd grade, when my teachers Mrs. Nysmith and Weaver taught us to draw webbings as a way to take notes and work through logic puzzles. 

![image.png](/site_media/media/2384d1f2f0c71.png)

In Biochemistry, we used this kind of non-linear [flowchart](http://samzeitlin.com/Sam%20Zeitlin%20Research%20Plans.html) all the time to keep track of mechanistic models and signal transduction pathways. 

In Organic chemistry [reaction-diagrams](http://goo.gl/nHRy4p), arrows trace the flow of reactants to products, and track lone pairs of electrons and leaving groups. 


********


When I was first thinking about switching to data science, I was rejected from the [Insight Fellows Program](http://insightdatascience.com) with no useful feedback as to why. So I hesitated when a friend sent me a link to the [Data Incubator Program in New York](http://www.thedataincubator.com), but the application was fairly quick and painless, and I figured it was worth a shot. 

I'd say it was worth doing the application, since the "code challenge" was fairly interesting. 


----------

One of the questions seemed like the perfect fit for a graph database solution.

**The question** was asking how many users of the website were referred by other users, and how many users referred additional users. 

Some simple SQL queries, and the wording of the question, led me to hypothesize that a map of the users and who referred them would form a webbing type of network. 
 
#**Neo4j**

I sat in on an "intro to Neo4j" talk at Hackbright not too long ago, and I went through some of the tutorials. Since I've done a little MySQL before, I can appreciate the simple ascii art syntax that Neo4j uses in the dashboard. So I think  actually interacting with the database looks pretty straightforward in that regard. 


*But I got stuck on the very first step: trying to build a database in the required format, and view it as a graph.* 


At first, I followed the instructions on what turns out to be 
[an outdated blog post](http://maxdemarzi.com/2012/02/28/batch-importer-part-1/). At least it gave me a starting point for understanding what needed to be done. 

The csv file started out looking something like this :

[code]
user_code,referrer_code
f97c6c37eeca,e5b4a1bb0e5e
52879656bb35,
2b633b15919b,840c5cb659b3
b362c0da9eec,
cf0671c1c7c4,95492a8fa47a
[/code]

But since it wasn't tab separated, I had to import it into pandas and re-export it, noting that pandas will by default add an index unless you tell it not to:

[code lang="python"]
import pandas
users = pandas.read_csv("user_codes.txt")
users.head()

#before
      user_code referrer_code
0  f97c6c37eeca  e5b4a1bb0e5e
1  52879656bb35           NaN
2  2b633b15919b  840c5cb659b3
3  b362c0da9eec           NaN
4  cf0671c1c7c4  95492a8fa47a

users.to_csv("nodes.csv", sep = '\t', index=False)

#after
user_code       referrer_code
f97c6c37eeca    e5b4a1bb0e5e
52879656bb35    
2b633b15919b    840c5cb659b3
b362c0da9eec    
cf0671c1c7c4    95492a8fa47a
[/code]

These would all be nodes, and I was originally thinking I would add the relationships after import using something like this 
[stack overflow example](http://stackoverflow.com/questions/13823988/batch-insertion-with-neo4j).

It turns out there is a [new version of the batch importer](https://github.com/jexp/batch-import/tree/20#binary-download).
This is much easier. I was able to create nodes by following the directions:

1. download zip (linked)
2. unzip

3. at the terminal, execute @jexp's ruby script: 

[code]./import.sh test.db nodes.csv rels.csv[/code]
 
where nodes.csv is your tab-separated data file. I didn't have a rels.csv file, but that was ok for a first run. 

Then I had to copy the data into the graph.db folder inside the neo4j/data folder, like so:

[code] cp -r test.db/* /path/to/neo4j/data/graph.db/ [/code]

To view the data after import, I used this to run neo4j and point it at my graph.db file:

[code]./neo4j-shell -path ../data/graph.db [/code]

Then I went to http://localhost:7474, the default location. 

This worked to get the nodes (users and referrers, in this case), 
but there were no relationships showing how they should be connected in the graph. 

*******

**Building relationships using pandas and IPython as a sandbox**

I knew that to identify relationships in my file, I had to iterate through my table.
I figured I would start with rows where there was at least something in the "refs" column. 

In other words, my first set of relationships would just be:

[code] (referrer) - [:REFERRED] -> (user) [/code] 

At first, I was confused by some of the conventions in pandas. 

The key thing you need to know is that pandas dataframes are based on DICTIONARIES. 


So I read in my file the usual easy way:

[code lang="python"]
referrals = pandas.read_csv("user_codes.txt")

#added a column as a flag for the missing values:
referrals['has_ref'] = referrals['referrer_code'].notnull()
[/code]

Then, just to make my life easier, I filtered through the dataframe to pull out just
the rows I wanted:

[code lang="python"]
usercol = referrals['user_code']
refcol = referrals['referrer_code']

i = 1 				 #to skip the first row
users, refs = [], []       #my new shortened, cleaned up lists

for i in range(len(usercol)):
	if referrals['has_ref'][i] == True:
		users.append(usercol[i])
		refs.append(refcol[i])
	else:
		continue

[/code] 

Note that this data set is tiny (~2000 rows), so I wasn't worried about how long it would take to do it this way. 

Next, I created temporary lists for the "start" and "end" of the arrows that would be the relationships between users. 

[code lang="python"]
start, end = [], []

for i in range(len(users)):
	start.append(users[i])
	end.append(refs[i])

#adjust the endpoints to get unique numbers
end = [(i + 1) for i in end]

[/code]

Finally, I created a set of rows that can be fed into [py2neo](http://nigelsmall.com/py2neo) to create nodes and relationships in the database. 

[code lang="python"]
rowlist = []

#nodes first
for i in range(1, 100): 	        #start with a small chunk, or you'll get an Incomplete Read error
	rowlist.append(node(user=users[i]))
	rowlist.append(node(ref=refs[i]))

#relationships second
for i in range(1, 100):
	rowlist.append(rel(start[i], "RECOMMENDED", end[i]))

incubate = graph_db.create(*rowlist)

#And I had to add this line to make it appear in the Neo4j browser:

neo4j._add_header('X-Stream', 'true;format=pretty')

[/code] 

That got me a rough draft of a graph. 

To run the neo4j browser (version 2.0.1), I had to type this command from inside the neo4j-community-2.0.1 folder:

[code] ./bin/neo4j console [/code] 

That got me a rough draft of a graph I could play with. 

![screen_shot.jpg](/site_media/media/0be98b00f3421.jpg)

The relationships are not correct, of course, but my plan is to work on [the script](https://github.com/szeitlin/data-incubator/blob/master/find_relationships.py) and read [the new Cypher book](http://www.packtpub.com/learning-cypher/book). 

Of course, in the meantime, @jexp wrote [a blog post](http://jexp.de/blog/2014/06/using-load-csv-to-import-git-history-into-neo4j/) about using the new LOAD CSV capability in version 2.1.1, so we should all upgrade and do that next. 
