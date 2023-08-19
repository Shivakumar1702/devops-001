pipeline {
    agent any
    options {
        timestamps()
        buildDiscarder(logRotator(numToKeepStr: '5', daysToKeepStr: '7'))
        disableConcurrentBuilds()

    }

     stages {

        stage ('Github Checkout'){
            checkout scmGit(branches: [[name: '*/master']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/Shivakumar1702/devops-001.git']])
        }

        stage('Build Docker Image') {
            steps {
                script {
                    def imageName = "shivakumar1702/httpd:${env.BUILD_NUMBER}"
                    docker.build(imageName, './')
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    def imageName = "your-docker-hub-username/your-image-name:${env.BUILD_NUMBER}"
                    docker.withRegistry('https://hub.docker.com', 'dockerhub') {
                        docker.image(imageName).push()
                    }
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
