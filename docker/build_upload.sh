#!/bin/bash

set -e

while true; do
  read -p "Please choose and BUILDENV - Local or Cloud: " lc
  case $lc in
    [Cc]* )
    upload=true
    break
    ;;
    [Ll]* )
    upload=false
    break
    ;;
    * ) echo "Please answer Local or Cloud.";;
  esac
done

docker build -t gaia-ibc .

if [ $upload = true ] ; 
then
# Varaibles
  DEVREGISTRY="gcr.io/fetch-ai-sandbox/"
  VERSION=$(git describe --always --dirty=-WIP)

  REGISTRY=$DEVREGISTRY
  
  docker tag gaia-ibc ${REGISTRY}gaia_goz:${VERSION}
  docker tag gaia-ibc ${REGISTRY}gaia_goz:latest
  if [ $1 != "" ]
  then
    docker tag gaia-ibc ${REGISTRY}gaia_goz:$1
    docker push ${REGISTRY}gaia_goz:$1
  fi
  docker push ${REGISTRY}gaia_goz:${VERSION}
  docker push ${REGISTRY}gaia_goz:latest
fi