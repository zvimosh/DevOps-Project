// Uses Declarative syntax to run commands inside a container.
pipeline {

    agent { 
        label 'centos7' 
    }

    triggers {
  pollSCM '* * * * *'
}
    stages {
        stage('checkout code') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/master']], extensions: [], userRemoteConfigs: [[credentialsId: 'github-ssh', url: 'git@github.com:lidorg-dev/hello-world-war.git']]])
            }
        }
        stage('Build') {
            steps {
                sh "docker build -t war:$BUILD_ID ."
            }
        }
    }
}
