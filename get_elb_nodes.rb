#!/usr/bin/env ruby

require 'aws-sdk-ec2'
require 'aws-sdk-elasticloadbalancing'
require 'json'
require 'trollop'

def fetch_instances_w_config(config_file, opts)
  elb = Aws::ElasticLoadBalancing::Client.new
  ec2 = Aws::EC2::Client.new
  groups = JSON.parse(File.read(config_file))['groups']

  groups.each do |group|
    elb_group = group['elbName']
    ssh_user = group['username']
    ssh_key = group['sshKey']
    prefix = group['groupName']
    count = 0

    instance_ids = elb.describe_load_balancers(load_balancer_names: [elb_group])
                     .load_balancer_descriptions[0].instances.map(&:instance_id)

    instance_ids.each do |id|
      instance = ec2.describe_instances(instance_ids: [id]).reservations[0].instances[0]
      tags = instance.tags
      name = tags.find { |t| t.key == 'Name' }&.value
      count += 1

      if !opts[:runcommand]
        puts "Host #{prefix}#{count}\n"
        puts "  Hostname #{instance.private_ip_address}\n"
        puts "  IdentityFile \"#{ssh_key}\"\n"
        puts "  User #{ssh_user}\n\n"
      end

      if opts[:runcommand]
        sshcmd = "ssh -i #{ssh_key} #{instance.private_ip_address} \"#{opts[:runcommand]}\""
        puts "Executing Command: #{sshcmd}\n"
        system sshcmd
      end
    end
  end
end

def fetch_instances_wo_config(opts)
  elb_group = opts[:name]
  ec2 = Aws::EC2::Client.new
  elb = Aws::ElasticLoadBalancing::Client.new
  count = 0

  instance_ids = elb.describe_load_balancers(load_balancer_names: [elb_group])
                   .load_balancer_descriptions[0].instances.map(&:instance_id)

  instance_ids.each do |id|
    instance = ec2.describe_instances(instance_ids: [id]).reservations[0].instances[0]
    tags = instance.tags
    name = tags.find { |t| t.key == 'Name' }&.value

    if opts[:ssh] == false
      puts "#{instance.id} #{name} #{instance.private_ip_address}"
    end

    if opts[:ssh]
      count += 1
      ssh_user = opts[:user]
      ssh_key = opts[:key]
      prefix = opts[:prefix]

      if prefix != ""
        puts "Host #{prefix}#{count}\n"
      else
        puts "Host #{name}\n"
      end

      puts "  Hostname #{instance.private_ip_address}\n"
      puts "  IdentityFile \"#{ssh_key}\"\n"
      puts "  User #{ssh_user}\n\n"
    end
  end
end

def parse_options
  Trollop::options do
    opt :config, "Config File", type: :string
    opt :name, "ELB Name", type: :string
    opt :ssh, "Output SSH config"
    opt :user, "SSH User", type: :string
    opt :key, "SSH Key File", type: :string
    opt :prefix, "Prefix for each instance ex. web results in web1, web2, etc", type: :string
    opt :runcommand, "Run command via ssh to each node", type: :string
  end
end

opts = parse_options

if opts[:config]
  fetch_instances_w_config(opts[:config], opts)
else
  fetch_instances_wo_config(opts)
end
