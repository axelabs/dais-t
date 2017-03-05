#!/bin/bash

# This script installs Ansible and needed dependencies and uses the included playbooks
# to provision a Web Server in AWS.  For meow details see:
# https://github.com/axelabs/dais-t

# Ensure we have AWS credentials and region
for AWSVAR in AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_DEFAULT_REGION; do
  [ -v "$AWSVAR" ] || read -p "Please specify the $AWSVAR: " $AWSVAR && export $AWSVAR
done

# Install dependencies
sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq ansible python-boto awscli jq

# Ensure boto knows the region
ENDPOINTS="/usr/lib/python2.7/dist-packages/boto/endpoints.json"
CHARTED="`jq -r '.ec2|keys[]' $ENDPOINTS`"
if ! grep -q "^${AWS_DEFAULT_REGION}$" <<< "$CHARTED"; then
  echo -e "\nERROR: The $AWS_DEFAULT_REGION region is not defined in $ENDPOINTS. Update boto or use a charted region:"
  echo $CHARTED 
  exit 1
fi

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

# Create resources in AWS
ansible-playbook -i inventory infrastructure.yml -e @vars.yml

# Enable dynamic inventory
# See https://aws.amazon.com/blogs/apn/getting-started-with-ansible-and-dynamic-amazon-ec2-inventory-management/
export ANSIBLE_HOST_KEY_CHECKING=False
export ANSIBLE_HOSTS="./ec2.py"
export EC2_INI_PATH=./ec2.ini
# Get the dynamic ec2 inventory script
[[ -f ./ec2.py ]] || {
  wget -q "https://raw.githubusercontent.com/ansible/ansible/devel/contrib/inventory/ec2.py"
  chmod +x ec2.py
}

SLEEP=5
echo "Waiting for instance..."
until ansible  -u ec2-user -m ping tag_aws_autoscaling_groupName_Web_Servers 2>&1|grep -q SUCCESS; do
  echo -en "${SLEEP}s\t"; sleep $SLEEP
  SLEEP=$(($SLEEP*2))
done

# Configure webservers on the instance
ansible-playbook -u ec2-user webservers.yml
