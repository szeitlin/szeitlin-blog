Dear future me who can never remember how to do this:

This repo is where the files live for Hugo to use.

To create a new post, use the *hugo new* command, don't just create a .md file.

To preview, use the *hugo server* command.

When you're done, remove the public folder, go to the top level and run the deploy.sh script. 

The deploy.sh script rebuilds and then copies the contents of the public folder 
to the szeitlin.github.io folder (which is connected to a separate repo).

Github Pages picks up the content from there and serves it automagically. 


