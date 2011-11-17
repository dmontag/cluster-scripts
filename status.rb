#!/usr/bin/env ruby

require 'net/http'

class Server
  attr_reader :host, :port

  def initialize params
    @host = params[:host]
    @port = params[:port] || 7474
  end

  def server 
    "#{host}:#{port}"
  end

  def mode
    master? ? "master" : "slave"
  end

  def master?
    `curl -s -f http://#{server}/healthcheck/master`
    $? == 0
  end
  
  def online?
    `nc -z #{host} #{port}`
	$? == 0
  end

  def latest_tx_id
    result = `curl -H "Content-Type:application/json" -d '["org.neo4j:name=High Availability,instance=*"]' http://#{server}/db/manage/server/jmx/query 2>/dev/null`.gsub(":","=>")
	return nil if $? != 0
    evaled_result = eval(result)
	ha_info = evaled_result[0]
    instances = ha_info["attributes"].find{|i|i["name"] == "InstancesInCluster"}["value"]
    instance = instances.map{|instance_info|instance_info["value"].find{|item|item["description"] == "lastCommittedTransactionId"}}.compact[0]
    instance["value"]
  end
end

require "servers.rb"

servers.each do |server|
  puts "#{server.host}\t" + (server.online? ? "online\t#{server.mode}\t#{server.latest_tx_id}" : "offline")
end
