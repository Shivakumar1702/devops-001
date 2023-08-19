pipeline {
    agent any

    options {
        timestamps()
        buildDiscarder(logRotator(numToKeepStr: '2', daysToKeepStr: '2'))
        disableConcurrentBuilds()
    }
    environment {
        DOCKERHUB = credentials('dockerhub')
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