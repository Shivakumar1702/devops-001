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


    stages {

       stage ('Github Checkout'){
           steps {
               checkout scmGit(branches: [[name: '*/master']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/Shivakumar1702/devops-001.git']])
           }
       }

       stage('Build Docker Image') {
           steps {
               script {
                   def imageName = "shivakumar1702/httpd:${env.BUILD_NUMBER}"
                   bat "docker image build -t ${imageName} ."
                   echo DOCKERHUB
               }
           }
       }

       stage('Push to Docker Hub') {
           steps {
               script {
                   def imageName = "shivakumar1702/httpd:${env.BUILD_NUMBER}"
                   // docker.withRegistry(credentialsId: 'dockerhub', url: 'https://hub.docker.com/') {
                   // }
                   bat "docker login -u shivakumar1702 -p Docker@1996"
                   bat "docker push $imageName"
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