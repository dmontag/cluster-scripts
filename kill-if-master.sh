#!/bin/sh

SERVER_ID=`cat /opt/neo4j-enterprise-1.5/conf/neo4j.properties | grep server_id | tr '=' ' ' | awk '{print $2}'`

if [ ! -z "`./status.rb | grep '$SERVER_ID @' | grep master`" ]; then 
  sleep 10
  PID=`cat /opt/neo4j-enterprise-1.5/data/neo4j-service.pid`
  echo "Killing master process: $PID"
  kill -9 $PID
  sleep 1
  echo "Restarting Neo4j"
  /opt/neo4j-enterprise-1.5/bin/neo4j start
fi

