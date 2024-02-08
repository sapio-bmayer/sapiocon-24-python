#!/bin/bash

DOCKERVER=$(date +"%Y%m%d.%H%M")
DOCKERURI=sapiosciences/sapiocon24:$DOCKERVER


docker build -f Dockerfile . -t $DOCKERURI

docker push $DOCKERURI

#sudo ctr content prune references
