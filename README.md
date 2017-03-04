Webservers in AWS with Ansible
==============================


This repository contains a setup script that wraps Ansible playbooks which create basic AWS infrastructure and start a web server in an EC2 Auto scaling group.

The code was tested with Ansible 2 from an Ubuntu xenial vagrant box against eu-west2 region. These are the pre-reqisits and steps:

Start the VM, checkout this repo, prep the environment and run setup:
```
vagrant init ubuntu/xenial64 && vagrant up && vagrant ssh
$ export AWS_ACCESS_KEY_ID="### Your key here ###"
$ export AWS_SECRET_ACCESS_KEY="### Your secret here ###"
$ AWS_DEFAULT_REGION="### Aws region to deploy to ###"
$ ./setup

```
