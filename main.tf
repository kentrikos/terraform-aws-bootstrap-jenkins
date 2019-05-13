data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

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

resource "random_id" "jenkins" {
  byte_length = 8
}

locals {
  name                        = "${var.product_domain_name}-${var.environment_type}-${var.name_suffix}"
  jenkins_no_proxy_list       = "${join("\\n",split(",",data.aws_ssm_parameter.proxy_no.value))}"
  jenkins_proxy_http          = "${element(split(":",replace(replace(data.aws_ssm_parameter.proxy_http.value,"http://",""),"https://","" )),0)}"
  iam_policy_names_list_local = "${join(",", var.iam_policy_names)}"
  auto_iam_policy_names_sufix = "_${data.aws_region.current.name}_${var.product_domain_name}_${var.environment_type}"

  iam_policy_names_prefix = "${var.iam_policy_names_prefix  != "" ? var.iam_policy_names_prefix : "/"}"
  iam_policy_names_sufix  = "${var.auto_IAM_mode == 1 ? local.auto_iam_policy_names_sufix : "" }"

  //  iam_policy_names_list_cross = "${var.iam_cross_account_policy_name != "" ? var.iam_cross_account_policy_name : ""}"
  iam_policy_names_list = "${local.iam_policy_names_list_local}"

  proxy_exports = <<EOF
bash -c "cat <<EOC > /etc/profile.d/http-proxy.sh
export http_proxy="${data.aws_ssm_parameter.proxy_http.value}"
export https_proxy="${data.aws_ssm_parameter.proxy_https.value}"
export no_proxy="${data.aws_ssm_parameter.proxy_no.value}"
EOC
"
source /etc/profile.d/http-proxy.sh
    EOF

  docker_proxy = <<EOF
bash -c "cat <<EOC > /etc/systemd/system/docker.service.d/http-proxy.conf
[Service]
Environment="HTTP_PROXY=${data.aws_ssm_parameter.proxy_http.value}"
Environment="HTTPS_PROXY=${data.aws_ssm_parameter.proxy_https.value}"
Environment="NO_PROXY=${data.aws_ssm_parameter.proxy_no.value}"
EOC
"
    EOF

  cross_account_role_name = "KENTRIKOS_${data.aws_region.current.name}_${var.product_domain_name}_${var.environment_type}_CrossAccount"
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
    aws_region                     = "${data.aws_region.current.name}"
    aws_operations_account_number  = "${data.aws_caller_identity.current.account_id}"
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

resource "tls_private_key" "jenkins_master_node_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "jenkins_master_node_key" {
  key_name_prefix = "${var.key_name_prefix}"
  public_key      = "${tls_private_key.jenkins_master_node_key.public_key_openssh}"
}

resource "local_file" "public_key_openssh" {
  depends_on = ["tls_private_key.jenkins_master_node_key"]
  content    = "${tls_private_key.jenkins_master_node_key.public_key_openssh}"
  filename   = "${pathexpand("~/.ssh/")}/${aws_key_pair.jenkins_master_node_key.key_name}.pub"
}

resource "local_file" "private_key_pem" {
  depends_on = ["tls_private_key.jenkins_master_node_key"]
  content    = "${tls_private_key.jenkins_master_node_key.private_key_pem}"
  filename   = "${pathexpand("~/.ssh/")}/${aws_key_pair.jenkins_master_node_key.key_name}.pem"
}

resource "null_resource" "private_key_pem_chmod" {
  depends_on = ["local_file.private_key_pem"]

  provisioner "local-exec" {
    command = "chmod 400 ${local_file.private_key_pem.filename}"
  }
}

data "http" "ip_priv" {
  url = "http://169.254.169.254/latest/meta-data/local-ipv4"
}

resource "aws_instance" "jenkins_master_node" {
  ami                         = "${length(var.ami_id) == 0 ? data.aws_ami.amazon-linux.id : var.ami_id}"
  instance_type               = "${var.ec2_instance_type}"
  subnet_id                   = "${var.subnet_id}"
  associate_public_ip_address = false
  vpc_security_group_ids      = ["${aws_security_group.ssh.id}"]
  key_name                    = "${aws_key_pair.jenkins_master_node_key.key_name}"
  user_data                   = "${length(var.ami_id) == 0 ? data.template_file.user_data.rendered : ""}"
  iam_instance_profile        = "${aws_iam_instance_profile.jenkins_master_node.name}"
  tags                        = "${merge(map("Name", "${local.name}"), var.tags)}"

  root_block_device {
    volume_size = 64
    volume_type = "gp2"
  }
}

# Route53 configuration for the Jenkins master:
data "aws_route53_zone" "selected" {
  zone_id = "${var.jenkins_dns_domain_hosted_zone_ID}"
}

resource "aws_route53_record" "jenkins_master_node" {
  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  name    = "${var.jenkins_dns_hostname}.${data.aws_route53_zone.selected.name}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.jenkins_master_node.private_ip}"]
}

