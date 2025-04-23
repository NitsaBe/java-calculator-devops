# Calculator DevOps Pipeline Project

A simple calculator web application with a complete DevOps pipeline implemented using Java, Spring Boot, Terraform, and GitHub Actions.

## Project Description

This project demonstrates a simplified DevOps pipeline for a Java Spring Boot calculator application. The application allows users to perform basic arithmetic operations through a web interface.

## Tools and Technologies Used

- **Java 21** - Programming language
- **Spring Boot 3.4.4** - Web application framework
- **Maven** - Build tool
- **Git & GitHub** - Version control and repository hosting
- **GitHub Actions** - CI/CD pipeline
- **Terraform** - Infrastructure as Code
- **Bash Scripts** - Deployment automation

## Application Features

The calculator web application provides:
- Addition
- Subtraction
- Multiplication
- Division
- Input validation and error handling

## CI/CD Pipeline

### Continuous Integration
- Automatic testing on push to dev branch
- Automatic testing on pull requests to main branch
- Tests include unit tests for controller and service classes

### Continuous Deployment
- Automatic build and deployment preparation on push to main branch
- Local deployment follows a blue-green deployment strategy
- Deployment scripts handle:
   - Staging deployment
   - Production promotion
   - Rollback capability
   - Health monitoring

### Infrastructure as Code
The project uses Terraform to manage the local deployment environment:
- Creation of staging and production directories
- Environment variable management
- Application configuration

## Deployment Workflow

1. Changes are pushed to dev branch
2. CI pipeline validates changes
3. Pull request is created to main branch
4. After PR approval and merge, CD pipeline builds the application
5. Manual deployment to staging using `deploy.sh`
6. Health check verifies staging deployment
7. Manual promotion to production using `promote_to_production.sh`
8. Health check verifies production deployment
9. If health check fails, automatic rollback using `rollback.sh`

## Local Setup Instructions

1. Clone the repository
```bash
git clone https://github.com/NitsaBe/java-calculator-devops.git
cd calculator-devops
```

2. Build the application
```bash
mvn clean package
```

3. Set up infrastructure with Terraform
```bash
cd terraform
terraform init
terraform apply
```

4. Deploy the application
```bash
./scripts/automated_deployment.sh
```

5. Access the application
- Staging: http://localhost:8081
- Production: http://localhost:8080

