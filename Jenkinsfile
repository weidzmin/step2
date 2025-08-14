pipeline {
    agent { label 'jenkins-worker' }
    
    environment {
        DOCKER_HUB_CREDENTIALS = credentials('dockerhub-credentials')
        DOCKER_IMAGE = 'ortoss/nodejs-app'
        DOCKER_TAG = "${BUILD_NUMBER}"
    }
    
    stages {
        stage('Pull Code') {
            steps {
                echo 'Pulling code from repository...'
                git branch: 'main', url: 'https://github.com/weidzmin/step2'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                script {
                    def image = docker.build("${DOCKER_IMAGE}:${DOCKER_TAG}")
                    env.DOCKER_IMAGE_ID = image.id
                }
            }
        }
        
        stage('Run Tests') {
            steps {
                echo 'Running tests in Docker container...'
                script {
                    try {
                        // Run tests inside the Docker container
                        sh """
                            docker run --rm ${DOCKER_IMAGE}:${DOCKER_TAG} test
                        """
                        env.TESTS_PASSED = 'true'
                    } catch (Exception e) {
                        env.TESTS_PASSED = 'false'
                        echo "Tests failed: ${e.getMessage()}"
                    }
                }
            }
        }
        
        stage('Push to Docker Hub') {
            when {
                environment name: 'TESTS_PASSED', value: 'true'
            }
            steps {
                echo 'Tests passed! Pushing image to Docker Hub...'
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'dockerhub-credentials') {
                        def image = docker.image("${DOCKER_IMAGE}:${DOCKER_TAG}")
                        image.push()
                        image.push("latest")
                    }
                }
            }
        }
        
        stage('Handle Test Failure') {
            when {
                environment name: 'TESTS_PASSED', value: 'false'
            }
            steps {
                echo 'Tests failed'
                error('Pipeline failed due to test failures')
            }
        }
    }
    
    post {
        always {
            echo 'Cleaning up...'
            script {
                // Clean up local Docker images
                sh """
                    docker rmi ${DOCKER_IMAGE}:${DOCKER_TAG} || true
                    docker system prune -f || true
                """
            }
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
