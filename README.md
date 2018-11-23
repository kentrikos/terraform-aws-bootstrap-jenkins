# A Terraform module to generate a Jenkins Master node

This module will create a [Jenkins](https://jenkins.io/) node in the provided VPC and subnet.
Resources created:

* EC2 instance with all required software prerequisites installed
* new Security Group for ssh  and web access
* IAM profile for an instance
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
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| environment_type | (Required) Type of environment (e.g. test, production) | string | - | yes |
| jenkins_config_repo_url | Git repo url with Product Domain configuration | string | - | yes |
| product_domain_name | (Required) Name of product domain, will be used to create other names | string | - | yes |
| subnet_id | (Required) The VPC Subnet ID to launch the instance in. | string | - | yes |
| vpc_id | (Required) The VPC ID to launch the instance in. | string | - | yes |
| ami_id | (Optional) The AMI ID, which provides restoration of pre-created managment node. (default is false). | string | `` | no |
| ec2_instance_type | Size of EC2 instance. | string | `t3.medium` | no |
| http_allowed_cidrs | (Optional) list of cidr ranges to allow HTTP access. | list | `<list>` | no |
| http_proxy | (Optional) HTTP proxy to use for access to internet. This is required to install packages on instances deployed in ops AWS accounts. | string | `` | no |
| iam_policy_names | (Optional) List of IAM policy names to apply to the instance. | list | `<list>` | no |
| iam_policy_names_prefix | (Optional) Prefix for policy names created by portal. | string | `customer/` | no |
| jenkins_admin_password | Local jenkins Admin username. | string | `Password` | no |
| jenkins_admin_username | Local jenkins Admin username. | string | `Admin` | no |
| jenkins_job_repo_url | (Optional) Git repo url with Jenkins Jobs | string | `ssh://git@github.com:kentrikos/jenkins-bootstrap-pipelines.git` | no |
| jenkins_proxy_http_port | (Optional) HTTP proxy port to use for access to internet. This is required to install packages on instances deployed in ops AWS accounts. | string | `` | no |
| key_name_prefix | (Optional) The key name of the Key Pair to use for remote management. | string | `jenkins_master` | no |
| name_suffix | (Optional) Instance name suffix. | string | `jenkins-master-node` | no |
| ssh_allowed_cidrs | (Optional) list of cidr ranges to allow SSH access. | list | `<list>` | no |
| tags | (Optional) A mapping of tags to assign to the resource. A 'Name' tag will be created by default using the input from the 'name' variable. | map | `<map>` | no |

## Outputs

| Name | Description |
|------|-------------|
| jenkins_web_url | URL for Jenkins web dashboard |
| jenkins_web_login | Default username for web dashboard |
| jenkins_web_password | Default password for web dashboard |
| jenkins_private_ip | Private IP address assigned to the instance |
| jenkins_username | Linux username for the instance. |
| ssh_private_key | SSH private key. |
| ssh_connection | SSH connection string for remote management. |

