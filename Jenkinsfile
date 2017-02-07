#!groovy​

pipeline {
    agent {
        label 'docker'
    }

    options {
        buildDiscarder(logRotator(numToKeepStr:'10'))
        disableConcurrentBuilds()
    }

    stages {
        stage("Build") {
            steps {
                timeout(time:10, unit:'MINUTES') {
                    sh 'docker-compose -p sagdevops-cc-server build --force-rm --no-cache --pull'
                }
            }
        }
        stage("Test") {
            steps {
                timeout(time:5, unit:'MINUTES') {
                    sh 'docker-compose -p sagdevops-cc-server run --rm test'
                }
            }
            post {
                always {
                    sh 'docker-compose -p sagdevops-cc-server stop'
                }
                success {
                    junit 'build/tests/**/TEST-*.xml'
                }
                unstable {
                    junit 'build/tests/**/TEST-*.xml'
                }
            }
        }
        stage("Deploy") {
            steps {
                //sh "docker tag sagcc/cce:9.12-internal daerepository03.eur.ad.sag:4443/ccdevops/cce:9.12-internal && docker images"
                //sh "docker push daerepository03.eur.ad.sag:4443/ccdevops/cce:9.12-internal"
                sh 'docker-compose -p sagdevops-cc-server up -d cc'
            }
        }        
    }
}
