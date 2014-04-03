## Build SSH configs for AWS ELB members!

###The Problem
You have an autoscale group and instances are always coming and going.  Sometimes its nessecery to SSH into them for troubloeshooting or something.  But it can be a hassle to manually goto the AWS console and track down IP addresses for the instances.  This script does that for you and even builds the SSH configs for you!

##Usage

### Requirements:
1. gem install aws-sdk
2. gem install trollop
3. Copy config/config.rb.sample to config/config.rb and add your AWS Key info
4. Optional - Usage of 'Name' tags.  Not needed if using the prefix option

###Basic:
ruby get_elb_nodes.rb -n ELB_GROUP_NAME

###Advanced:
ruby get_elb_nodes.rb -n ELB_GROUP_NAME -s -u SSH_USER -k SSH_KEY_FILE -p PREFIX

  -s Enable SSH Config Output<br>
  -u SSH User used with -s<br>
  -k SSH Keyfile used with -s<br>
  -p Prefix of Hostname used with -s<br>

##SSH Config Output
This will output to STDOUT SSH style config blocks for each instance found in the ELB group<br>
ruby get_elb_nodes.rb -n ELB_GROUP_NAME -s -u SSH_USER -k SSH_KEY_FILE

Another cool feature is prefixing:

Lets say you have 5 web servers in an ELB group
By specifing a prefix (-p web ) of web the following Hostnames will be generated:<br>
EX. <br>
ruby get_elb_nodes.rb -n ELB_GROUP_NAME -s -u ubuntu -k ~/.ssh/mykey.pem -p web

Hostname web1<br>
Host 1.1.1.1<br>
User ubuntu<br>
IdentityFile "~/.ssh/mykey.pem"

Hostname web2<br>
Host 1.1.1.2<br>
User ubuntu<br>
IdentityFile "~/.ssh/mykey.pem"

etc....
