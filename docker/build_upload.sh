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

  #Check For WIP
  if [[ $VERSION == *-WIP ]];
  then 
      echo "WIP detected - please commit changes"
      # exit 1
  fi

  REGISTRY=$DEVREGISTRY
  
  docker tag gaia-ibc ${REGISTRY}gaia_goz:${VERSION}
  docker tag gaia-ibc ${REGISTRY}gaia_goz:latest

  docker push ${REGISTRY}gaia_goz:${VERSION}
  docker push ${REGISTRY}gaia_goz:$latest
fi