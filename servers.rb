def servers
  [
    Server.new(:id=>1, :host=>"ec2-184-73-135-131.compute-1.amazonaws.com", :port=>7474),
    Server.new(:id=>2, :host=>"ec2-50-17-146-82.compute-1.amazonaws.com", :port=>7474),
    Server.new(:id=>3, :host=>"ec2-184-73-133-206.compute-1.amazonaws.com", :port=>7474)
#    Server.new(:id=>201, :host=>"ec2-176-34-3-157.ap-northeast-1.compute.amazonaws.com", :port=>7474),
#    Server.new(:id=>202, :host=>"ec2-176-34-3-181.ap-northeast-1.compute.amazonaws.com", :port=>7474),
#    Server.new(:id=>203, :host=>"ec2-176-34-7-21.ap-northeast-1.compute.amazonaws.com", :port=>7474)
  ]
end
