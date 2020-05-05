pipeline {
    agent any
    environment {
        //be sure to replace "willbla" with your own Docker Hub username
        DOCKER_IMAGE_NAME = "iproute36/my-app"
    }
    stages {
        stage('Build') {
            steps {
                echo 'Running build automation'
                sh './gradlew build --no-daemon'
                archiveArtifacts artifacts: 'dist/trainSchedule.zip'
            }
        }
        stage('Build Docker Image') {
            when {
                branch 'master'
            }
            steps {
                script {
                    app = docker.build(DOCKER_IMAGE_NAME)
                    app.inside {
                        sh 'echo Hello, World!'
                    }
                }
            }
        }
        stage('Push Docker Image') {
            when {
                branch 'master'
            }
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'docker-creds') {
                        app.push("${env.BUILD_NUMBER}")
                        app.push("latest")
                    }
                }
            }
        }
		stage('analyze') {
			steps {
				sh 'echo "docker.io/iproute36/my-app:latest `pwd`/Dockerfile" > anchore_images'
				anchore name: 'anchore_images'
			}
		}
		stage('teardown') {
			steps {
				sh'''
					for i in `cat anchore_images | awk '{print $1}'`;do docker rmi $i; done
				'''
			}
		}
        stage('Trigger DockerBenchSecurity Compliance') {
            steps {
             retry(3) {
                echo "Trigger DockerBenchSecurity Compliance"
                build job: 'bench-security'
                }
            }
        }
        stage('DeployToProduction') {
            when {
                branch 'master'
            }
            steps {
                kubernetesDeploy(
                    kubeconfigId: 'kubeconfig',
                    configs: 'train-schedule-kube.yml',
                    enableConfigSubstitution: true
                )
            }
        }
    }
}
