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
      - id: $${ADMIN_USER:-Admin}
        password: $${ADMIN_PASSWORD:-Password}
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
      - key: "CROSS_ACCOUNT_ROLE_NAME"
        value: "${cross_account_role_name}"
  crumbIssuer:
    standard:
      excludeClientIPFromCrumb: false
  proxy:
    name: "${jenkins_proxy_http}"
    noProxyHost: "${jenkins_no_proxy_list}"
    port: ${jenkins_proxy_http_port}
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
      folder('Infrastructure')
  - script: >
      folder('LMA')
  - script: >
      folder('Deployment')
  - script: >
      folder('Experimental')

  - script: >
      pipelineJob("Experimental/Generate_IAM_Policies_Operations") {
        displayName('Generate IAM Policies for KOPS in Operations Account')
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
                branch("0.9.0")
              }
            }
            scriptPath("operations/iam/create/${iam_jobs_path}/Jenkinsfile")
          }
        }
       }
      pipelineJob("Experimental/Generate_IAM_Policies_Application") {
        displayName('Generate IAM Policies for KOPS in Application Account')
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
                branch("0.9.0")
              }
            }
            scriptPath("application/iam/create/${iam_jobs_path}/Jenkinsfile")
          }
        }
       }
      pipelineJob("Infrastructure/Kubernetes_Install_EKS_Operations_Account") {
        displayName('Create EKS cluster in Operations Account')
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
                branch("0.9.0")
              }
            }
            scriptPath("operations/kubernetes/install_eks/Jenkinsfile")
          }
        }
       }
      pipelineJob("Infrastructure/Kubernetes_Remove_EKS_Operations_Account") {
        displayName('Remove EKS cluster in Operations Account')
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
                branch("0.9.0")
              }
            }
            scriptPath("operations/kubernetes/destroy_eks/Jenkinsfile")
          }
        }
       }
      pipelineJob("Infrastructure/Install_Kubernetes_EKS_Application_Account") {
        displayName('Create EKS cluster in Application Account')
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
                branch("0.9.0")
              }
            }
            scriptPath("application/kubernetes/install_eks/Jenkinsfile")
          }
        }
       }
      pipelineJob("Infrastructure/Remove_Kubernetes_EKS_Application_Account") {
        displayName('Remove EKS cluster in Application Account')
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
                branch("0.9.0")
              }
            }
            scriptPath("application/kubernetes/destroy_eks/Jenkinsfile")
          }
        }
       }
      pipelineJob("Infrastructure/Install_VPC_Endpoint_Service_Application_Account") {
        displayName('Deploy VPC Endpoint Service in Application Account')
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
                branch("0.9.0")
              }
            }
            scriptPath("application/vpc_endpoint_service/install/Jenkinsfile")
          }
        }
       }
      pipelineJob("Infrastructure/Remove_VPC_Endpoint_Service_Application_Account") {
        displayName('Remove VPC Endpoint Service in Application Account')
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
                branch("0.9.0")
              }
            }
            scriptPath("application/vpc_endpoint_service/destroy/Jenkinsfile")
          }
        }
       }
      pipelineJob("Experimental/Kubernetes_Install_KOPS_OperationsAccount") {
        displayName('Create KOPS cluster in Operations Account')
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
                branch("0.9.0")
              }
            }
            scriptPath("operations/kubernetes/install_kops/Jenkinsfile")
          }
        }
       }
      pipelineJob("Experimental/Kubernetes_Remove_KOPS_OperationsAccount") {
        displayName('Remove KOPS cluster in Operations Account')
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
                branch("0.9.0")
              }
            }
            scriptPath("operations/kubernetes/destroy_kops/Jenkinsfile")
          }
        }
       }
      pipelineJob("Experimental/Kubernetes_Install_KOPS_ApplicationAccount") {
        displayName('Create KOPS cluster in Application Account')
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
                branch("0.9.0")
              }
            }
            scriptPath("application/kubernetes/install_kops/Jenkinsfile")
          }
        }
       }
      pipelineJob("Experimental/Kubernetes_Remove_KOPS_ApplicationAccount") {
        displayName('Remove KOPS cluster in Application Account')
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
                branch("0.9.0")
              }
            }
            scriptPath("application/kubernetes/destroy_kops/Jenkinsfile")
          }
        }
       }
      pipelineJob("Experimental/Generate_JX_Docker_Image") {
        displayName('Generate JenkinsX Image')
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
                branch("0.9.0")
              }
            }
            scriptPath("operations/images/jenkins-x-image/Jenkinsfile")
          }
        }
       }
      pipelineJob("Experimental/JX_Install") {
        displayName('Deploy JenkinsX in Operations Account')
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
                branch("0.9.0")
              }
            }
            scriptPath("operations/jx/install/Jenkinsfile")
          }
        }
       }
      pipelineJob("Experimental/JX_Remove") {
        displayName('Remove JenkinsX in Operations Account')
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
                branch("0.9.0")
              }
            }
            scriptPath("operations/jx/destroy/Jenkinsfile")
          }
        }
       }
      pipelineJob("LMA/Grafana_Install") {
        displayName('Deploy Grafana in Operations Account')
        description()
        disabled(false)
        keepDependencies(false)
        parameters {
           choiceParam('K8S_FLAVOR',["eks", "kops"],'Choose type of Kubernetes cluster (required for kops)')
           stringParam('GRAFANA_PV', "", 'Name of existing PV to use for Grafana storage (usually "pvc-*"), leave empty if this is first deployment')
        }
        definition {
          cpsScm {
            scm {
              git {
                remote {
                  url("${jenkins_job_repo_url}")
                  credentials("bitbucket-key")
                }
                branch("0.9.0")
              }
            }
            scriptPath("operations/grafana/install/Jenkinsfile")
          }
        }
       }
      pipelineJob("LMA/Grafana_Remove") {
        displayName('Remove Grafana in Operations Account')
        description()
        disabled(false)
        keepDependencies(false)
        parameters {
           choiceParam('K8S_FLAVOR',["eks", "kops"],'Choose type of Kubernetes cluster (required for kops)')
        }
        definition {
          cpsScm {
            scm {
              git {
                remote {
                  url("${jenkins_job_repo_url}")
                  credentials("bitbucket-key")
                }
                branch("0.9.0")
              }
            }
            scriptPath("operations/grafana/destroy/Jenkinsfile")
          }
        }
       }
      pipelineJob("LMA/Ingress_ops_Install") {
        displayName('Create Ingress in Operations Account')
        description()
        disabled(false)
        keepDependencies(false)
        parameters {
           choiceParam('K8S_FLAVOR',["eks", "kops"],'Choose type of Kubernetes cluster (required for kops)')
        }
        definition {
          cpsScm {
            scm {
              git {
                remote {
                  url("${jenkins_job_repo_url}")
                  credentials("bitbucket-key")
                }
                branch("0.9.0")
              }
            }
            scriptPath("operations/ingress/install/Jenkinsfile")
          }
        }
       }
      pipelineJob("LMA/Ingress_ops_Remove") {
        displayName('Remove Ingress in Operations Account')
        description()
        disabled(false)
        keepDependencies(false)
        parameters {
           choiceParam('K8S_FLAVOR',["eks", "kops"],'Choose type of Kubernetes cluster (required for kops)')
        }
        definition {
          cpsScm {
            scm {
              git {
                remote {
                  url("${jenkins_job_repo_url}")
                  credentials("bitbucket-key")
                }
                branch("0.9.0")
              }
            }
            scriptPath("operations/ingress/destroy/Jenkinsfile")
          }
        }
       }
      pipelineJob("LMA/Prometheus_app_Install") {
        displayName('Deploy Prometheus in Application Account')
        description()
        disabled(false)
        keepDependencies(false)
        parameters {
           choiceParam('K8S_FLAVOR',["eks", "kops"],'Choose type of Kubernetes cluster (required for kops)')
        }
        definition {
          cpsScm {
            scm {
              git {
                remote {
                  url("${jenkins_job_repo_url}")
                  credentials("bitbucket-key")
                }
                branch("0.9.0")
              }
            }
            scriptPath("application/prometheus/install/Jenkinsfile")
          }
        }
       }
      pipelineJob("LMA/Prometheus_app_Remove") {
        displayName('Remove Prometheus in Application Account')
        description()
        disabled(false)
        keepDependencies(false)
        parameters {
           choiceParam('K8S_FLAVOR',["eks", "kops"],'Choose type of Kubernetes cluster (required for kops)')
        }
        definition {
          cpsScm {
            scm {
              git {
                remote {
                  url("${jenkins_job_repo_url}")
                  credentials("bitbucket-key")
                }
                branch("0.9.0")
              }
            }
            scriptPath("application/prometheus/destroy/Jenkinsfile")
          }
        }
       }
      pipelineJob("LMA/Prometheus_ops_Install") {
        displayName('Deploy Prometheus in Operations Account')
        description()
        disabled(false)
        keepDependencies(false)
        parameters {
           choiceParam('K8S_FLAVOR',["eks", "kops"],'Choose type of Kubernetes cluster (required for kops)')
        }
        definition {
          cpsScm {
            scm {
              git {
                remote {
                  url("${jenkins_job_repo_url}")
                  credentials("bitbucket-key")
                }
                branch("0.9.0")
              }
            }
            scriptPath("operations/prometheus/install/Jenkinsfile")
          }
        }
       }
      pipelineJob("LMA/Prometheus_ops_Remove") {
        displayName('Remove Prometheus in Operations Account')
        description()
        disabled(false)
        keepDependencies(false)
        parameters {
           choiceParam('K8S_FLAVOR',["eks", "kops"],'Choose type of Kubernetes cluster (required for kops)')
        }
        definition {
          cpsScm {
            scm {
              git {
                remote {
                  url("${jenkins_job_repo_url}")
                  credentials("bitbucket-key")
                }
                branch("0.9.0")
              }
            }
            scriptPath("operations/prometheus/destroy/Jenkinsfile")
          }
        }
       }
      pipelineJob("Deployment/Example_app") {
          displayName('Deploy example app to operations account')
          description()
          disabled(false)
          keepDependencies(false)
          parameters {
             choiceParam('K8S_FLAVOR',["eks", "kops"],'Choose type of Kubernetes cluster (required for kops)')
          }
          definition {
            cpsScm {
              scm {
                git {
                  remote {
                    url("https://github.com/kentrikos/example-app.git")
                    credentials("bitbucket-key")
                  }
                  branch("master")
                }
              }
              scriptPath("Jenkinsfile")
            }
          }
        }
      pipelineJob("LMA/Create_Logging_Operations") {
        displayName('Create Logging in Operations Account')
        description()
        disabled(false)
        keepDependencies(false)
        parameters {
           choiceParam('K8S_FLAVOR',["eks", "kops"],'Choose type of Kubernetes cluster (required for kops)')
        }
        definition {
          cpsScm {
            scm {
              git {
                remote {
                  url("${jenkins_job_repo_url}")
                  credentials("bitbucket-key")
                }
                branch("0.9.0")
              }
            }
            scriptPath("operations/logging/install/Jenkinsfile")
          }
        }
       }
      pipelineJob("LMA/Remove_Logging_Operations") {
        displayName('Remove Logging in Operations Account')
        description('Could impact logging in Application account')
        disabled(false)
        keepDependencies(false)
        parameters {
           choiceParam('K8S_FLAVOR',["eks", "kops"],'Choose type of Kubernetes cluster (required for kops)')
        }
        definition {
          cpsScm {
            scm {
              git {
                remote {
                  url("${jenkins_job_repo_url}")
                  credentials("bitbucket-key")
                }
                branch("0.9.0")
              }
            }
            scriptPath("operations/logging/destroy/Jenkinsfile")
          }
        }
       }
      pipelineJob("LMA/Create_Logging_Application") {
        displayName('Create Logging in Application Account')
        description('Requires logging deployment in Operations account first')
        disabled(false)
        keepDependencies(false)
        parameters {
           choiceParam('K8S_FLAVOR',["eks", "kops"],'Choose type of Kubernetes cluster (required for kops)')
        }
        definition {
          cpsScm {
            scm {
              git {
                remote {
                  url("${jenkins_job_repo_url}")
                  credentials("bitbucket-key")
                }
                branch("0.9.0")
              }
            }
            scriptPath("application/logging/install/Jenkinsfile")
          }
        }
       }
      pipelineJob("LMA/Remove_Logging_Application") {
        displayName('Remove Logging in Application Account')
        description()
        disabled(false)
        keepDependencies(false)
        parameters {
           choiceParam('K8S_FLAVOR',["eks", "kops"],'Choose type of Kubernetes cluster (required for kops)')
        }
        definition {
          cpsScm {
            scm {
              git {
                remote {
                  url("${jenkins_job_repo_url}")
                  credentials("bitbucket-key")
                }
                branch("0.9.0")
              }
            }
            scriptPath("application/logging/destroy/Jenkinsfile")
          }
        }
       }
unclassified:
  location:
    adminAddress: you@example.com
    url: http://${jenkins_url}/
  globalLibraries:
    libraries:
    - defaultVersion: "0.9.0"
      implicit: true
      name: "kentrikos-shared-library"
      retriever:
        modernSCM:
          scm:
            git:
              remote: "${jenkins_job_repo_url}"
