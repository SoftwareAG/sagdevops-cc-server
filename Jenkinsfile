#!groovy​

pipeline {
    agent {
        label 'w64' // this is Windows pipeline
    }

    tools {
         ant "ant-1.9.7"
         jdk "jdk-1.8"
    }

    options {
        buildDiscarder(logRotator(numToKeepStr:'10'))
        disableConcurrentBuilds()
    }

    stages {
        stage("Download and Boot") {
            environment {
                // set EMPOWER_USR and EMPOWER_PSW env variables using Jenkins credentials
                EMPOWER = credentials('empower')
            }
            steps {
                timeout(time:60, unit:'MINUTES') {
                    bat 'git submodule update --init' 
                    bat 'ant boot'
                }
            }
        }
        stage("Up") {
            steps {
                timeout(time:10, unit:'MINUTES') {
                    bat 'ant masters licenses images'
                }
            }
        }
        stage("Mirrors") {
            steps {
                timeout(time:120, unit:'MINUTES') {
                    bat 'ant mirrors'
                }
            }
        }
        stage("Test") {
            steps {
                timeout(time:5, unit:'MINUTES') {
                    bat 'ant test'
                }
            }
            post {
                success {
                    junit 'build/tests/**/TEST-*.xml'
                }
                unstable {
                    junit 'build/tests/**/TEST-*.xml'
                }
            }
        }
    }
}
