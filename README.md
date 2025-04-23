# Calculator - DevOps Pipeline Project

This project implements a simple calculator web application using Spring Boot and Java 21, along with a complete DevOps pipeline implemented for local deployment.

## Project Overview

This calculator application provides basic arithmetic operations (addition, subtraction, multiplication, division) through a web interface. The project demonstrates DevOps principles including:

- Version control with Git
- CI/CD pipeline with GitHub Actions
- Infrastructure as Code using Terraform
- Automated testing
- Continuous deployment with blue-green deployment strategy
- Health monitoring

## Tools and Technologies Used

- Java 21
- Spring Boot 3.4.4
- Maven
- JUnit 5
- Git/GitHub
- GitHub Actions
- Terraform
- Bash scripting

## Project Structure

```
calculator/
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/example/calculator/
│   │   │       ├── controller/
│   │   │       │   └── CalculatorController.java
│   │   │       ├── service/
│   │   │       │   └── CalculatorService.java
│   │   │       └── CalculatorApplication.java
│   │   └── resources/
│   │       ├── templates/
│   │       │   └── calculator.html
│   │       └── application.properties
│   └── test/
│       └── java/
│           └── com/example/calculator/
│               ├── controller/
│               │   └── CalculatorControllerTest.java
│               └── service/
│                   └── CalculatorServiceTest.java
├── terraform/
│   ├── main.tf
│   └── scripts/
│       ├── automated_deployment.sh
│       ├── deploy.sh
│       ├── promote_to_production.sh
│       ├── rollback.sh
│       └── health_check.sh
├── .github/
│   └── workflows/
│       └── ci.yml
├── .gitignore
├── pom.xml
└── README.md
```

## CI/CD Pipeline Explanation

The CI/CD pipeline for this project consists of the following stages:

1. **Continuous Integration**:
   - Triggered by pushes to master/dev branches or PRs to master
   - Builds the application
   - Runs unit tests
   - Archives build artifacts and test results

2. **Infrastructure Provisioning**:
   - Terraform creates local deployment directories
   - Generates deployment, promotion, rollback, and health check scripts

3. **Continuous Deployment**:
   - Blue-Green deployment strategy
   - Deploys to staging environment first
   - Runs validation tests
   - Promotes to production if validation passes
   - Includes automated rollback mechanism if health checks fail

## Getting Started

### Prerequisites
- Java 21 JDK
- Maven
- Git
- Terraform
- IntelliJ IDEA

### Building and Running Locally

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/calculator.git
   cd calculator
   ```

2. Build with Maven:
   ```
   mvn clean package
   ```

3. Run the application:
   ```
   java -jar target/calculator-0.0.1-SNAPSHOT.jar
   ```

4. Access the calculator at: http://localhost:8080

### Executing the Deployment Pipeline

1. Make sure the application is built:
   ```
   mvn clean package
   ```

2. Run the automated deployment:
   ```
   cd terraform/scripts
   ./automated_deployment.sh
   ```