# Do the provisioning at this point
resource "null_resource" "node" {
  connection {
    type        = "ssh"
    agent       = false
    user        = "ec2-user"
    host        = "${aws_instance.jenkins_master_node.private_ip}"
    private_key = "${tls_private_key.jenkins_master_node_key.private_key_pem}"
    timeout     = "3m"
  }

  provisioner "file" {
    destination = "/tmp/etc_sysconfig_jenkins"
    content     = "${data.template_file.jenkins-sysconfig.rendered}"
  }

  provisioner "file" {
    destination = "/tmp/etc_initd_jenkins"
    source      = "${path.module}/jenkins/jenkins-initd"
  }

  provisioner "file" {
    destination = "/tmp/setup.sh"
    source      = "${path.module}/jenkins/setup.sh"
  }

  provisioner "file" {
    destination = "/tmp/var_lib_jenkins_jenkins.yaml"
    content     = "${data.template_file.jenkins-jenkins_yaml.rendered}"
  }

  provisioner "file" {
    destination = "/tmp/var_lib_jenkins_docker_config"
    content     = "${data.template_file.docker-config.rendered}"
  }

  provisioner "file" {
    destination = "/tmp/plugins.txt"
    source      = "${path.module}/jenkins/plugins.txt"
  }

  provisioner "file" {
    destination = "/tmp/var_lib_jenkins_scriptApproval.xml"
    source      = "${path.module}/jenkins/scriptApproval.xml"
  }

  provisioner "file" {
    destination = "/tmp/run_secret_git_private_key"
    source      = "${pathexpand("~/.ssh/id_rsa")}"
  }

  provisioner "file" {
    destination = "/tmp/run_secret_admin_username"
    content     = "${var.jenkins_admin_username}"
  }

  provisioner "file" {
    destination = "/tmp/run_secret_admin_password"
    content     = "${var.jenkins_admin_password}"
  }

  provisioner "remote-exec" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'waiting for boot-finished'; sleep 5; done;",
      "sudo su - root -c  'cloud-init status --wait'",
      "sudo mkdir -p /var/lib/jenkins/init.groovy.d/",
      "sudo mkdir -p /var/lib/jenkins/.docker/",
      "sudo mkdir -p  /etc/secrets/jenkins",
      "sudo mv /tmp/etc_sysconfig_jenkins /etc/sysconfig/jenkins ",
      "sudo mv /tmp/etc_initd_jenkins /etc/init.d/jenkins ",
      "sudo mv /tmp/var_lib_jenkins_jenkins.yaml /var/lib/jenkins/jenkins.yaml",
      "sudo mv /tmp/var_lib_jenkins_scriptApproval.xml /var/lib/jenkins/scriptApproval.xml",
      "sudo mv /tmp/run_secret_git_private_key /etc/secrets/jenkins/GITPRIVATEKEY",
      "sudo echo ''  >> /run/secrets/GITPRIVATEKEY",
      "sudo mv /tmp/run_secret_admin_username /etc/secrets/jenkins/ADMIN_USER",
      "sudo mv /tmp/run_secret_admin_password /etc/secrets/jenkins/ADMIN_PASSWORD",
      "sudo mv /tmp/var_lib_jenkins_docker_config /var/lib/jenkins/.docker/config.json",
      "sudo su - root -c  'bash /tmp/setup.sh 2>&1 |tee /var/log/setup_log' ",
    ]
  }
}

data "aws_iam_policy" "this" {
  count = "${length(split(",",local.iam_policy_names_list))}"
  arn   = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy${local.iam_policy_names_prefix}${element(split(",", local.iam_policy_names_list), count.index)}${local.iam_policy_names_sufix}"
}

resource "aws_iam_instance_profile" "jenkins_master_node" {
  name = "${local.name}-${random_id.jenkins.hex}"
  role = "${aws_iam_role.jenkins_master_node.name}"
}

resource "aws_iam_role" "jenkins_master_node" {
  name = "${local.name}-${random_id.jenkins.hex}"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
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

# This policy is created only if auto policy creation is allowed (auto_IAM_mode)
resource "aws_iam_policy" "AssumeJenkinsCrossAccount" {
  count  = "${var.auto_IAM_mode}"
  name   = "AssumeJenkinsCrossAccount-${random_id.jenkins.hex}"
  path   = "${var.auto_IAM_path}"
  policy = "${data.aws_iam_policy_document.AssumeJenkinsCrossAccount.json}"
}

resource "aws_iam_role_policy_attachment" "jenkins_master_node" {
  role       = "${aws_iam_role.jenkins_master_node.name}"
  count      = "${length(split(",",local.iam_policy_names_list))}"
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy${local.iam_policy_names_prefix}${element(split(",",local.iam_policy_names_list), count.index)}${local.iam_policy_names_sufix}"
}

# This policy is attached only if auto policy creation is allowed (auto_IAM_mode)
resource "aws_iam_role_policy_attachment" "jenkins_master_node_cross_account" {
  role       = "${aws_iam_role.jenkins_master_node.name}"
  count      = "${var.auto_IAM_mode}"
  policy_arn = "${aws_iam_policy.AssumeJenkinsCrossAccount.arn}"
}

resource "aws_security_group" "ssh" {
  name        = "jenkins-${random_id.jenkins.hex}"
  description = "Allow SSH access to instance"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = "${var.ssh_allowed_cidrs}"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.ip_priv.body)}/32"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = "${var.http_allowed_cidrs}"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
