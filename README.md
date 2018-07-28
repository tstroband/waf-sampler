# AWS WAF Sampler

Welcome to the AWS WAF Sampler project. AWS WAF is a pretty cool Web Application Firewall that can be used to protect
your applications against DDOS attacks and malicious requests.

Unfortunately it does not let you log, store and analyze blocked requests. Instead it offers the capability to take
'samples' of blocked requests from the last 3 hours. Either through the API or through the console.

As you probably have better things to than staring at your screen waiting for blocked requests here's a small
_serverless_ little app that automates the lot. This repository contains a CloudFormation template that lets you
provision a simple lambda function and S3 bucket to periodically get those 'samples' and store them in S3 for
future reference (compliance).

The stack takes a `scheduleInterval` parameter which defines the interval for getting the samples. Every invocation it
iterates over all WebACLs in your AWS account and for each WebACL iterates over all rules to get the `Blocked` samples
for the preceding period. If any, it saves them to a file in the S3 bucket using the following key pattern:
`waf/blocked/<webacl-id>/<yyyy-MM-dd-HH-mm-ss>.json`

For example:
```
waf/blocked/8854084d-ac6b-4d55-80b4-2b0fc07c4a42/2018-07-27-08-40-00.json
```

The files contain line-break (`0x10`) separated JSON structures that allow for easy ingestion into ElasticSearch, Splunk
or other log aggregation platforms.

Each line entry contain the following information:

```json
{
  "timestamp": "2018-07-27 08:32:23.709000+00:00",
  "web-acl-id": "8854084d-ac6b-4d55-80b4-2b0fc07c4a42",
  "web-acl-name": "my-web-acl",
  "rule-id": "3f3907aa-679f-478b-a6d0-2cc537697c5b",
  "rule-name": "my-xss-rule - XSS Rule",
  "action": "BLOCK",
  "client-ip": "123.123.123.123",
  "country": "NL",
  "method": "GET",
  "uri": "/forum/newpost?text=%3Cscript%3Ealert(document.cookie)%3C%2Fscript%3E",
  "http-version": "HTTP/2.0",
  "headers": {
    "accept-language": "en-US,en;q=0.9,nl;q=0.8",
    "accept-encoding": "gzip, deflate, br",
    "accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8",
    "user-agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/67.0.3396.99 Safari/537.36",
    "host": "forum.mydomain.com",
    "cache-control": "max-age=0",
    "upgrade-insecure-requests": "1"
  }
}
```

The following sections discuss how to provision and decommission this stack.

1. Preparation
2. Provisioning
3. Decommissioning

## Preparation

#### 1. Install AWS CLI
Install the __latest version__ of the AWS CLI and ensure that it is working correctly. More information on how to do
this can be found here: [Installing the AWS Command Line Interface](https://docs.aws.amazon.com/cli/latest/userguide/installing.html)

#### 2. Setup AWS access keys
To execute the scripts that provision and decommission this app you need to setup your AWS CLI profiles correctly.

To setup your main account profile, edit the file `~/.aws/credentials` and add the following section:

```
[my-profile]
aws_access_key_id = AKIA****************
aws_secret_access_key = aLs8i9Fr********************************
aws_arn_mfa = arn:aws:iam::***********:mfa/**********
region = eu-west-1
output = json
```

* You can generate an access key for your user through the AWS console. This will give you the  `aws_access_key_id`
and `aws_secret_access_key`. More information on generating access keys for users can be found here: 
  [AWS Managing Access Keys (Console)](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_CreateAccessKey)
* The `aws_arn_mfa` is the ARN of your Multi Factor Authentication Device. More information can be found here:
  [AWS Checking MFA Status of IAM users](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_mfa_checking-status.html)
* Set the `region` value to the region of your choice. A list of region codes can be found here:
  [AWS Regions and Availability Zones](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html#concepts-available-regions)

More information on setting up profiles and credentials can be found here:
[Configuration and Credential Files](https://docs.aws.amazon.com/cli/latest/userguide/cli-config-files.html)

#### 4. Clone repository
To be able to execute the scripts you need to clone this source repository on your local machine.

Detailed information on how to clone this repository can be found here:
[GitHub Help - Cloning a repository](https://help.github.com/articles/cloning-a-repository/) 

## Provisioning
The WAF Sampler app is setup by executing the following steps:


### Step 1 - Set defaults

In the directory `cmd`, edit the file `defaults.shinc` and change the following values:

| Parameter | Description |
| --------- | ------------|
| `profile` | The AWS profile to use. This value should match the profile name you want to use. For instance `my-profile` |


### Step 2 - Create the stack
This stack provisions the entire application and all related resources. More specifically it creates the following:

1. The S3 bucket to hold the sampled logs: `waf-sampler-<env>-<account-id>`
2. The Lambda function that takes the samples and writes them to the bucket: `waf-sampler-<env>`
3. The CloudWatch log group to hold the Lambda debug log output: `/aws/lambda/waf-sampler-<env>`
4. The CloudWatch scheduled event to trigger the Lambda: `waf-sampler-<env>-lambda-schedule`

To create this stack, execute the following command from the directory `cmd`:
```
$ ./stack-create.sh -env=prod -stack=all -scheduledInterval=10 -archivePeriod=60 -retentionPeriod=365 [-<paramName>=<paramValue>]*
```
Several parameters can be appended in the form of `-paramName=paramValue`. The following parameters are supported:

| Parameter | Default | Description |
| --------- | ------- | ------------|
| `env` |  | This parameter indicates the environment of the application itself. Valid values are `dev`, `test`, `acc` and `prod`. |
| `profile` | value from `defaults.shinc` | The AWS profile to use. |
| `scheduleInterval` | `10` | The schedule interval in minutes. Valid values are `5`, `10`, `15`, `20` and `30. |
| `archivePeriod` | `60` (two months) | The time in days after which the sample logs will be moved to Glacier. Specify `0` to not archive to Glacier. |
| `retentionPeriod` | `1825` (5 years) | The time in days after which the sample logs will be deleted. Specify `0` to never delete. |


