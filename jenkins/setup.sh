#!/usr/bin/env bash

set -x
chmod a+x /etc/init.d/jenkins

export JENKINS_UC=https://updates.jenkins.io
ln -s /usr/lib/jenkins/jenkins.war /usr/share/jenkins/jenkins.war


install-plugins.sh < /tmp/plugins.txt

export JENKINS_HOME="/var/lib/jenkins"
export COPY_REFERENCE_FILE_LOG="$JENKINS_HOME/copy_reference_file.log"
find /usr/share/jenkins/ref/ \( -type f -o -type l \) -exec bash -c '. /usr/local/bin/jenkins-support; for arg; do copy_reference_file "$arg"; done' _ {} +

chown jenkins:jenkins $JENKINS_HOME -R
echo "Attempt to stop and start jenkins"
systemctl status jenkins.service

chown -R jenkins:jenkins /var/lib/jenkins
chown -R jenkins:jenkins /var/cache/jenkins
chown -R jenkins:jenkins /var/log/jenkins


systemctl stop jenkins.service
sleep 5
systemctl status jenkins.service
systemctl start jenkins.service
sleep 15
systemctl status jenkins.service

systemctl enable jenkins
sleep 10
systemctl status jenkins.service

systemctl show -p SubState jenkins |grep running || systemctl restart jenkins

sleep 10
systemctl status jenkins.service

echo "Attempt to stop and start jenkins done"

(crontab -l 2>/dev/null; echo "*/1 * * * * systemctl show -p SubState jenkins |grep -E 'running|dead' || systemctl restart jenkins") | crontab -

set +x