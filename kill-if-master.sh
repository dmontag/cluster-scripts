#!/bin/sh

if [ ! -z "`./status.rb | grep '3 @' | grep master`" ]; then 
  kill -9 `cat /opt/neo4j-enterprise-1.5/data/neo4j-service.pid`
fi

