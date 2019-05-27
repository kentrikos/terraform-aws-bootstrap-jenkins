locals {
  name                        = "${var.product_domain_name}-${var.environment_type}-${var.name_suffix}"
  jenkins_no_proxy_list       = "${join("\\n",split(",",data.aws_ssm_parameter.proxy_no.value))}"
  jenkins_proxy_http          = "${element(split(":",replace(replace(data.aws_ssm_parameter.proxy_http.value,"http://",""),"https://","" )),0)}"
  iam_policy_names_list_local = "${join(",", var.iam_policy_names)}"
  auto_iam_policy_names_sufix = "_${var.region}_${var.product_domain_name}_${var.environment_type}"

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

  cross_account_role_name = "KENTRIKOS_${var.region}_${var.product_domain_name}_${var.environment_type}_CrossAccount"
}
