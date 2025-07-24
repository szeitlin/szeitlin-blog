#!/usr/bin/bash

set -e   			#exit if any errors, so we don't publish garbage by accident
set -x   			#print commands as you go, in case anything goes wrong
hugo     			#build the public folder
cd ../szeitlin.github.io
cp -r ../szeitlin-blog/public/* .
git add *
git commit -m "deploying latest changes"
git push
