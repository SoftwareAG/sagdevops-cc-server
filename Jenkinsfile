#!/usr/bin/env groovy

// https://jenkins.io/doc/book/pipeline/shared-libraries/
// TODO: move to a Jenkins CC library

// curl -X POST -F "jenkinsfile=<Jenkinsfile" http://ccbvtauto.eur.ad.sag:8080/pipeline-model-converter/validate

def installAntcc () {
    if (isUnix()) {
        sh "antcc/bootstrap/install.sh"
    } else {
        powershell "antcc/bootstrap/install.ps1"
    }
}

def ant (command) {
    if (isUnix()) {
        sh "ant $command"
    } else {
        bat "ant $command"
    }
}

def restartVMs(propfile) {
    def props = readProperties file: propfile
    def vms = props['vm.names']?.split(',')
    def vmserver = props['vm.server']
    def vmwait = props['vm.wait']?.toInteger()

    if (!vmserver) {
        error message: "Required vm.server, vm.names properties are not set in ${params.CC_ENV} env.properties file"
    }

    def builders = [:]
    for (x in vms) {
        def vm = x
        builders[vm] = {
            node('master') {
                vSphere buildStep: [$class: 'PowerOff', evenIfSuspended: false, shutdownGracefully: false, vm: vm], serverName: vmserver
                vSphere buildStep: [$class: 'PowerOn', timeoutInSeconds: 180, vm: vm], serverName: vmserver
                sleep vmwait
            }
        }                        
    }
    parallel builders // run in parallel
}

def test(propfile) {
    def props = readProperties file: propfile
    def vms = props['vm.names']?.split(',')
    def vmdomain = props['vm.domain']
    def builders = [:]
    for (x in vms) {
        def label = x + vmdomain // Need to bind the label variable before the closure - can't do 'for (label in labels)'
        builders[label] = {
            node(label) {
                unstash 'scripts'

                installAntcc()

                ant '-Daccept.license=true boot'
                ant 'up test'
                junit 'build/tests/**/TEST-*.xml'
            }
        }                        
    }
    parallel builders // kick off parallel provisioning    
}

pipeline {
    agent {
        label 'master'
    }
    environment {
        SAG_AQUARIUS = 'aquarius-bg.eur.ad.sag'
        CC_INSTALLER_URL = "http://aquarius-bg.eur.ad.sag/cc/installers" // internal download site
        CC_VERSION = '10.3-milestone'
        CC_PASSWORD = 'manage'
        CC_BOOT = 'staging'
        CC_ENV = 'staging'     // your custom env config        
        CC_ENV_FILE = "environments/staging/env.properties"
        EMPOWER = credentials('empower')
    }
    stages {
        stage("Prepare") {
            steps {
                stash 'scripts'
            }
        }        
        stage ('Restart VMs') { 
            steps {
                script {
                    restartVMs env.CC_ENV_FILE
                }              
            }
        }  
        stage ('Platform Test') {
            steps {
                script {
                    test env.CC_ENV_FILE
                }         
            }
        }     
    }
}
