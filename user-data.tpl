#!/bin/bash -x
#
# Install prerequisites on Jenkins master for Core Infra
# (needs to be run as root on Amazon Linux EC2 instance)
#
# FIXME: includes hardcodes + should be done as local ansible
#
#

${proxy_info}

bash -c "cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
"
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key

echo "Updating all packages:"
yum update -y

yum  -y install jenkins java-1.8.0-openjdk java-1.8.0-openjdk-devel git jq kubectl chromium

amazon-linux-extras install docker -y

mkdir -p /etc/systemd/system/docker.service.d

${docker_proxy_info}

usermod -a -G docker ec2-user
usermod -a -G docker jenkins
systemctl daemon-reload
service docker restart

#TERRAFORM_VERSION=$(curl -s https://api.github.com/repos/hashicorp/terraform/releases/latest | grep tag_name | cut -d '"' -f 4|cut -c 2-)
TERRAFORM_VERSION=0.11.11
TERRAFORM_DOWNLOAD_URL="https://releases.hashicorp.com/terraform/$${TERRAFORM_VERSION}/terraform_$${TERRAFORM_VERSION}_linux_amd64.zip"
wget --quiet "$$TERRAFORM_DOWNLOAD_URL" -O terraform.zip
unzip terraform.zip
mv -i terraform /usr/bin/
rm -rf terraform.zip

AWS_IAM_AUTH_VERSION=$$(curl -s https://api.github.com/repos/kubernetes-sigs/aws-iam-authenticator/releases/latest | grep tag_name  | cut -d '"' -f 4)
AWS_IAM_AUTH_VERSION_NUM=$$(echo $$AWS_IAM_AUTH_VERSION | cut -c 2-)
AWS_IAM_AUTH_DOWNLOAD_URL="https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/$${AWS_IAM_AUTH_VERSION}/heptio-authenticator-aws_$${AWS_IAM_AUTH_VERSION_NUM}_linux_amd64"
wget --quiet "$$AWS_IAM_AUTH_DOWNLOAD_URL" -O aws-iam-authenticator
chmod +x aws-iam-authenticator
mv -i aws-iam-authenticator /usr/bin/

curl -LO https://github.com/kubernetes/kops/releases/download/$$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64
chmod +x kops-linux-amd64
mv -i kops-linux-amd64 /usr/bin/kops

export HELM_INSTALL_DIR=/usr/bin
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get > get_helm.sh
chmod 700 get_helm.sh
./get_helm.sh


JX_VERSION=1.3.737
curl -s -f -L https://github.com/jenkins-x/jx/releases/download/v$${JX_VERSION}/jx-linux-amd64.tar.gz | tar xzv &&  mv jx /usr/bin/


mkdir -p /usr/share/jenkins/ref/
curl -s -LO https://raw.githubusercontent.com/jenkinsci/docker/master/install-plugins.sh
chmod +x install-plugins.sh
mv install-plugins.sh /usr/local/bin/

curl -s -LO https://raw.githubusercontent.com/jenkinsci/docker/master/jenkins-support
mv jenkins-support /usr/local/bin/

echo lts > /usr/share/jenkins/ref/jenkins.install.UpgradeWizard.state
echo lts > /usr/share/jenkins/ref/jenkins.install.InstallUtil.lastExecVersion
echo lts > /var/lib/jenkins/jenkins.install.UpgradeWizard.state
echo lts > /var/lib/jenkins/jenkins.install.InstallUtil.lastExecVersion



