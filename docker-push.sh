#!/bin/bash

LATEST_TAG=$(git describe --abbrev=0 --tags 2> /dev/null)
if [ "$LATEST_TAG" = "" ];
then
  echo No tags found. Skipping push.
  exit 0
fi

LATEST_TAG_COMMIT=$(git rev-list -n 1 $LATEST_TAG)
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
CURRENT_COMMIT=$(git rev-parse HEAD)

if [ "$CURRENT_BRANCH" = "master" ] && [ "$LATEST_TAG_COMMIT" = "$CURRENT_COMMIT" ];
then
  docker push $1
else
  echo Skipping push to docker hub
fi
