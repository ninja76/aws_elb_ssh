#!/usr/bin/ruby
require 'aws-sdk'
require 'trollop'
require 'json'
require File.expand_path(File.dirname(__FILE__) + '/config/config.aws.rb')

begin
  def fetch_instances(config_file)
    output = []
    JSON.parse(File.read(config_file))['groups'].each do |item|
       group = item['groupName']
       excludeList = item['exclude']
    end

    ec2 = AWS::EC2.new
    ec2.instances.each do |instance|
      state = instance.status.to_s
      tags = instance.tags
      name = tags[:Name]
      output << {:name => name, :state =>state}
    end
    puts output.to_json
  end
end

fetch_instances("stop_environment.json")

