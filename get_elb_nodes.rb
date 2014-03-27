#!/usr/bin/ruby
require 'rubygems'
require 'yaml'
require 'aws-sdk'
require 'trollop'
require File.expand_path(File.dirname(__FILE__) + '/config/config.rb')

opts = Trollop::options do
  opt :name, "ELB Name", :type => :string        # string --name <s>, default nil
end

begin
  def fetch_instance_ips(elb_group)
    puts "All Nodes in #{elb_group}"
    elb = AWS::ELB.new
    ec2 = AWS::EC2.new
    instance_ids = elb.load_balancers[elb_group].instances.collect(&:id)
    instance_ids.each do |id|
      i = ec2.instances[id]
      puts "#{i.id} #{i.private_ip_address}"
    end
  end

  def parse_options
  end
end

fetch_instance_ips opts[:name] 
