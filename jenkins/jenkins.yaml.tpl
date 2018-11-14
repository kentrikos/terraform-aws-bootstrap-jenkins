plugins:
  proxy:
    name: "${jenkins_proxy_http}"
    noProxyHost: "${jenkins_no_proxy_list}"
    port: ${jenkins_proxy_http_port}
jenkins:
  systemMessage: "Jenkins configured automatically by Jenkins Configuration as Code Plugin\n\n"
  numExecutors: 5
  scmCheckoutRetryCount: 2
  mode: NORMAL
  securityRealm:
    local:
      allowsSignup: false
      enableCaptcha: false
      users:
      - id: $${ADMIN_USER}
        password: $${ADMIN_PASSWORD}
  authorizationStrategy:
    loggedInUsersCanDoAnything:
      allowAnonymousRead: false
  globalNodeProperties:
  - envVars:
      env:
      - key: "CONFIG_REPO_URL"
        value: "${jenkins_config_repo_url}"
      - key: "JOB_REPO_URL"
        value: "${jenkins_job_repo_url}"
      - key: "AWS_REGION"
        value: "${aws_region}"
      - key: "AWS_ACCOUNT_NUMBER"
        value: "${aws_account_number}"
  crumbIssuer:
    standard:
      excludeClientIPFromCrumb: false
security:
  remotingCLI:
    enabled: false
credentials:
  system:
    domainCredentials:
    - credentials:
      - basicSSHUserPrivateKey:
          scope: GLOBAL
          id: "bitbucket-key"
          username: "git"
          passphrase: "" #Doable, but not recommended
          description: "SSH Credentials for git to BitBucket"
          privateKeySource:
            directEntry:
              privateKey: $${GITPRIVATEKEY}
jobs:
  - script: >
      pipelineJob("Generate_IAM_Policy") {
        description()
        disabled(false)
        keepDependencies(false)
        definition {
          cpsScm {
            scm {
              git {
                remote {
                  url("${jenkins_job_repo_url}")
                  credentials("bitbucket-key")
                }
                branch("*/master")
              }
            }
            scriptPath("iam/Jenkinsfile")
          }
        }
       }
      pipelineJob("Install_Kubernetes") {
        description()
        disabled(false)
        keepDependencies(false)
        definition {
          cpsScm {
            scm {
              git {
                remote {
                  url("${jenkins_job_repo_url}")
                  credentials("bitbucket-key")
                }
                branch("*/master")
              }
            }
            scriptPath("kubernetes/Jenkinsfile")
          }
        }
       }
      pipelineJob("Install_JX") {
        description()
        disabled(false)
        keepDependencies(false)
        definition {
          cpsScm {
            scm {
              git {
                remote {
                  url("${jenkins_job_repo_url}")
                  credentials("bitbucket-key")
                }
                branch("*/master")
              }
            }
            scriptPath("jx/Jenkinsfile")
          }
        }
       }
unclassified:
  location:
    adminAddress: you@example.com
    url: http://${jenkins_url}/