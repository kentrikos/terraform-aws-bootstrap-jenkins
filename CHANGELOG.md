# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.9.0] - 2019-06-14
### Fixed 
- Removed remotingCli config - removed from jenkins 2.176+

## [0.8.1] - 2019-05-27
### Fixed
- Fix incorrect variable region for cross account role 
### Changed
- Upgrade tls provider to 2.0
- Add ignore user_data change to prevent recreation of master node 

## [0.8.0] - 2019-05-22
### Added
- New jobs for VPC Endpoint Service in app account

### Fixed
## [0.7.0] - 2019-05-21
### Fixed
- Fix handling secrets after reboot 

### Changed
- Secrets for jenkins moved to /etc/secrets/jenkins/ 

### Added
- Added logging infrastructure deployment to operations account
- Added logging infrastructure deployment to application account
- Cron task to restart jenkins after failed startup or reboot

## [0.6.1] - 2019-05-08
### Changed
- Updated download URL for aws-iam-authenticator

## [0.6.0] - 2019-04-15
### Added
- Add example app deployment to operations account

### Changed 
- Updated jobs version to 0.6.0

## [0.5.3] - 2019-04-09
### Changed 
- Update terraform providers to newest and support aws 2.X provider

## [0.5.2] - 2019-04-02
### Fixed
- Fix for incorrect job versions

### Changed 
- Updated jobs version to 0.5.1

## [0.5.1] - 2019-04-01
### Fixed
- Fix for incorrect param for grafana install job

## [0.5.0] - 2019-04-01
### Fixed
- Fix for not starting jenkins at server creation

### Changed
- Updated plugins
- Move proxy config for updated JCAC plugin

### Added
- Support for pipeline library definition with same source as jenkins job repo 
- Add parameter for Grafana persistence in Grafana install job

### Removed
- Ark/velero has been removed from installation

## [0.4.2] - 2019-03-26
### Fixed
- Fix display name for kops create job for application account

## [0.4.1] - 2019-03-25
### Changed 
- Bump jobs version to 0.4.1
- Rename jobs from Destroy to Remove 

## [0.4.0] - 2019-03-21
### Added
- Job folders: Infrastructure, EKS, Deployment, Extras
- Job for separate eks/kops deployments
- Job for Prometheus on application cluster
- Job for Ingress on operations cluster

### Changed 
- Move jobs to folders
- Grafana and Prometheus job updated to support eks/kops
- Jobs displays name updated 

## [0.3.1] - 2019-03-11
## Added
- New job to deploy EKS into application account
- Incremented pipeline versions to 0.3.0

## [0.3.0] - 2019-03-07
## Changed 
- Added cross account role to environment variables
- updated IAM policy names to include new eks policy

## [0.2.3] - 2019-03-01
## Changed 
- Pin terraform to 0.11.11 instead of latest

## [0.2.2] - 2019-03-01
### Added
- New job to remove jx installation

## Changed 
- update jobs version to 0.2.1

## [0.2.1] - 2019-02-27
### Fixed
- Fix for attaching policies and suffixes to master jenkins.
- Fix for pining jobs on tag - use 0.2.0 instead */0.2.0
### Added
- Included aws-iam-authenticator during Jenkins deployment
- Jenkins environment variable with the IAM Cross account role name 

## [0.2.0] - 2019-02-25
### Changed
- using jobs from 0.2.0 version

### Fixed
- Not starting jenkins on fresh installation 

## [0.1.0] - 2019-02-05
### Added
- Pining versions
- This CHANGELOG file


