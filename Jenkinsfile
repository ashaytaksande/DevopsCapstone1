pipeline {
    agent 'any'
    environment {
        ProductionServer = 'ubuntu@ec2-23-22-136-100.compute-1.amazonaws.com'
        TestServer = 'ubuntu@ec2-52-200-131-115.compute-1.amazonaws.com'
        BuildServer = 'ubuntu@ec2-54-226-57-1.compute-1.amazonaws.com'
        DockerCred = credentials('dockercred')
        version = "${env.BUILD_ID}-${env.GIT_COMMIT.substring(0, 5)}"
        branchName = "${env.GIT_BRANCH.split('/').size() == 1 ? env.GIT_BRANCH.split('/')[-1] : env.GIT_BRANCH.split('/')[1..-1].join('/')}"
    }
    stages {
        stage('Job1: build - If commit is made to develop branch, just build the product, do not publish."') {
            agent {
                label 'BuildServer'
            }
            steps {
                sh '''
                docker build -t ashayalmighty/website:${version} .
                docker save -o website-${version}.tar ashayalmighty/website:${version}
                '''
            }
        }
        stage('Push to test server') {
            agent {
                label 'BuildServer'
            }
            steps {
                sh '''
                docker build -t ashayalmighty/website:${version} .
                docker save -o website-${version}.tar ashayalmighty/website:${version}
                rsync -azPpr -e ssh website-${version}.tar ${TestServer}:/home/ubuntu/
                '''
            }            
        } 
        stage('Job2: test - Test the docker image') {
            agent {
                label 'TestServer'
            }
            steps {
                sh '''
                cd /home/ubuntu/
                docker load -i website-${version}.tar
                echo $DockerCred_PSW | sudo docker login -u $DockerCred_USR --password-stdin
                docker push website-${version}         
                echo 'Perform tests'
                echo 'tests sucessful'
                '''
        } 
            stage('If commit is made to master branch, push the image from TestServer to Production server after passing all the tests') {
            agent {
                label 'TestServer'
            }
            when {
                expression {
                    branchName == 'master'
                }
            }
            steps {
                sh '''
                rsync -azPpr -e ssh website-${version}.tar ${ProductionServer}:/home/ubuntu/
                '''
            }
            }
            stage('publish website') {
                agent {
                    label 'publish'
                }
                when {
                    expression {
                        branchName == 'master'
                    }
                }            
                steps {
                    sh '''
                    cd /home/ubuntu/
                    docker load -i website-${version}.tar
                    docker rm -f website
                    docker run -d -p 82:80 --name website ashayalmighty/website:${version}
                    '''
                }
            }
    }
}