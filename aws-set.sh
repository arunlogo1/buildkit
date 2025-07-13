#######################
# This script is create a ec2 instance with a given name and instance type
# It requires following prompts:
# 1. Instance type - use only graviton instance types
#    (e.g., t2g.micro, t3g.micro, t4g.micro)
# 2. VPC ID
# 3. Subnet ID
# 5. Security group ID
# 6. Instance name
# 7. check for latest AL2023 AMI for Graviton which starts with "al2023-ami-2023*" --query "Images[0].ImageId" --output text)
# 7. create a ec2 instance from the latest Amazon Linux 2 AMI for graviton which is fetched from above AWS CLI command
# 8. create a instance without a key pair
# 9. create a instance with auto assign public IP address
# 10. create a instance with a userdata script to install docker
# 10. print the instance details in a table format including:
#    - Instance ID
#    - Public IP address
#    - State (running, stopped, etc.)
#    - Instance name
#    - Instance type
# 11. Provides a options to create or destroy an ec2 instance in the shell script in the start of the script
fi
# 12. If the user chooses to destroy the instance, it will terminate the instance and
#     print a message indicating that the instance is being terminated. 
# 13. If the user chooses not to destroy the instance, create the instaance with above details



#!/bin/bash
# Check if AWS CLI is installed

if ! command -v aws &> /dev/null; then
    echo "AWS CLI is not installed. Please install it first."
    exit 1
fi
# Check if the user is logged in to AWS
if ! aws sts get-caller-identity &> /dev/null; then
    echo "You are not logged in to AWS. Please log in first."
    exit 1
fi  
# Prompt for instance type
read -p "Enter instance type (e.g., t2.micro): " INSTANCE_TYPE
# Prompt for VPC ID
read -p "Enter VPC ID: " VPC_ID
# Prompt for subnet ID 
read -p "Enter Subnet ID: " SUBNET_ID
# Prompt for security group ID
read -p "Enter Security Group ID: " SECURITY_GROUP_ID
# Prompt for instance name
read -p "Enter instance name: " INSTANCE_NAME
# Fetch the latest Amazon Linux 2023 AMI ID for Graviton
AMI_ID=$(aws ec2 describe-images --owners amazon --filters "Name=name,Values=al2023-ami-2023*" --query "Images[0].ImageId" --output text)
if [ -z "$AMI_ID" ]; then
    echo "Failed to fetch the latest Amazon Linux 2023 AMI ID for Graviton."
    exit 1
fi
# Create the EC2 instance
INSTANCE_ID=$(aws ec2 run-instances --image-id "$AMI_ID" --instance-type "$INSTANCE_TYPE" \
    --key-name "" --security-group-ids "$SECURITY_GROUP_ID" --subnet-id "$SUBNET_ID" \
    --associate-public-ip-address --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$INSTANCE_NAME}]" \
    --user-data '#!/bin/bash
    yum update -y
    amazon-linux-extras install docker -y
    systemctl start docker
    systemctl enable docker' \
    --query "Instances[0].InstanceId" --output text)
if [ -z "$INSTANCE_ID" ]; then
    echo "Failed to create the EC2 instance."
    exit 1
fi 
# Wait for the instance to be running
aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"
# Fetch instance details
INSTANCE_DETAILS=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --query "Reservations[0].Instances[0].{InstanceId:InstanceId,PublicIpAddress:PublicIpAddress,State:State.Name,InstanceType:InstanceType,Tags:Tags[?Key=='Name'].Value | [0]}" --output table)
if [ -z "$INSTANCE_DETAILS" ]; then
    echo "Failed to fetch instance details."
    exit 1
fi
# Print instance details
echo "Instance created successfully. Details:"
echo "$INSTANCE_DETAILS"
# Prompt for action to create or destroy the instance
read -p "Do you want to destroy the instance? (yes/no): " DESTROY
if [[ "$DESTROY" == "yes" ]]; then
    # Terminate the instance
    aws ec2 terminate-instances --instance-ids "$INSTANCE_ID"
    echo "Instance $INSTANCE_ID is being terminated."
else
    echo "Instance $INSTANCE_ID has been created successfully and is running."
fi
# End of script
exit 0 