#!groovy​

pipeline {
    agent {
        label 'master' // most of work on linux master/client
    }
    tools {
        ant "ant-1.9.7"
        jdk "jdk-1.8"
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
            /*
            when { 
                expression { return isUnix() } 
            }*/
            steps {
                unstash 'scripts'
                timeout(time:60, unit:'MINUTES') {
                    sh 'ant boot -Dbootstrap=10.0' // use sh
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
                    bat 'ant boot -Dbootstrap=10.0' // use bat
                }
            }
        }*/       

        stage('Up') {
            environment {
                // set EMPOWER_USR and EMPOWER_PSW env variables using Jenkins credentials
                EMPOWER = credentials('empower')
            }
            steps {
                unstash 'scripts'
                timeout(time:10, unit:'MINUTES') {
                    sh "ant client -Dbootstrap=10.0" // boot client
                    sh "ant masters licenses -Denv=10.0 -Dcc=${params.VM}" // point to the target VM
                }
            }
        }

        stage('Test') {
            steps {
                unstash 'scripts'
                timeout(time:10, unit:'MINUTES') {
                    sh "ant test -Denv=internal -Dcc=${params.VM}"
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
        stage('Installers') {
            steps {
                unstash 'scripts'
                timeout(time:240, unit:'MINUTES') {
                    sh "ant installers -Denv=internal -Dbootstrap=internal -Dcc=${params.VM}"
                }
            }
        }       
        
        stage('Mirrors') {
            steps {
                unstash 'scripts'
                timeout(time:240, unit:'MINUTES') {
                    sh "ant mirrors -Denv=internal -Dcc=${params.VM}"
                }
            }
        }
*/        

/*
        stage("Reset Target VM's") {
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

    }
}
