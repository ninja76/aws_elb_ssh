#!/usr/bin/ruby
require 'aws-sdk'
require 'trollop'
require File.expand_path(File.dirname(__FILE__) + '/config/config.rb')

begin
  def fetch_instance_ips(opts)
    elb_group = opts[:name]
    elb = AWS::ELB.new
    ec2 = AWS::EC2.new
    c = 0
    instance_ids = elb.load_balancers[elb_group].instances.collect(&:id)
    instance_ids.each do |id|
      i = ec2.instances[id]
      tags = i.tags
      name = tags[:Name]
      if opts[:ssh] == false
        puts "#{i.id} #{name} #{i.private_ip_address}"
      end
      if opts[:ssh]
	c = c +1
	ssh_user = opts[:user]
	ssh_key  = opts[:key]
        prefix   = opts[:prefix]
	if prefix != ""
	  puts "Host #{prefix}#{c}\n"
	else
	  puts "Host #{name}\n"
        end
   	puts "  Hostname #{i.private_ip_address}\n"
        puts "  IdentityFile \"#{ssh_key}\"\n"
	puts "  User #{ssh_user}\n\n"
      end
    end
  end

## Get CLI options
  def parse_options
    opts = Trollop::options do
      opt :name, "ELB Name", :type => :string
      opt :ssh, "Output SSH config"
      opt :user, "SSH User", :type => :string
      opt :key, "SSH Key File", :type => :string
      opt :prefix, "Prefix for each instance ex. web results in web1, web2, etc", :type => :string
    end
    return opts
  end
end

opts = parse_options
fetch_instance_ips opts 
