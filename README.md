# A Terraform module to generate a Jenkins Master node

This module will create a [Jenkins](https://jenkins.io/) node in the provided VPC and subnet.
Resources created:

* EC2 instance with all required software prerequisites installed
* new Security Group for ssh  and web access
* IAM profile for an instance
* DNS entry in Route53 for Jenkins master
* [not yet] cronjob for sending custom CloudWatch metric reporting cluster health
* [not yet] [optional] Custom AMI for EC2 instance, it gives possibility to restore state of management node

## Preparations

The module requires that the AWS policy documents for permissions be created prior to executing.
Please use `github.com/kentrikos/aws-bootstrap` repo to create policies.
Please follow the steps outlined in the README deployment guide.

## Usage

### Basic use

```hcl
module "jenkins" {
  source              = "github.com/kentrikos/terraform-aws-bootstrap-jenkins"

  product_domain_name = "demo"
  environment_type    = "test"

  vpc_id              = "vpc-12345"
  subnet_id           = "subnet-12345"

  http_proxy          = "10.10.10.1"

  ssh_allowed_cidrs   = ["10.10.10.0/24"]
  http_allowed_cidrs  = ["10.10.10.0/24"]
  
  operations_aws_account_number  = "123456789012"
  application_aws_account_number = "210987654321"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| ami\_id | (Optional) The AMI ID, which provides restoration of pre-created managment node. (default is false). | string | `""` | no |
| application\_aws\_account\_number | AWS application account number (without hyphens) | string | n/a | yes |
| auto\_IAM\_mode | Create IAM Policies in AWS | string | `"false"` | no |
| auto\_IAM\_path | IAM path for auto IAM mode uploaded policies | string | `"/"` | no |
| ec2\_instance\_type | Size of EC2 instance. | string | `"t3.medium"` | no |
| environment\_type | (Required) Type of environment (e.g. test, production) | string | n/a | yes |
| http\_allowed\_cidrs | (Optional) list of cidr ranges to allow HTTP access. | list | `<list>` | no |
| http\_proxy | (Optional) HTTP proxy to use for access to internet. This is required to install packages on instances deployed in ops AWS accounts. | string | `""` | no |
| iam\_policy\_names | (Optional) List of IAM policy names to apply to the instance. | list | `<list>` | no |
| iam\_policy\_names\_prefix | (Optional) Prefix for policy names created by portal. | string | `"/"` | no |
| jenkins\_additional\_jcasc | Path to directory containing aditional Jenkins configuration as code files; empty string is for disable | string | `""` | no |
| jenkins\_admin\_password | Local jenkins Admin username. | string | `"Password"` | no |
| jenkins\_admin\_username | Local jenkins Admin username. | string | `"Admin"` | no |
| jenkins\_config\_repo\_url | Git repo url with Product Domain configuration | string | n/a | yes |
| jenkins\_dns\_domain\_hosted\_zone\_ID | R53 Hosted Zone ID for domain that will be used by Jenkins master | string | n/a | yes |
| jenkins\_dns\_hostname | Local part of FQDN for Jenkins master | string | `"jenkins"` | no |
| jenkins\_job\_repo\_url | (Optional) Git repo url with Jenkins Jobs | string | `"https://github.com/kentrikos/jenkins-bootstrap-pipelines.git"` | no |
| jenkins\_proxy\_http\_port | (Optional) HTTP proxy port to use for access to internet. This is required to install packages on instances deployed in ops AWS accounts. | string | `"8080"` | no |
| key\_name\_prefix | (Optional) The key name of the Key Pair to use for remote management. | string | `"jenkins_master"` | no |
| name\_suffix | (Optional) Instance name suffix. | string | `"jenkins-master-node"` | no |
| operations\_aws\_account\_number | AWS operations account number (without hyphens) | string | n/a | yes |
| product\_domain\_name | (Required) Name of product domain, will be used to create other names | string | n/a | yes |
| region | AWS region | string | `"eu-central-1"` | no |
| ssh\_allowed\_cidrs | (Optional) list of cidr ranges to allow SSH access. | list | `<list>` | no |
| subnet\_id | (Required) The VPC Subnet ID to launch the instance in. | string | n/a | yes |
| tags | (Optional) A mapping of tags to assign to the resource. A 'Name' tag will be created by default using the input from the 'name' variable. | map | `<map>` | no |
| vpc\_id | (Required) The VPC ID to launch the instance in. | string | n/a | yes |


## Outputs

| Name | Description |
|------|-------------|
| jenkins\_dns\_name | FQDN associated with Jenkins master |
| jenkins\_private\_ip | Private IP address assigned to the instance |
| jenkins\_username | Linux username for the instance. |
| jenkins\_web\_login | Default username for web dashboard |
| jenkins\_web\_password | Default password for web dashboard |
| jenkins\_web\_url | URL for Jenkins web dashboard |
| ssh\_connection | SSH connection string for remote management. |
| ssh\_private\_key | SSH private key. |
