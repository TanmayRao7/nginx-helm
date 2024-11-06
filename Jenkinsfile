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
                sh '''sed -i "s/tag: \\"[^\\"]*\\"/tag: \\"$IMAGE_TAG\\"/" application_set.yaml'''
                sh '''sed -i "s/homepageText: \\"[^\\"]*\\"/homepageText: \\"$CUSTOM_TEXT\\"/" application_set.yaml'''
                // sh '''sed -i "" "s/tag: \\"[^\\"]*\\"/tag: \\"$IMAGE_TAG\\"/" application_set.yaml'''
                // sh '''sed -i "" "s/homepageText: \\"[^\\"]*\\"/homepageText: \\"$CUSTOM_TEXT\\"/" application_set.yaml'''
                // sh '''sed -i "" "s/tag: \\"[^\\"]*\\"/tag: \\"$IMAGE_TAG\\"/" application_set.yaml'''
                // sh '''sed -i "" "s/homepageText: \\"[^\\"]*\\"/homepageText: \\"$CUSTOM_TEXT\\"/" application_set.yaml'''
                // // sh ''' /opt/homebrew/bin/yq -i '.tag = env.IMAGE_TAG' application_set.yaml '''
                // sh ''' /opt/homebrew/bin/yq -i '.homepageText = env.CUSTOM_TEXT' application_set.yaml '''
            }
        }
        
        stage('Check Configuration') {
            steps {
                sh '/usr/bin/git diff'
            }
        }
        
        stage('Commit') {
            steps {
                sh '/usr/bin/git add .'
                sh '/usr/bin/git commit -m "Updated with ${IMAGE_TAG}"'
                sh '/usr/bin/git push --set-upstream origin master'
            }
        }
        
        stage('Deploy') {
            steps {
                sh '/opt/homebrew/bin/kubectl apply -f application_set.yaml'
            }
        }
        
        stage('Sync') {
            steps {
                sh '/bin/sh deployment_check.sh nginx'
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
