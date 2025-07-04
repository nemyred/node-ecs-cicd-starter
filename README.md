Sprint Freight CI/CD Project
A streamlined CI/CD pipeline for a Node.js application with MySQL, utilizing GitHub Actions, Docker, Terraform, and AWS ECS/ECR for automated testing, deployment, and rollback.

Objectives

Automate testing, building, and deployment of a Node.js application
Deploy to AWS ECS (Fargate) with zero-downtime and rollback support
Securely manage database credentials using AWS Secrets Manager


Tech Stack

Node.js 18 + Express
MySQL (AWS RDS)
Docker for containerization
GitHub Actions for CI/CD
Terraform for infrastructure
AWS ECS/ECR/RDS/Secrets Manager for deployment and configuration


Repository Structure
cicd-project/
├── .github/workflows/          # CI/CD workflows
│   ├── ci.yml                  # PR-based testing/linting
│   ├── deploy-staging.yml      # Auto-deploy to staging
│   ├── deploy-production.yml   # Auto-deploy to production
│   └── rollback.yml            # Rollback on failure
├── src/                        # Application code
│   ├── index.js                # Node.js app entry
│   ├── index.test.js           # Jest test file
│   └── package.json            # Dependencies
├── terraform/                  # Infrastructure
│   ├── main.tf                 # VPC, ECS, RDS, IAM
│   └── modules/                # Reusable modules
├── Dockerfile                  # Docker image config
├── .eslintrc.json              # ESLint config
├── task-definition.json        # ECS task definition
└── README.md                   # Project guide


Setup Instructions
1. Prerequisites
Install required tools:
sudo apt install nodejs npm docker.io awscli unzip

Install Terraform:
wget https://releases.hashicorp.com/terraform/1.5.7/terraform_1.5.7_linux_amd64.zip
unzip terraform_1.5.7_linux_amd64.zip
sudo mv terraform /usr/local/bin/

Verify versions:
node -v
npm -v
docker --version
aws --version
terraform version

2. Clone & Install
git clone https://github.com/nemyred/node-ecs-cicd-starter
cd cicd-project
npm install --prefix src

3. Provision AWS Infrastructure
aws configure  # Set credentials & region (us-east-1)
cd terraform
terraform init
terraform apply  # Confirm with "yes"

Provisions:

VPC with public/private subnets
ECS Cluster (sprint-freight-cluster)
ECR Repository
RDS MySQL instance (sprint-freight-db, database: testdb)
IAM roles and CloudWatch logs

Verify:
aws ecs list-clusters
aws ecr describe-repositories
aws rds describe-db-instances --db-instance-identifier sprint-freight-db

4. Configure Secrets
Create DB credentials in AWS Secrets Manager:
aws secretsmanager create-secret \
  --name sprint-freight-db-credentials \
  --secret-string '{"username":"user","password":"password","host":"sprint-freight-db.c6pco4s0qkp5.us-east-1.rds.amazonaws.com","port":"3306","database":"testdb"}' \
  --region us-east-1

Attach SecretsManager policy to ECS role:
aws iam attach-role-policy \
  --role-name ECSTaskExecutionRole \
  --policy-arn arn:aws:iam::aws:policy/SecretsManagerReadWrite

5. Set GitHub Secrets
Get AWS Account ID:
aws sts get-caller-identity

In GitHub > Settings > Secrets, add:

AWS_ACCOUNT_ID
AWS_REGION (e.g., us-east-1)

Ensure OIDC role (GitHubActionsRole) has ECS/ECR access.
6. Run Locally
Set environment variables:
export DB_HOST=localhost
export DB_PORT=3306
export DB_USERNAME=user
export DB_PASSWORD=password
export DB_DATABASE=testdb
export PORT=3000

Start the app:
npm start --prefix src

Access at: http://localhost:3000

CI/CD Pipeline
CI Workflow (ci.yml)

Trigger: Pull requests to main
Actions: Runs Jest tests and ESLint with MySQL container

Deploy to Staging (deploy-staging.yml)

Trigger: Push to main
Actions:
Build/push Docker image to ECR
Deploy to sprint-freight-staging-service
Health check /health (180s start period)
Rollback to sprint-freight-staging-prev on failure



Deploy to Production (deploy-production.yml)

Trigger: Push to production
Actions:
Build/push Docker image to ECR
Deploy to sprint-freight-production-service
Health checks and rollback enabled



Rollback Workflow (rollback.yml)

Trigger: Failure in staging/production
Actions: Revert to previous task definition


AWS Environment
Staging

Service: sprint-freight-staging-service
Task Definition: sprint-freight-staging
Env Vars: PORT=3000 (DB via Secrets Manager)
Rollback: sprint-freight-staging-prev
Resources: 0.25 vCPU, 1024MB
Health Check: /health, 15s timeout, 5 retries, 180s start period

Production

Service: sprint-freight-production-service
Task Definition: sprint-freight-production
Env Vars: PORT=3000, NODE_ENV=production
Rollback: sprint-freight-production-prev
Resources: 0.25 vCPU, 1024MB
Health Check: Same as staging

Database (RDS MySQL)

Identifier: sprint-freight-db
DB Name: testdb
Credentials: Secured via Secrets Manager


Best Practices

Protect main and production branches
Use Secrets Manager for sensitive data
Define ECS health checks
Implement rollback mechanisms
Separate staging/production logic


Troubleshooting



Issue
Fix



Terraform fails
Verify AWS credentials, run terraform init


GitHub Action fails
Check GitHub secrets, OIDC role, Secrets Manager


ECS task unhealthy
Adjust health check, increase memory or startPeriod


DB connection failed
Verify RDS security group and endpoint


Logs not showing
Use AWS CLI v2, run aws logs tail


CLI version errors
Upgrade to AWS CLI v2



Running the Pipeline
Feature Branch
git checkout -b feature/my-feature
# Make changes
git commit -am "Add feature"
git push origin feature/my-feature
gh pr create

Merge to Staging
git checkout main
git merge feature/my-feature
git push origin main  # Triggers staging deploy

Deploy to Production
git checkout production
git merge main
git push origin production  # Triggers production deploy

Monitor
aws ecs describe-services \
  --cluster sprint-freight-cluster \
  --services sprint-freight-staging-service sprint-freight-production-service

aws logs tail /ecs/sprint-freight-staging --follow --region us-east-1
aws logs tail /ecs/sprint-freight-production --follow --region us-east-1


Submission

Repository: https://github.com/nemyred/node-ecs-cicd-starter
Documentation: This README.md, Terraform, and workflow comments


Credits
Built by @nemyred to demonstrate Node.js deployment automation with GitHub Actions and AWS.
