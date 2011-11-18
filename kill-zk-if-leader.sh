#!/bin/sh

SERVER_ID=`cat /opt/neo4j-enterprise-1.5/conf/neo4j.properties | grep server_id | tr '=' ' ' | awk '{print $2}'`

if [ ! "`./status.rb | grep -E '(leader|follower)' | wc -l`" -eq 3 ]; then 
  exit
fi

if [ ! -z "`./status.rb | grep "$SERVER_ID @" | grep leader`" ]; then 
  PID=`cat /opt/neo4j-enterprise-1.5/data/neo4j-coord.pid`
  echo "Killing ZK leader process: $PID (id=$SERVER_ID)"
  sleep 10
  kill -9 $PID
  if [ ! "`./status.rb | grep 'follower' | wc -l`" -eq 2 ]; then 
    exit
  fi
  sleep 1
  echo "Restarting Neo4j"
  /opt/neo4j-enterprise-1.5/bin/neo4j-coordinator start
fi

