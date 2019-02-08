#!/usr/bin/env bash

set -x

export JENKINS_UC=https://updates.jenkins.io
ln -s /usr/lib/jenkins/jenkins.war /usr/share/jenkins/jenkins.war


install-plugins.sh < /tmp/plugins.txt

export JENKINS_HOME="/var/lib/jenkins"
export COPY_REFERENCE_FILE_LOG="$JENKINS_HOME/copy_reference_file.log"
find /usr/share/jenkins/ref/ \( -type f -o -type l \) -exec bash -c '. /usr/local/bin/jenkins-support; for arg; do copy_reference_file "$arg"; done' _ {} +

chown jenkins:jenkins $JENKINS_HOME -R

systemctl restart jenkins.service

set +x