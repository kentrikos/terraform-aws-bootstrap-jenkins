variable "product_domain_name" {
  description = "(Required) Name of product domain, will be used to create other names"
}

variable "environment_type" {
  description = "(Required) Type of environment (e.g. test, production)"
}

variable "name_suffix" {
  description = "(Optional) Instance name suffix."
  default     = "jenkins-master-node"
}

variable "operations_aws_account_number" {
  description = "AWS operations account number (without hyphens)"
}

variable "application_aws_account_number" {
  description = "AWS application account number (without hyphens)"
}

variable "vpc_id" {
  description = "(Required) The VPC ID to launch the instance in."
}

variable "subnet_id" {
  description = "(Required) The VPC Subnet ID to launch the instance in."
}

variable "ami_id" {
  description = "(Optional) The AMI ID, which provides restoration of pre-created managment node. (default is false)."
  default     = ""
}

variable "key_name_prefix" {
  description = "(Optional) The key name of the Key Pair to use for remote management."
  default     = "jenkins_master"
}

variable "ssh_allowed_cidrs" {
  type        = "list"
  description = "(Optional) list of cidr ranges to allow SSH access."
  default     = []
}

variable "http_allowed_cidrs" {
  type        = "list"
  description = "(Optional) list of cidr ranges to allow HTTP access."
  default     = []
}

variable "iam_policy_names_prefix" {
  description = "(Optional) Prefix for policy names created by portal."
  default     = "/"
}

variable "iam_policy_names" {
  type        = "list"
  description = "(Optional) List of IAM policy names to apply to the instance."

  default = [
    "KENTRIKOS_autoscaling_elb_eks",
    "KENTRIKOS_lma",
    "KENTRIKOS_dynamodb",
    "KENTRIKOS_ec2",
    "KENTRIKOS_ecr_route53",
    "KENTRIKOS_iam",
    "KENTRIKOS_s3",
    "KENTRIKOS_ssm",
    "KENTRIKOS_vpc",
  ]
}

variable "tags" {
  type        = "map"
  description = "(Optional) A mapping of tags to assign to the resource. A 'Name' tag will be created by default using the input from the 'name' variable."
  default     = {}
}

variable "http_proxy" {
  description = "(Optional) HTTP proxy to use for access to internet. This is required to install packages on instances deployed in ops AWS accounts."
  default     = ""
}

variable "jenkins_proxy_http_port" {
  description = "(Optional) HTTP proxy port to use for access to internet. This is required to install packages on instances deployed in ops AWS accounts."
  default     = "8080"
}

variable "ec2_instance_type" {
  description = "Size of EC2 instance."
  default     = "t3.medium"
}

variable "jenkins_admin_username" {
  description = "Local jenkins Admin username."
  default     = "Admin"
}

variable "jenkins_admin_password" {
  description = "Local jenkins Admin username."
  default     = "Password"
}

variable "jenkins_job_repo_url" {
  description = "(Optional) Git repo url with Jenkins Jobs"
  default     = "https://github.com/kentrikos/jenkins-bootstrap-pipelines.git"
}

variable "jenkins_config_repo_url" {
  description = "Git repo url with Product Domain configuration"
}

variable "auto_IAM_mode" {
  description = "Create IAM Policies in AWS"
  default     = false
}

variable "auto_IAM_path" {
  description = "IAM path for auto IAM mode uploaded policies"
  default     = "/"
}

variable "jenkins_dns_domain_hosted_zone_ID" {
  description = "R53 Hosted Zone ID for domain that will be used by Jenkins master"
}

variable "jenkins_dns_hostname" {
  description = "Local part of FQDN for Jenkins master"
  default     = "jenkins"
}

variable "region" {
  description = "AWS region"
  default     = "eu-central-1"
}

variable "jenkins_additional_jcasc" {
  description = "Path to directory containing aditional Jenkins configuration as code files; empty string is for disable"
  default     = ""
}
