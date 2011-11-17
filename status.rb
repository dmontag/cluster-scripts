#!/usr/bin/env ruby

require 'net/http'
require 'date'

STDOUT.sync = true

class Server
  attr_reader :id, :host, :port

  def initialize params
    @id = params[:id] || nil
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
    return nil if id.nil?
    result = `curl -H "Content-Type:application/json" -d '["org.neo4j:name=High Availability,instance=*"]' http://#{server}/db/manage/server/jmx/query 2>/dev/null`.gsub(":","=>")
	return nil if $? != 0
    evaled_result = eval(result)
	ha_info = evaled_result[0]
    instances = ha_info["attributes"].find{|i|i["name"] == "InstancesInCluster"}
	instance = instances["value"].find{|instance_info|instance_info["value"].find{|item| item["name"] == "machineId" && item["value"].to_i == id}}
	return nil if instance.nil?
    latest_tx_id_item = instance["value"].find{|item| item["description"] == "lastCommittedTransactionId"}
	return nil if latest_tx_id_item.nil?
	latest_tx_id_item["value"].to_i
  end
end

require "servers.rb"

servers.each do |server|
#  puts "#{server.host}\t" + (server.online? ? "online\t#{server.mode}\t#{server.latest_tx_id}" : "offline")
  print "#{Time.now} -- #{server.host}\t"
  if server.online?
    print "online"
	print "\t#{server.mode}"
	print "\t#{server.latest_tx_id}"
  else
    print "offline"
  end
  puts
end
