**File Path:** /opt/aws/amazon-cloudwatch-agent/bin/mon.sh

**Purpose**

This script monitors the status of the Nginx service on an Amazon EC2
instance and sends a metric (nginx_status) to AWS CloudWatch. It is
designed to report the operational state of Nginx using custom metrics
and integrates with AWS CloudWatch alarms for notifications.

**Detailed Breakdown**

1.  **Setting the PATH**  
    The PATH variable is extended to include common directories for
    executing system commands:

```
export
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
```
2.  **Optional Debugging**

    - Debugging can be enabled by uncommenting set -x, which will print
      commands and their arguments as they are executed.

3.  **Instance ID File**

    - The script relies on an instance-specific file:  
      INSTANCE_ID_FILE=\"/home/ec2-user/mon_tab_status/instance-id\"

    - It ensures the file exists:

```

if \[\[ ! -f \"\$INSTANCE_ID_FILE\" \]\]; then
```
- Reads the instance ID, which is used to associate metrics with the EC2
  instance.

4.  **Nginx Status Check**

    - The script checks the status of the Nginx service using systemctl:

```

service_status=\$(systemctl is-active nginx 2\>/dev/null)
```
- Validates the result to ensure systemctl is available and the command
  succeeds.

5.  **Metric Value Assignment**

    - Sets the metric_value based on whether Nginx is active:

      - **0**: Nginx is running.

      - **1**: Nginx is not running.

6.  **Send Metrics to CloudWatch**

    - Uses the AWS CLI to send the metric data to AWS CloudWatch with:

```

aws \--region eu-central-1 cloudwatch put-metric-data \\

\--metric-name nginx_status \\

\--value \"\$metric_value\" \\

\--namespace CWAgent \\

\--dimensions InstanceId=\"\$INSTANCE_ID\"
```
- Associates the metric with a custom namespace (CWAgent) and a
  dimension (InstanceId).

7.  **Error Handling**

    - Provides error handling for various failure scenarios, including
      missing files, invalid instance IDs, and AWS CLI errors.

8.  **Notification Integration**

    - CloudWatch alarms can be configured to trigger notifications
      (e.g., via SNS) when the metric value equals 1.

**Usage and Integration**

1.  **Prerequisites**

    - Ensure that:

      - Nginx is installed and managed using systemctl.

      - AWS CLI is installed and configured with the necessary
        permissions.

      - The EC2 instance contains a file at
        /home/ec2-user/mon_tab_status/instance-id with a valid instance
        ID.

2.  **CloudWatch Alarm Setup**  
    Configure a CloudWatch alarm to monitor the nginx_status metric. For
    instance:

    - **Condition:** Metric value = 1

    - **Action:** Notify an Amazon SNS topic, send an email, or perform
      other automated responses.

3.  **Deployment**

    - Place the script at the specified path
      (/opt/aws/amazon-cloudwatch-agent/bin/mon.sh).

    - Add it to the system's cron or task scheduler to run periodically:

```

\*/5 \* \* \* \* /opt/aws/amazon-cloudwatch-agent/bin/mon.sh
```
4.  **Security**

    - Restrict access to the script and INSTANCE_ID_FILE to ensure
      sensitive information is protected.
