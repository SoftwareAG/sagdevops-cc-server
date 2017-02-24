#!groovy​

pipeline {
    options {
        buildDiscarder(logRotator(numToKeepStr:'10'))
        disableConcurrentBuilds()
    }

    stages {
        stage("Restart VMs") {
            agent {
                label 'master'
            }
            steps {
                // TODO: clean this up
                //vSphere buildStep: [$class: 'PowerOff', evenIfSuspended: false, shutdownGracefully: false, vm: 'bgninjabvt11'], serverName: 'daevvc02'
                vSphere buildStep: [$class: 'PowerOff', evenIfSuspended: false, shutdownGracefully: false, vm: 'bgninjabvt02'], serverName: 'daevvc02'
                //vSphere buildStep: [$class: 'PowerOff', evenIfSuspended: false, shutdownGracefully: false, vm: 'bgninjabvt22'], serverName: 'daevvc02'
                sleep 10
                //vSphere buildStep: [$class: 'PowerOn', timeoutInSeconds: 180, vm: 'bgninjabvt11'], serverName: 'daevvc02'
                vSphere buildStep: [$class: 'PowerOn', timeoutInSeconds: 180, vm: 'bgninjabvt02'], serverName: 'daevvc02'
                //vSphere buildStep: [$class: 'PowerOn', timeoutInSeconds: 180, vm: 'bgninjabvt22'], serverName: 'daevvc02'
                sleep 80
            }
        }
        stage("Download and Boot") {
            agent {
                label 'w64' // this is Windows pipeline
            }
            tools {
                ant "ant-1.9.7"
                jdk "jdk-1.8"
            }            
            environment {
                // set EMPOWER_USR and EMPOWER_PSW env variables using Jenkins credentials
                EMPOWER = credentials('empower')
            }
            steps {
                timeout(time:60, unit:'MINUTES') {
                    bat 'git submodule update --init' 
                    bat 'ant boot -Daccept.license=true'
                }
            }
        }
        stage("Up") {
            agent {
                label 'w64' // this is Windows pipeline
            }
            steps {
                timeout(time:10, unit:'MINUTES') {
                    bat 'ant masters licenses images'
                }
            }
        }
        stage("Mirrors") {
            agent {
                label 'w64' // this is Windows pipeline
            }
            steps {
                timeout(time:120, unit:'MINUTES') {
                    bat 'ant mirrors'
                }
            }
        }
        stage("Test") {
            agent {
                label 'w64' // this is Windows pipeline
            }
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
