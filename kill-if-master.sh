#!/bin/sh

if [ ! -z "`./status.rb | grep '3 @' | grep master`" ]; then 
  PID=`cat /opt/neo4j-enterprise-1.5/data/neo4j-service.pid`
  echo "Killing master process: $PID"
  kill -9 $PID
fi

