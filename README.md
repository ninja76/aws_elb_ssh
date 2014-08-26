## Build SSH configs for AWS ELB members!

###The Problem
You have an autoscale group with instances behind an ELB that are always coming and going.  Sometimes its nessecery to SSH into them for troubleshooting, deployment or other tasks.  But it can be a hassle to keep track of what the current IP addresses are for each instance.  This script does that for you and even builds the SSH configs for you!

##Usage

### Install:
1. git clone https://github.com/ninja76/ruby-aws-tools.git
1. cd ruby-aws-tools; bundle install  (this will install all the dependencies)
3. Copy config/config.aws.rb.sample to config/config.aws.rb and add your AWS Key info
4. Optional - Usage of 'Name' tags.  Not needed if using the prefix option

###Basic:
ruby get_elb_nodes.rb -n ELB_GROUP_NAME

###Advanced:
ruby get_elb_nodes.rb -n ELB_GROUP_NAME -s -u SSH_USER -k SSH_KEY_FILE -p PREFIX<br>
or<br>
ruby get_elb_nodes.rb -c myconfig.json<br>

  -s Enable SSH Config Output<br>
  -u SSH User used with -s<br>
  -k SSH Keyfile used with -s<br>
  -p Prefix of Hostname used with -s<br>
  -c myconfig.json<br>
  -r Run Command across all nodes in a ELB group<br>

NEW: config file.  This option allows you to store all of your ELB or ASG group information in a file to quickly generate the config for all of your groups<br>
example myconfig.json:<br>
{<br>
        "groups" : [<br>
        {<br>
                "groupName": "webprod",<br>
                "username" : "ubuntu",<br>
                "sshKey"   : "/root/.ssh/prodkey.pem",<br>
                "elbName"  : "PROD01-WEB0-webELB-XXXXXXX"<br>
        },<br>
        {<br>
                "groupName": "dbprod",<br>
                "username" : "ubuntu",<br>
                "sshKey"   : "/root/.ssh/prodkey.pem",<br>
                "elbName"  : "PROD01-SE-DBE-XXXXXXX"<br>
        }<br>
        ]<br>
}<br>


####SSH Config Output:
This will output to STDOUT SSH style config blocks for each instance found in the ELB group<br>
ruby get_elb_nodes.rb -n ELB_GROUP_NAME -s -u SSH_USER -k SSH_KEY_FILE

This will output to STDOUT SSH style config blocks for all the nodes defined in all ELB groups in myconfig.json<br>
ruby get_elb_nodes.rb -c myconfig.json<br>

####Run Command:
This is will run the command "df -h" across all nodes and return the output to stdout: <br>
ruby get_elb_nodes.rb -c myconfig.json -r "df -h" <br>


####Prefixing:

Lets say you have 5 web servers in an ELB group,<br>
by specifing a prefix (-p web ) of web the following Hostnames will be generated:<br>
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
