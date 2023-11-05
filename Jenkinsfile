pipeline {
    agent any

     parameters {
        choice(name: 'choice', choices: ['build','deploy','destroy'], description: 'choose a value')
    }

    environment {
        ECR_REPO = '404405619113.dkr.ecr.eu-north-1.amazonaws.com'
    }

    stages {

        stage('Build') {
            when {
                expression {
                    params.choice == 'build'
                }
            }
            steps {
                sh "aws ecr get-login-password --region eu-north-1 | docker login --username AWS --password-stdin $ECR_REPO"
                dir('app') {
                    sh "docker build -t $ECR_REPO/app:latest ." 
                    sh "docker push $ECR_REPO/app:latest"
                    sh "docker rmi $ECR_REPO/app:latest"
                }
            }
        }

        stage('Terraform init') {
            when {
                expression {
                    params.choice == 'deploy' || params.choice == 'destroy'
                }
            }
            steps { 
                script {
                    withAWS(role:"jenkins", roleSessionName: "role", useNode: true){
                        dir('terraform') {
                            sh "terraform init"
                        }
                    }
                }
               
            }
        }

        stage('Deploy') {
            when {
                expression {
                    params.choice == 'deploy'
                }
            }
            steps { 
                script {
                    withAWS(role:"jenkins", roleSessionName: "role", useNode: true){
                        dir('terraform') {
                            sh "terraform plan -out=demo2.tfplan"
                            sh "terraform apply demo2.tfplan" 
                        }
                    }
                }
            }
        }
        
        stage('Destroy') {
            when {
                expression {
                    params.choice =='destroy'
                }
            }
            steps {
                script {
                    withAWS(role:"jenkins", roleSessionName: "role", useNode: true){
                        dir('terraform') {
                            sh "terraform plan -destroy -out=demo2.destroy.tfplan"
                            sh "terraform apply demo2.destroy.tfplan"
                        }
                    }
                }
            }
        }
    }
    post {
        always {
          cleanWs()
        }
}
}