#!groovy​
pipeline {
    agent none

    options {
        buildDiscarder(logRotator(numToKeepStr:'10'))
        disableConcurrentBuilds()
        skipDefaultCheckout()
    }
    environment {
        CC_BOOT = 'default'    // your custom boot config
        CC_ENV = 'default'     // your custom env config
  
        VM_SERVER  = 'daevvc02'
        CC_VM = 'bgninjabvt06' // your VM
        CC_AGENT = "bgninjabvt06.eur.ad.sag" // Jenkins agent

        // set EMPOWER_USR and EMPOWER_PSW env variables using Jenkins credentials
        EMPOWER = credentials('empower')
        // CC_CLI_HOME = '$HOME/sag/cc/CommandCentral/client'
    }
    stages {
        stage("Prepare") {
            agent {
                label 'master'
            }            
            steps {
                checkout scm
                stash(name:'scripts', includes:'**')
            }
        }
        stage ('Restart VM') {
            agent {
                label 'master'
            }
            steps {
                vSphere buildStep: [$class: 'PowerOff', evenIfSuspended: false, shutdownGracefully: false, vm: env.CC_VM], serverName: env.VM_SERVER
                vSphere buildStep: [$class: 'PowerOn', timeoutInSeconds: 180, vm: env.CC_VM], serverName: env.VM_SERVER
            }
        }   
        stage("Boot") {
            steps {
                node ("${env.CC_AGENT}") {
                    unstash 'scripts'
                    bat "ant boot -Daccept.license=true -Dbootstrap=$CC_BOOT"
                }
            }
        }   
        stage ('Up') {
            steps {
                node ("${env.CC_AGENT}") {
                    unstash 'scripts'
                    bat "ant tuneup credentials masters licenses -Denv=$CC_ENV"
                }
            }
        }   
        stage ('Download') {
            steps {
                node ("${env.CC_AGENT}") {
                    unstash 'scripts'
                    bat "ant test -Denv=$CC_ENV"
                    junit 'build/tests/**/TEST-*.xml'
                    bat "ant images installers mirrors -Denv=$CC_ENV"
                }
            }
        }                        
    }
}
