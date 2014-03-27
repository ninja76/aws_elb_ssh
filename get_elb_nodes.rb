#!/usr/bin/ruby
require 'rubygems'
require 'yaml'
require 'aws-sdk'
require 'trollop'
require File.expand_path(File.dirname(__FILE__) + '/config/config.rb')

begin
  def fetch_instance_ips(elb_group)
    puts "All Nodes in #{elb_group}"
    elb = AWS::ELB.new
    ec2 = AWS::EC2.new
    instance_ids = elb.load_balancers[elb_group].instances.collect(&:id)
    instance_ids.each do |id|
      i = ec2.instances[id]
      tags = i.tags
      name = tags[:Name]
      puts "#{i.id} #{name} #{i.private_ip_address}"
    end
  end

## Get CLI options
  def parse_options
    opts = Trollop::options do
      opt :name, "ELB Name", :type => :string
      opt :ssh, "Output SSH config"
    end
    return opts
  end
end

opts = parse_options
fetch_instance_ips opts[:name] 
