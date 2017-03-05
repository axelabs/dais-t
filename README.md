Web Servers in AWS with Ansible
==============================

## Overview
This repository contains a setup script that wraps Ansible playbooks which create basic AWS infrastructure and start a web server in an EC2 Auto scaling group.

The code was tested with Ansible 2 from an Ubuntu xenial vagrant box against eu-west2 region.

## Pre-reqisits and steps
Start the VM, checkout this repo, prep the environment and run setup:
```
vagrant init ubuntu/xenial64 && vagrant up && vagrant ssh
$ git clone https://github.com/axelabs/dais-t.git && cd dais-t
$ export AWS_ACCESS_KEY_ID="### Your key here ###"
$ export AWS_SECRET_ACCESS_KEY="### Your secret here ###"
$ export AWS_DEFAULT_REGION="### Aws region to deploy to ###"
$ ./setup.sh

```

The output of the last play will have the IP address of the web server.  Alternatively, you can query the dynamic inventory by tag to curl against:
```
./ec2.py | jq -r '.tag_aws_autoscaling_groupName_Web_Servers[]' | xargs -n1 curl
```

### Notes
* The setup uses [Ansible's dynamic inventory scripts](https://aws.amazon.com/blogs/apn/getting-started-with-ansible-and-dynamic-amazon-ec2-inventory-management).
* The xenial boto package is unaware of newest regions. Consider [extending the endpoints or install latest boto](http://docs.pythonboto.org/en/latest/boto_config_tut.html).

