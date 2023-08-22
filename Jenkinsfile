pipeline {
    agent any

    options {
        timestamps()
        buildDiscarder(logRotator(numToKeepStr: '2', daysToKeepStr: '2'))
        disableConcurrentBuilds()
    }
    environment {
        DOCKERHUB = credentials('dockerhub')
        SERVERCRED = credentials('SERVERCRED')
    }
    
    parameters {
        choice (
            choices: '''BUILDNPUSH\nPLAN\nAPPLY\nDESTROY\nDEPLOY''',
            description: 'select an option',
            name: 'CHOICE'
        )
    }
    // triggers {
    //     pollSCM('* * * * *')
    // }

    stages {

        stage ('Github Checkout'){
            steps {
                checkout scmGit(branches: [[name: '*/master']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/Shivakumar1702/devops-001.git']])
            }
        }

       stage('Build Docker Image') {

            when {
                expression {
                    CHOICE == 'BUILDNPUSH'
                }
            }

            steps {
                script {
                    def imageName = "shivakumar1702/httpd:${env.BUILD_NUMBER}"
                    bat "docker image build -t ${imageName} ."
                }
            }
        }

        stage('Push to Docker Hub') {
            when {
                expression {
                    CHOICE == 'BUILDNPUSH'
                }
            }
            steps {
                script {
                    def imageName = "shivakumar1702/httpd:${env.BUILD_NUMBER}"
                    // docker.withRegistry(credentialsId: 'dockerhub', url: 'https://hub.docker.com/') {
                    // }
                    bat "docker login -u ${DOCKERHUB_USR} -p ${DOCKERHUB_PSW}"
                    bat "docker push $imageName"
                     bat "docker logout"
                }
            }
        }

        stage('Remove local image') {
            when {
                expression {
                    CHOICE == 'BUILDNPUSH'
                }
            }
            steps {
                script {
                    bat "docker image rm shivakumar1702/httpd:${env.BUILD_NUMBER}"
                }
            }
        }

        stage('Terraform init') {
            when {
                expression {
                    CHOICE == 'PLAN' || CHOICE == 'APPLY' || CHOICE == 'DESTROY' || CHOICE == 'DEPLOY'
                }
            }
            steps {
                bat 'terraform -chdir=./Docker-VM init'
            }
        }

        stage('Terraform Plan') {
            when {
                expression {
                    CHOICE == 'PLAN' || CHOICE == 'APPLY' || CHOICE == 'DESTROY' || CHOICE == 'DEPLOY'
                }
            }
            steps {
                bat 'terraform -chdir=./Docker-VM plan'
            }
        }

        stage('Terraform Apply') {
            when {
                expression {
                    CHOICE == 'APPLY' || CHOICE == 'DEPLOY'
                }
            }
            steps {
                bat 'terraform -chdir=./Docker-VM apply -auto-approve'
            }
        }
        
        stage('Terraform Destroy') {
            when {
                expression {
                    CHOICE == 'DESTROY'
                }
            }
            steps {
                bat 'terraform -chdir=./Docker-VM destroy -auto-approve'
            }
        }

        stage('DEPLOY') {
            when {
                expression {
                    CHOICE == 'DEPLOY'
                }
            }
            steps {
                script {
                    def serverIP = input(
                        id: 'userInput',
                        message: 'Please provide the Server IP:',
                        parameters: [
                            string(defaultValue: '', description: 'Your input', name: 'SERVER_IP')
                        ]
                    )
                    def imageTag = input(
                        id: 'imageTag',
                        message: 'Please provide the image name:',
                        parameters: [
                            string(defaultValue: '', description: 'Your input', name: 'IMAGE_TAG')
                        ]
                    )
                    echo "Server IP: ${serverIP}"
                    echo "Image Tag: ${imageTag}"
                    bat "sudo docker -H ssh://adminuser@${serverIP}:${SERVERCRED_PSW} run -d -p --name customhttpd 8000:80 shivakumar1702/httpd:${imageTag}"
                }
            }
        }
    }

    post {
        success {
            echo 'Image push to GitHub Completed Successfully'
        }
        failure {
            echo 'Image push to GitHub Failed'
        }
        always {
            echo 'Pipeline completed'
        }
    }
}