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

## CI/CD Pipeline Explanation

### Continuous Integration (CI)

The CI pipeline runs on every push to the `dev` branch and on pull requests to the `main` branch. It performs the following steps:

1. Checkout the code repository
2. Set up Java 21 environment
3. Build the application using Maven
4. Run unit tests

### Continuous Deployment (CD)

The CD pipeline runs on every push to the `main` branch and performs these steps:

1. Checkout the code repository
2. Set up Java 21 environment
3. Build the application using Maven (skipping tests)
4. Create a deployment package with JAR file and scripts
5. Archive the deployment package as an artifact

### Local Deployment Process

1. **Staging Deployment**: The `deploy.sh` script copies the JAR file to the staging directory and starts the application on port 8081.
2. **Health Checks**: The `health_check.sh` script verifies that both staging and production environments are responding correctly.
3. **Production Deployment**: If staging is healthy, the `promote_to_production.sh` script:
   - Backs up the current production version
   - Stops the production instance
   - Copies the staging version to production
   - Starts the production instance on port 8080
4. **Rollback**: If needed, the `rollback.sh` script restores the previous production version.

## Infrastructure as Code

The project uses Terraform to manage the local deployment environment:

- Creates and manages directories for staging, production, backup, and logs
- Ensures consistent environment structure
- Provides clear output of directory locations

## Setup and Deployment
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


2. Initialize Terraform:
```bash
   cd terraform
   terraform init
   terraform apply
   ```

3. Build the application:
```bash
   mvn clean package
   ```

4. Deploy to staging:
```bash
   ./scripts/deploy.sh
   ```

5. Check application health:
```bash
   ./scripts/health_check.sh
   ```

6. Promote to production:
```bash
   ./scripts/promote_to_production.sh
   ```

### Accessing the Application

- Staging: http://localhost:8081
- Production: http://localhost:8080
