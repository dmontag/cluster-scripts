#!/usr/bin/env ruby

require 'net/http'
require 'date'

STDOUT.sync = true

class Server
  attr_reader :id, :host, :port, :timeout

  def initialize params
    @timeout = 5
    @id = params[:id] || nil
    @host = params[:host]
    @port = params[:port] || 7474
  end

  def server 
    "#{host}:#{port}"
  end

  def ha_mode
    master? ? "master" : "slave"
  end

  def master?
    `curl -m #{timeout} -s -f http://#{server}/healthcheck/master`
    $? == 0
  end
  
  def online?
    `nc -z #{host} #{port}`
	$? == 0
  end
  
  def zk_mode
    if `echo stat | nc #{host} 2181 | grep Mode:` =~ /^Mode:\s*(.*)$/
      $1
    else
      "unknown"
    end
  end

  def latest_tx_id
    return nil if id.nil?
    result = `curl -m #{timeout} -f -H "Content-Type:application/json" -d '["org.neo4j:name=High Availability,instance=*"]' http://#{server}/db/manage/server/jmx/query 2>/dev/null`.gsub(":","=>")
    return nil if $? != 0
    evaled_result = eval(result)
    begin
      ha_info = evaled_result[0]
      instances = ha_info["attributes"].find{|i|i["name"] == "InstancesInCluster"}
      instance = instances["value"].find{|instance_info|instance_info["value"].find{|item| item["name"] == "machineId" && item["value"].to_i == id}}
      latest_tx_id_item = instance["value"].find{|item| item["description"] == "lastCommittedTransactionId"}
      latest_tx_id_item["value"].to_i
    rescue NoMethodError
      nil
    end
  end
end

require "servers.rb"

longest = 0
servers.each do |server|
  len = server.host.size()
  longest = len if (len > longest)
end  

puts "#{Time.now} --  ID @ %#{longest}s\tStatus\tHA mode\tTx ID\tZK mode" % ["Hostname"]
servers.each do |server|
  print "#{Time.now} -- %3d @ %#{longest}s\t" % [server.id, server.host]
  if server.online?
    print "online"
	  print "\t#{server.ha_mode}"
	  print "\t#{server.latest_tx_id}"
	  print "\t#{server.zk_mode}"
  else
    print "offline"
  end
  puts
end
