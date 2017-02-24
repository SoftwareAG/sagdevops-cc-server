#!groovy​

pipeline {
    agent {
        label 'w64'
    }

    tools {
         ant "ant-1.9.7"
         jdk "jdk-1.8"
    }

    // use agent node ENV variables
    // or you can use parameters for the pipeline
    //parameters {
    //    stringParam(description: 'Empower username (email)', name: 'EMPOWER_USER')
    //    stringParam(description: 'Empower password', name: 'EMPOWER_PASS')
    //}

    options {
        buildDiscarder(logRotator(numToKeepStr:'10'))
        disableConcurrentBuilds()
    }

    stages {
        stage("Download and Boot") {
            steps {
                timeout(time:60, unit:'MINUTES') {
                    bat 'ant boot'
                }
            }
        }
        stage("Up") {
            steps {
                timeout(time:60, unit:'MINUTES') {
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
