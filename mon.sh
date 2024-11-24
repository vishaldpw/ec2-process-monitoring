#!/bin/bash

# Set PATH
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin

# Enable debugging for troubleshooting (optional)
# Uncomment to debug
# set -x

# Define the path to the Instance ID file
INSTANCE_ID_FILE="/home/ec2-user/mon_tab_status/instance-id"

# Check if the Instance ID file exists
if [[ ! -f "$INSTANCE_ID_FILE" ]]; then
    echo "Error: Instance ID file not found at $INSTANCE_ID_FILE"
    exit 1
fi

# Read the Instance ID from the file
INSTANCE_ID=$(cat "$INSTANCE_ID_FILE")
if [[ -z "$INSTANCE_ID" ]]; then
    echo "Error: Instance ID file is empty or invalid."
    exit 1
fi

# Check the status of the Nginx service
service_status=$(systemctl is-active nginx 2>/dev/null)

# Validate the output of the systemctl command
if [[ -z "$service_status" || "$service_status" == "unknown" ]]; then
    echo "Error: Failed to check the status of Nginx. Please ensure Nginx is installed and systemctl is available."
    exit 1
fi

# Debugging output for service_status
echo "Nginx service status: $service_status"

# Send metrics to AWS CloudWatch
if [[ "$service_status" == "active" ]]; then
    # Nginx is running
    metric_value=0
else
    # Nginx is not running
    metric_value=1
fi

# Debugging output for metric value
echo "Metric value to send: $metric_value"

# Send the metric to CloudWatch
aws --region eu-central-1 cloudwatch put-metric-data \
    --metric-name nginx_status \
    --value "$metric_value" \
    --namespace CWAgent \
    --dimensions InstanceId="$INSTANCE_ID"

# Check if the AWS CLI command was successful
if [[ $? -ne 0 ]]; then
    echo "Error: Failed to send metrics to CloudWatch. Please check your AWS CLI configuration."
    exit 1
fi

echo "Metrics sent successfully to CloudWatch."
