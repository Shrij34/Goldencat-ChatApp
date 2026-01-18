pipeline {
    agent any

    environment {
        // App
        APP_IMAGE       = "shrij34/chatapp:latest"
        
        //Dockerhub 
        REG_IMAGE = "shrij34/chatapp:latest"


        // Git
        GIT_REPO        = "https://github.com/Shrij34/Goldencat-ChatApp.git"
        GIT_BRANCH      = "end"

        // MySQL (non-secret)
        MYSQL_DATABASE  = "chatapp"
        MYSQL_USER      = "chatuser"
    }

    stages {

        stage('Pre-check Docker') {
            steps {
                bat 'docker --version'
                bat 'docker-compose --version'
            }
        }

        stage('Cleanup Old Containers') {
            steps {
                echo "Stopping containers (DB volume preserved unless -v is used)"
                bat 'docker-compose down'
            }
        }

        stage('Clone Repository') {
            steps {
                git branch: "${GIT_BRANCH}",
                    url: "${GIT_REPO}",
                    credentialsId: 'GitHub-token'
            }
        }

        stage('Build & Deploy with Docker Compose') {
            steps {
                withCredentials([
                    string(credentialsId: 'mysql-root-pass-id', variable: 'MYSQL_ROOT_PASSWORD'),
                    string(credentialsId: 'mysql-user-pass-id', variable: 'MYSQL_PASSWORD')
                ]) {
                    bat """
                    set MYSQL_ROOT_PASSWORD=%MYSQL_ROOT_PASSWORD%
                    set MYSQL_DATABASE=${MYSQL_DATABASE}
                    set MYSQL_USER=${MYSQL_USER}
                    set MYSQL_PASSWORD=%MYSQL_PASSWORD%

                    docker-compose pull
                    docker-compose build
                    docker-compose up -d
                    """
                }
            }
        }

        stage('Verify Containers') {
            steps {
                bat 'docker ps'
            }
        }
        
        
        stage ("Docker login"){
            steps{
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]){
                    bat "docker logout"
                    bat 'docker login -u %DOCKER_USER% -p %DOCKER_PASS%'
                }
            }
        }
            
        stage('Tag & Push Image') {
            steps {
                bat "docker tag ${env.APP_IMAGE} ${env.REG_IMAGE}"
                bat "docker push ${env.REG_IMAGE}"
            }
        }
        
        stage('Health Check') {
            steps {
                echo "Waiting for application health..."
                bat 'ping 127.0.0.1 -n 20 > nul'
                bat 'curl http://localhost:9090/actuator/health'
            }
        }
    }

    post {
        success {
            echo "✅ Deployment successful!"
        }
        failure {
            echo "❌ Deployment failed!"
            
            bat 'docker-compose logs --tail=50 > compose.log'

            archiveArtifacts artifacts: 'compose.log', fingerprint: true
        }
        always {
            echo "Pipeline finished"
        }
    }
}
