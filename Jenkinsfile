#!groovy​

pipeline {
    agent none

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
                //vSphere buildStep: [$class: 'PowerOn', timeoutInSeconds: 180, vm: 'bgninjabvt11'], serverName: 'daevvc02'
                vSphere buildStep: [$class: 'PowerOn', timeoutInSeconds: 180, vm: 'bgninjabvt02'], serverName: 'daevvc02'
                //vSphere buildStep: [$class: 'PowerOn', timeoutInSeconds: 180, vm: 'bgninjabvt22'], serverName: 'daevvc02'
            }
        }
        
        stage("Prepare") {
            agent {
                label 'master'
            }
            steps {
                checkout scm
                sh 'git submodule update --init' 
                stash(name:'scripts', includes:'**')
            }
        }
        
        stage("Boot") {
            agent {
                label 'w64' // this is Windows pipeline
            }
            tools {
                ant "ant-1.9.7"
                jdk "jdk-1.8"
            }            
            steps {
                unstash 'scripts'
                timeout(time:60, unit:'MINUTES') {
                    bat 'ant boot -Daccept.license=true'
                }
            }
        }

        stage('Up') {
            agent {
                label 'w64'
            }
            environment {
                // set EMPOWER_USR and EMPOWER_PSW env variables using Jenkins credentials
                EMPOWER = credentials('empower')
            }
            steps {
                unstash 'scripts'
                timeout(time:10, unit:'MINUTES') {
                    bat 'ant masters licenses images test'
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

        stage('Mirrors') {
            agent {
                label 'w64'
            }
            steps {
                unstash 'scripts'
                timeout(time:120, unit:'MINUTES') {
                    bat 'ant mirrors'
                }
            }
        }
    }
}
