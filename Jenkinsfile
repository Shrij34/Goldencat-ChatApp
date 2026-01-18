pipeline {
  agent any

  environment {
    IMAGE_REPO  = "shrij34/chatapp"
    GIT_REPO    = "https://github.com/Shrij34/Goldencat-ChatApp.git"
    GIT_BRANCH  = "end"
  }

  stages {

    stage('Checkout App Repo') {
      steps {
        git branch: "${GIT_BRANCH}",
            url: "${GIT_REPO}",
            credentialsId: 'GitHub-token'
      }
    }

    stage('Build Jar') {
      steps {
        bat 'mvnw.cmd clean package -DskipTests'
      }
    }

    stage('Build Docker Image') {
      steps {
        script {
          env.IMAGE_TAG = "${BUILD_NUMBER}"
        }
        bat "docker build -t ${IMAGE_REPO}:${IMAGE_TAG} ."
      }
    }

    stage('Docker Login & Push') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          bat "docker login -u %DOCKER_USER% -p %DOCKER_PASS%"
          bat "docker push ${IMAGE_REPO}:${IMAGE_TAG}"
        }
      }
    }

    stage('Update Helm Image Tag') {
      steps {
        bat """
        cd gitops-helm-repo\\Goldencat-ChatApp
        powershell -Command "(Get-Content values.yaml) -replace 'tag:.*', 'tag: \\"${BUILD_NUMBER}\\"' | Set-Content values.yaml"
        git config user.email "jenkins@local"
        git config user.name "jenkins"
        git add values.yaml
        git commit -m "Update image tag to ${BUILD_NUMBER}"
        git push origin ${GIT_BRANCH}
        """
      }
    }
  }

  post {
    success {
      echo "✅ GitOps pipeline complete — ArgoCD will deploy automatically"
    }
  }
}









// pipeline {
//     agent any

//     environment {
//         // App
//         APP_IMAGE       = "shrij34/chatapp:latest"
        
//         //Dockerhub 
//         REG_IMAGE = "shrij34/chatapp:latest"


//         // Git
//         GIT_REPO        = "https://github.com/Shrij34/Goldencat-ChatApp.git"
//         GIT_BRANCH      = "end"

//         // MySQL (non-secret)
//         MYSQL_DATABASE  = "chatapp"
//         MYSQL_USER      = "chatuser"
//     }

//     stages {

//         stage('Pre-check Docker') {
//             steps {
//                 bat 'docker --version'
//                 bat 'docker-compose --version'
//             }
//         }

//         stage('Cleanup Old Containers') {
//             steps {
//                 echo "Stopping containers (DB volume preserved unless -v is used)"
//                 bat 'docker-compose down'
//             }
//         }

//         stage('Clone Repository') {
//             steps {
//                 git branch: "${GIT_BRANCH}",
//                     url: "${GIT_REPO}",
//                     credentialsId: 'GitHub-token'
//             }
//         }

//         stage('Build & Deploy with Docker Compose') {
//             steps {
//                 withCredentials([
//                     string(credentialsId: 'mysql-root-pass-id', variable: 'MYSQL_ROOT_PASSWORD'),
//                     string(credentialsId: 'mysql-user-pass-id', variable: 'MYSQL_PASSWORD')
//                 ]) {
//                     bat """
//                     set MYSQL_ROOT_PASSWORD=%MYSQL_ROOT_PASSWORD%
//                     set MYSQL_DATABASE=${MYSQL_DATABASE}
//                     set MYSQL_USER=${MYSQL_USER}
//                     set MYSQL_PASSWORD=%MYSQL_PASSWORD%

//                     docker-compose pull
//                     docker-compose build
//                     docker-compose up -d
//                     """
//                 }
//             }
//         }

//         stage('Verify Containers') {
//             steps {
//                 bat 'docker ps'
//             }
//         }
        
//         // stage("check trivy insatllation"){
//         //     steps{
//         //         bat "trivy --version"
//         //     }
//         // }   
//         // stage("trivy scan"){
//         //     steps {
//         //         script {
//         //     // Run Trivy scan, capture all output (stdout + stderr) into a text file
//         //                 bat "trivy image --exit-code 1 --severity HIGH,CRITICAL ${env.APP_IMAGE} > trivy-report.txt 2>&1"

//         //     // Also generate a JSON report for structured analysis
//         //                 bat "trivy image --exit-code 1 --severity HIGH,CRITICAL --format json -o trivy-report.json ${env.APP_IMAGE}"

//         //     // Archive both reports so they appear in Jenkins Artifacts
//         //                 archiveArtifacts artifacts: 'trivy-report.txt,trivy-report.json', fingerprint: true
//         //             }
//         //       }
//         // }
        
//         stage ("Docker login"){
//             steps{
//                 withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]){
//                     bat "docker logout"
//                     bat 'docker login -u %DOCKER_USER% -p %DOCKER_PASS%'
//                 }
//             }
//         }
            
//         stage('Tag & Push Image') {
//             steps {
//                 bat "docker tag ${env.APP_IMAGE} ${env.REG_IMAGE}"
//                 bat "docker push ${env.REG_IMAGE}"
//             }
//         }
        
