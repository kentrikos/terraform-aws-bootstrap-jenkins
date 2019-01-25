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
      - key: "AWS_OPERATIONS_ACCOUNT_NUMBER"
        value: "${aws_operations_account_number}"
      - key: "AWS_APPLICATION_ACCOUNT_NUMBER"
        value: "${aws_application_account_number}"
      - key: "PRODUCT_DOMAIN_NAME"
        value: "${product_domain_name}"
      - key: "ENVIRONMENT_TYPE"
        value: "${environment_type}"
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
      pipelineJob("Generate_IAM_Policies_Operations") {
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
            scriptPath("operations/iam/create/${iam_jobs_path}/Jenkinsfile")
          }
        }
       }
      pipelineJob("Generate_IAM_Policies_Application") {
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
            scriptPath("application/iam/create/${iam_jobs_path}/Jenkinsfile")
          }
        }
       }
      pipelineJob("Kubernetes_Install") {
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
            scriptPath("operations/kubernetes/install/Jenkinsfile")
          }
        }
       }
      pipelineJob("Kubernetes_Destroy") {
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
            scriptPath("operations/kubernetes/destroy/Jenkinsfile")
          }
        }
       }
      pipelineJob("Generate_JX_Docker_Image") {
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
            scriptPath("operations/images/jenkins-x-image/Jenkinsfile")
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
            scriptPath("operations/jx/Jenkinsfile")
          }
        }
       }
      pipelineJob("Grafana_Install") {
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
            scriptPath("operations/grafana/install/Jenkinsfile")
          }
        }
       }
      pipelineJob("Grafana_Destroy") {
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
            scriptPath("operations/grafana/destroy/Jenkinsfile")
          }
        }
       }
unclassified:
  location:
    adminAddress: you@example.com
    url: http://${jenkins_url}/
