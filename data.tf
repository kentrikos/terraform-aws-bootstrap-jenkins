data "aws_ami" "amazon-linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*x86_64-gp2"]
  }
}

data "aws_ssm_parameter" "proxy_http" {
  name = "/${var.product_domain_name}/${var.environment_type}/proxy/http"
}

data "aws_ssm_parameter" "proxy_https" {
  name = "/${var.product_domain_name}/${var.environment_type}/proxy/https"
}

data "aws_ssm_parameter" "proxy_no" {
  name = "/${var.product_domain_name}/${var.environment_type}/proxy/no"
}

data "template_file" "user_data" {
  template = "${file("${path.module}/user-data.tpl")}"

  vars {
    proxy_info        = "${length(var.http_proxy) > 0 ? local.proxy_exports : var.http_proxy }"
    docker_proxy_info = "${length(var.http_proxy) > 0 ? local.docker_proxy : var.http_proxy }"
  }
}

data "template_file" "jenkins-sysconfig" {
  template = "${file("${path.module}/jenkins/jenkins-sysconfig.tpl")}"
}

data "template_file" "docker-config" {
  template = "${file("${path.module}/jenkins/docker_config.json.tpl")}"

  vars {
    httpProxy  = "${data.aws_ssm_parameter.proxy_http.value}"
    httpsProxy = "${data.aws_ssm_parameter.proxy_https.value}"
    noProxy    = "${data.aws_ssm_parameter.proxy_no.value}"
  }
}

data "template_file" "jenkins-jenkins_yaml" {
  template = "${file("${path.module}/jenkins/jenkins.yaml.tpl")}"

  vars {
    jenkins_url             = "${aws_route53_record.jenkins_master_node.name}:8080"
    jenkins_config_repo_url = "${var.jenkins_config_repo_url}"

    jenkins_job_repo_url           = "${var.jenkins_job_repo_url}"
    aws_region                     = "${var.region}"
    aws_operations_account_number  = "${var.operations_aws_account_number}"
    aws_application_account_number = "${var.application_aws_account_number}"
    jenkins_proxy_http_port        = "${var.jenkins_proxy_http_port}"
    jenkins_no_proxy_list          = "${local.jenkins_no_proxy_list}"
    jenkins_proxy_http             = "${local.jenkins_proxy_http}"

    iam_jobs_path = "${var.auto_IAM_mode == 1 ? "auto" : "manual" }"

    product_domain_name     = "${var.product_domain_name}"
    environment_type        = "${var.environment_type}"
    cross_account_role_name = "${local.cross_account_role_name}"
  }
}

data "http" "ip_priv" {
  url = "http://169.254.169.254/latest/meta-data/local-ipv4"
}

# Route53 configuration for the Jenkins master:
data "aws_route53_zone" "selected" {
  zone_id = "${var.jenkins_dns_domain_hosted_zone_ID}"
}

data "aws_iam_policy" "this" {
  count = "${length(split(",",local.iam_policy_names_list))}"
  arn   = "arn:aws:iam::${var.operations_aws_account_number}:policy${local.iam_policy_names_prefix}${element(split(",", local.iam_policy_names_list), count.index)}${local.iam_policy_names_sufix}"
}

data "aws_iam_policy_document" "AssumeJenkinsCrossAccount" {
  statement {
    sid    = "IAMJenkinsCrossAccountRolePermissions"
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    resources = [
      "arn:aws:iam::${var.application_aws_account_number}:role/${local.cross_account_role_name}",
    ]
  }
}

data "external" "trigger" {
  program = ["${path.module}/scripts/dirhash.sh"]

  query {
    directory = "${path.module}/jenkins"
  }
}

data "external" "trigger-jcasc" {
  program = ["${path.module}/scripts/dirhash.sh"]

  query {
    directory = "${var.jenkins_additional_jcasc}"
  }
}
