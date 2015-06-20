# StackTray
StackTray App

To get started with the app, run 'pod install' in the terminal.
After that, open StackTray.xcworkspace


## Creating policy with restricted access using IAM
Using IAM you can create an account with less privileges, eg. to only read, stop and start instances. 

Example policy file that allows stop and start for the instances with environment tag stacktray:

```{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "TheseActionsSupportResourceLevelPermissionsWithInstancesAndTags",
            "Effect": "Allow",
            "Action": [
                "ec2:StopInstances",
                "ec2:StartInstances"],
            "Resource": "arn:aws:ec2:eu-west-1:{customerid}:instance/*",
            "Condition": {
                "StringEquals": {"ec2:ResourceTag/Environment": "stacktray"}
            }
        }
    ]
}```

