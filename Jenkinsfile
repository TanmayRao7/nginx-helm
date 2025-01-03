pipeline {
    agent any

    parameters {
        choice(name: 'ENV', choices: ['dev', 'test', 'stage', 'prod'], description: 'Choose the deployment environment')
        string(name: 'IMAGE_TAG', defaultValue: '', description: 'Specify the image tag') 
        string(name: 'CUSTOM_TEXT', defaultValue: '', description: 'Custom text for configuration') 
    }

    stages {
        stage('Git Checkout') {
            steps {
                git branch: 'master', changelog: false, poll: false, url: 'https://github.com/TanmayRao7/nginx-helm.git'
            }
        }
        
        stage('Modify Configuration') {
            steps {
                sh """
                    yq -i '.image.tag = "${IMAGE_TAG}"' nginx-chart/values.yaml 
                    yq -i '.custom.homepageText = "${CUSTOM_TEXT}"' nginx-chart/values.yaml
                """
            }
        }
        
        stage('Check Configuration') {
            steps {
                sh '/usr/bin/git diff'
            }
        }
        
        stage('Commit') {
            steps {
                withCredentials([gitUsernamePassword(credentialsId: 'git-new', gitToolName: 'Default')]) {
                    sh 'git config --global user.name "${GIT_USERNAME}"'
                    sh 'git config --global user.password "${GIT_PASSWORD}"'
                    sh 'git add .'
                    sh 'git commit -m "Updated with ${IMAGE_TAG}"'
                    sh 'git push --set-upstream origin master'   
                }
            }
        }
        
        stage('Deploy') {
            steps {
                withKubeConfig(caCertificate: '', clusterName: '', contextName: '', credentialsId: 'kubeconfig-kind', namespace: '', restrictKubeConfigAccess: false, serverUrl: '') {
                    sh 'kubectl apply -f application_set.yaml'
                }
            }
        }
        
        // stage('Argocd Login') {
        //     steps {
        //         withKubeConfig(caCertificate: '', clusterName: '', contextName: '', credentialsId: 'kubeconfig-kind', namespace: '', restrictKubeConfigAccess: false, serverUrl: '') {
        //             sh ''' ARGOCD_PASS="$(kubectl -n argocd  get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d)" 
        //                   argocd login argocd-server.argocd.svc.cluster.local --username='admin' --password='$ARGOCD_PASS' --skip-test-tls --insecure
        //                   argocd app list
        //             '''
        //         }
        //     }
        // }
        
        stage('Sync') {
            steps {
                sh '/bin/sh argocd app sync nginx -o tree=detailed'
                sh '/bin/sh argocd app wait nginx --health --timeout 120'
            }
        }

        stage('Deploy to Dev') {
            when {
                expression { params.ENV == 'dev' }
            }
            steps {
                input message: 'Promote To Dev', parameters: [choice(choices: ['Yes', 'No'], name: 'Do you want to promote to dev')], submitter: 'admin'
                sh 'echo "Deployment to dev"'
            }
        }

        stage('Deploy to Test') {
            when {
                expression { params.ENV == 'test' }
            }
            steps {
                input message: 'Promote To Test', parameters: [choice(choices: ['Yes', 'No'], name: 'Do you want to promote to test')], submitter: 'admin'
                sh 'echo "Deployment to test"'
            }
        }

        stage('Deploy to Stage') {
            when {
                expression { params.ENV == 'stage' }
            }
            steps {
                input message: 'Promote To Stage', parameters: [choice(choices: ['Yes', 'No'], name: 'Do you want to promote to stage')], submitter: 'admin'
                sh 'echo "Deployment to stage"'
            }
        }

        stage('Deploy to Production') {
            when {
                expression { params.ENV == 'prod' }
            }
            steps {
                input message: 'Promote To Production', parameters: [choice(choices: ['Yes', 'No'], name: 'Do you want to promote to prod')], submitter: 'admin'
                sh 'echo "Deployment to production"'
            }
        }
    }
}
