#!/bin/bash


# Install dependencies
sudo apt-get install ansible python-boto awscli jq

# Get redhat's AMI for the exported region
RHELACC=309956199498
AMINAME='RHEL-7.3_HVM_GA-20161026-x86_64*'
AMI=`aws ec2 describe-images --owners $RHELACC --filters Name=name,Values="$AMINAME"|jq -r '.Images[0].ImageId'`

# Inject region and AMI into Ansible variables file
tee vars.yml << _EOF
region: $AWS_DEFAULT_REGION
ec2ami: $AMI
_EOF

# Generate RSA key if one does not exist
[[ -f ~/.ssh/id_rsa ]] || ssh-keygen -qf ~/.ssh/id_rsa -N ""

# Get the dynamic ec2 inventory script
wget -q "https://raw.githubusercontent.com/ansible/ansible/devel/contrib/inventory/ec2.py"