//         stage('Health Check') {
//             steps {
//                 echo "Waiting for application health..."
//                 bat 'ping 127.0.0.1 -n 20 > nul'
//                 bat 'curl http://localhost:9090/actuator/health'
//             }
//         }
//     }

//     post {
//         success {
//             echo "✅ Deployment successful!"
//         }
//         failure {
//             echo "❌ Deployment failed!"
            
//             bat 'docker-compose logs --tail=50 > compose.log'

//             archiveArtifacts artifacts: 'compose.log', fingerprint: true
//         }
//         always {
//             echo "Pipeline finished"
//         }
//     }
// }


// pipeline {
//     agent any

//     environment {
//         APP_IMAGE = "chatapp:latest"
//         GIT_REPO = "https://github.com/Shrij34/Goldencat-ChatApp.git"
//         GIT_BRANCH = "end"
//         MYSQL_DATABASE = "chatapp"
//         MYSQL_USER = "chatuser"   // dedicated app user, not root
//     }
    
//     stages {
//         stage('Cleanup Containers') {
//             steps {
//                 bat "docker-compose down -v"
//             }
//         }

//         stage('Clone Repo') {
//             steps {
//                 git branch: "${env.GIT_BRANCH}", 
//                     url: "${env.GIT_REPO}", 
//                     credentialsId: 'GitHub-token'
//             }
//         }

//         stage('Build Docker Image') {
//             steps {
//                 script {
//                     docker.build("${env.APP_IMAGE}")
//                 }
//             }
//         }

//         stage('Run Docker Compose') {
//             steps {
//                 withCredentials([
//                     string(credentialsId: 'mysql-root-pass-id', variable: 'MYSQL_ROOT_PASSWORD'),
//                     string(credentialsId: 'mysql-user-pass-id', variable: 'MYSQL_PASSWORD')
//                 ]) {
//                     bat """
//                     set MYSQL_ROOT_PASSWORD=%MYSQL_ROOT_PASSWORD%
//                     set MYSQL_DATABASE=${env.MYSQL_DATABASE}
//                     set MYSQL_USER=${env.MYSQL_USER}
//                     set MYSQL_PASSWORD=%MYSQL_PASSWORD%
//                     docker-compose up -d --build
//                     """
//                 }
//             }
//         }
//     }
// }



// pipeline {
//     agent any

//     environment {
//         // App
//         APP_IMAGE       = "shrij34/chatapp:latest"
        
//         //Dockerhub 
//         REG_IMAGE = "shrij34/chatapp:latest"


//         // Git
//         GIT_REPO        = "https://github.com/Shrij34/Goldencat-ChatApp.git"
//         GIT_BRANCH      = "end"

//         // MySQL (non-secret)
//         MYSQL_DATABASE  = "chatapp"
//         MYSQL_USER      = "chatuser"
//     }

//     stages {

//         stage('Pre-check Docker') {
//             steps {
//                 bat 'docker --version'
//                 bat 'docker-compose --version'
//             }
//         }

//         stage('Cleanup Old Containers') {
//             steps {
//                 echo "Stopping containers (DB volume preserved unless -v is used)"
//                 bat 'docker-compose down'
//             }
//         }

//         stage('Clone Repository') {
//             steps {
//                 git branch: "${GIT_BRANCH}",
//                     url: "${GIT_REPO}",
//                     credentialsId: 'GitHub-token'
//             }
//         }

//         stage('Build & Deploy with Docker Compose') {
//             steps {
//                 withCredentials([
//                     string(credentialsId: 'mysql-root-pass-id', variable: 'MYSQL_ROOT_PASSWORD'),
//                     string(credentialsId: 'mysql-user-pass-id', variable: 'MYSQL_PASSWORD')
//                 ]) {
//                     bat """
//                     set MYSQL_ROOT_PASSWORD=%MYSQL_ROOT_PASSWORD%
//                     set MYSQL_DATABASE=${MYSQL_DATABASE}
//                     set MYSQL_USER=${MYSQL_USER}
//                     set MYSQL_PASSWORD=%MYSQL_PASSWORD%

//                     docker-compose pull
//                     docker-compose build
//                     docker-compose up -d
//                     """
//                 }
//             }
//         }

//         stage('Verify Containers') {
//             steps {
//                 bat 'docker ps'
//             }
//         }
        
        
//         stage ("Docker login"){
//             steps{
//                 withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]){
//                     bat "docker logout"
//                     bat 'docker login -u %DOCKER_USER% -p %DOCKER_PASS%'
//                 }
//             }
//         }
            
//         stage('Tag & Push Image') {
//             steps {
//                 bat "docker tag ${env.APP_IMAGE} ${env.REG_IMAGE}"
//                 bat "docker push ${env.REG_IMAGE}"
//             }
//         }
        
//         stage('Health Check') {
//             steps {
//                 echo "Waiting for application health..."
//                 bat 'ping 127.0.0.1 -n 20 > nul'
//                 bat 'curl http://localhost:9090/actuator/health'
//             }
//         }
//     }

//     post {
//         success {
//             echo "✅ Deployment successful!"
//         }
//         failure {
//             echo "❌ Deployment failed!"
            
//             bat 'docker-compose logs --tail=50 > compose.log'

//             archiveArtifacts artifacts: 'compose.log', fingerprint: true
//         }
//         always {
//             echo "Pipeline finished"
//         }
//     }
// }
