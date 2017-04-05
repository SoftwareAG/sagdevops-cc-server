#!groovy​
pipeline {
    agent {
        label 'master' // most of work on linux master/client
    }
    options {
        buildDiscarder(logRotator(numToKeepStr:'10'))
        disableConcurrentBuilds()
    }
    parameters { 
        string(name: 'VM', defaultValue: 'bgcctbp05', description: 'Command Central server VM: bgcctbp05 (lnx), bgcctbp21 (win), bgninjabvt22 (sol)') 
    }

    environment {
        VM_SERVER  = 'daevvc02'
        CC_ENV = 'default' // 9.12 or 10.0
    }

    stages {
        stage("Restart VM") {
            steps {
                vSphere buildStep: [$class: 'PowerOff', vm: params.VM, evenIfSuspended: false, shutdownGracefully: false], serverName: "${VM_SERVER}"
                vSphere buildStep: [$class: 'PowerOn',  vm: params.VM, timeoutInSeconds: 180], serverName: "${VM_SERVER}"
           }
        }
        stage("Prepare") {
            steps {
                checkout scm
                sh 'git submodule update --init' 
                stash(name:'scripts', includes:'**')
            }
        }
        stage("Boot Unix") {
            agent {
                label params.VM + '.eur.ad.sag' // bootstrap MUST run on the target VM
            }
            tools {
                ant "ant-1.9.7"
                jdk "jdk-1.8"
            }       
            /*
            when { 
                expression { return isUnix() } 
            }*/
            steps {
                unstash 'scripts'
                timeout(time:60, unit:'MINUTES') {
                    sh "ant boot --accept-license -Dbootstrap=${CC_ENV}" // use sh
                }
            }
        }
        /*
        stage('Boot Windows') {
            agent {
                label params.VM + '.eur.ad.sag' // bootstrap MUST run on the target VM
            }
            tools {
                ant "ant-1.9.7"
                jdk "jdk-1.8"
            }             
            when { 
                expression { return !isUnix() } 
            }
            steps {
                unstash 'scripts'
                timeout(time:60, unit:'MINUTES') {
                    bat "ant boot -Dbootstrap=${CC_ENV}" // use bat
                }
            }
        }*/       

        stage('Up and Test') {
            agent {
                label 'master'
            }
            tools {
                ant "ant-1.9.7"
                jdk "jdk-1.8"
            } 
            environment {
                // set EMPOWER_USR and EMPOWER_PSW env variables using Jenkins credentials
                EMPOWER = credentials('empower')
                CC_SERVER = params.VM
            }
            steps {
                unstash 'scripts'
                timeout(time:10, unit:'MINUTES') {
                    sh "ant client -Dbootstrap=${CC_ENV}" // boot client
                    sh "ant masters test installers mirrors -Denv=${CC_ENV}" // point to the target VM
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
