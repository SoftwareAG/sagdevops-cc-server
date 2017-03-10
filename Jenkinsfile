#!groovy​

pipeline {
    agent none

    options {
        buildDiscarder(logRotator(numToKeepStr:'10'))
        disableConcurrentBuilds()
    }

    environment {
        LINUX_VM   = 'bgninjabvt11' // http://ccbvtauto.eur.ad.sag:8080/computer/bgninjabvt11.eur.ad.sag/
        WINDOWS_VM = 'bgninjabvt02' // http://ccbvtauto.eur.ad.sag:8080/computer/bgninjabvt02.eur.ad.sag/
        SOLARIS_VM = 'bgninjabvt22' // http://ccbvtauto.eur.ad.sag:8080/computer/bgninjabvt22.eur.ad.sag/
        VM_SERVER  = 'daevvc02'

        CC_VM = "bgninjabvt11" // use any of the above/other
        NODE = "bgninjabvt11.eur.ad.sag" // node label
    }

    stages {
        stage("Restart VM") {
            agent {
                label 'master'
            }
            steps {
                // main CC_VM
                vSphere buildStep: [$class: 'PowerOff', evenIfSuspended: false, shutdownGracefully: false, vm: "${CC_VM}"], serverName: "${VM_SERVER}"
                vSphere buildStep: [$class: 'PowerOn', timeoutInSeconds: 180, vm: "${CC_VM}"], serverName: "${VM_SERVER}"
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
                label 'bgninjabvt11.eur.ad.sag'
            }
            tools {
                ant "ant-1.9.7"
                jdk "jdk-1.8"
            }            
            steps {
                unstash 'scripts'
                timeout(time:60, unit:'MINUTES') {
                    sh 'ant boot -Dbootstrap=10.0'
                }
            }
        }

        stage('Up') {
            agent {
                label 'bgninjabvt11.eur.ad.sag'
            }
            environment {
                // set EMPOWER_USR and EMPOWER_PSW env variables using Jenkins credentials
                EMPOWER = credentials('empower')
            }
            steps {
                unstash 'scripts'
                timeout(time:10, unit:'MINUTES') {
                    sh 'ant masters licenses images installers -Denv=10.0'
                    sh 'ant test -Denv=internal' // test against 9.12 repos
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

/*
        stage("Reset Target VM's") {
            agent {
                label 'master'
            }
            steps {
                script {
                    def vms = ['bgcctbp12', 'bgcctbp13', 'bgcctbp14']
                    for (int i = 0; i < vms.size(); ++i) {
                        echo "Resetting ${vms[i]}..."
                        vSphere buildStep: [$class: 'PowerOff', evenIfSuspended: false, shutdownGracefully: false, vm: "${vms[i]}"], serverName: "${VM_SERVER}"
                        vSphere buildStep: [$class: 'PowerOn', timeoutInSeconds: 180, vm: "${vms[i]}"], serverName: "${VM_SERVER}"
                    }
                }
           }
        }        
*/
/*
        stage('Mirrors') {
            agent {
                label 'bgninjabvt11.eur.ad.sag'
            }
            steps {
                unstash 'scripts'
                timeout(time:120, unit:'MINUTES') {
                    sh 'ant mirrors -Denv=internal'
                }
            }
        }
*/
    }
}
