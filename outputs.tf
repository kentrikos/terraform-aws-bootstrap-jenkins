output "jenkins_web_url" {
  description = "URL for Jenkins web dashboard"
  value       = "http://${aws_instance.jenkins_master_node.private_ip}:8080"
}

output "jenkins_web_login" {
  description = "Default username for web dashboard"
  value       = "Admin"
}

output "jenkins_web_password" {
  description = "Default password for web dashboard"
  value       = "Password"
}

output "jenkins_private_ip" {
  description = "Private IP address assigned to the instance"
  value       = "${aws_instance.jenkins_master_node.private_ip}"
}

output "jenkins_username" {
  description = "Linux username for the instance."
  value       = "ec2-user"
}

output "ssh_private_key" {
  description = "SSH private key."
  value       = "${tls_private_key.jenkins_master_node_key.private_key_pem}"
  sensitive   = true
}

output "ssh_connection" {
  description = "SSH connection string for remote management."
  value       = "${format("ssh -i '~/.ssh/%s.pem' %s@%s", aws_key_pair.jenkins_master_node_key.key_name, "ec2-user", aws_instance.jenkins_master_node.private_ip)}"
}
