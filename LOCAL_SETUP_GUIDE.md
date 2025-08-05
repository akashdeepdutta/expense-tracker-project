# Local Setup Guide - Expense Tracker with Receipt Scanning

This guide provides step-by-step instructions to set up and run the Expense Tracker application locally on your machine.

## 📋 Prerequisites

Before starting, ensure you have the following installed:

### Required Software
- **Java 17 or higher** (OpenJDK or Oracle JDK)
- **Node.js 16 or higher** and npm
- **Maven 3.6 or higher**


### Optional Software
- **Git** (for version control)
- **IDE** (IntelliJ IDEA, Eclipse, VS Code)
- **Postman** (for API testing)

## 🔍 Verify Prerequisites

### Check Java Installation
```bash
java -version
# Should show Java 17 or higher
```

### Check Node.js Installation
```bash
node --version
# Should show v16 or higher
npm --version
# Should show v8 or higher
```

### Check Maven Installation
```bash
mvn --version
# Should show Maven 3.6 or higher
```

## 🚀 Quick Start (Automated Setup)

### For Windows Users
```bash
# Navigate to project directory
cd expense-tracker-project

# Run the setup script
setup.bat
```

### For Linux/Mac Users
```bash
# Navigate to project directory
cd expense-tracker-project

# Make script executable
chmod +x setup.sh

# Run the setup script
./setup.sh
```

## 📦 Manual Setup Steps

If the automated setup doesn't work or you prefer manual setup, follow these steps:

### Step 1: Clone/Download the Project
```bash
# If using Git
git clone <repository-url>
cd expense-tracker-project

# Or download and extract the project files
```

### Step 2: Backend Setup

#### 2.1 Navigate to Backend Directory
```bash
cd backend
```

#### 2.2 Build the Spring Boot Application
```bash
# Clean and compile
mvn clean compile

# Run tests
mvn test

# Build the JAR file
mvn package -DskipTests
```

#### 2.3 Start the Backend Server
```bash
# Option 1: Run with Maven
mvn spring-boot:run

# Option 2: Run the JAR file
java -jar target/expense-tracker-0.0.1-SNAPSHOT.jar

# Option 3: Run with specific profile
mvn spring-boot:run -Dspring-boot.run.profiles=dev
```

#### 2.4 Verify Backend is Running
- Open browser and go to: `http://localhost:8080`
- You should see the Spring Boot welcome page
- H2 Console: `http://localhost:8080/h2-console`
  - JDBC URL: `jdbc:h2:mem:expensedb`
  - Username: `sa`
  - Password: (leave empty)

### Step 3: Frontend Setup

#### 3.1 Navigate to Frontend Directory
```bash
# From project root
cd frontend
```

#### 3.2 Install Dependencies
```bash
# Install all required packages
npm install

# Or if you prefer yarn
yarn install
```

#### 3.3 Start the Frontend Development Server
```bash
# Start the React development server
npm start

# Or with yarn
yarn start
```

#### 3.4 Verify Frontend is Running
- Open browser and go to: `http://localhost:3000`
- You should see the Expense Tracker application

## 🔧 Configuration

### Backend Configuration

The backend configuration is in `backend/src/main/resources/application.yml`:

```yaml
server:
  port: 8080
  servlet:
    context-path: /api

spring:
  datasource:
    url: jdbc:h2:mem:expensedb
    driver-class-name: org.h2.Driver
    username: sa
    password: 
  
  h2:
    console:
      enabled: true
      path: /h2-console

  jpa:
    hibernate:
      ddl-auto: create-drop
    show-sql: true
    properties:
      hibernate:
        format_sql: true

# JWT Configuration
jwt:
  secret: your-secret-key-here
  expiration: 86400000 # 24 hours

# OCR Configuration
tesseract:
  data-path: /usr/share/tesseract-ocr/4.00/tessdata
  language: eng

# File Upload Configuration
spring:
  servlet:
    multipart:
      max-file-size: 10MB
      max-request-size: 10MB
```

### Frontend Configuration

The frontend configuration is in `frontend/src/services/api.ts`:

```typescript
// API base URL
const API_BASE_URL = 'http://localhost:8080/api';

// Configure axios
const api = axios.create({
  baseURL: API_BASE_URL,
  timeout: 10000,
});
```

## 🧪 Testing the Application

### 1. Backend API Testing

#### Test with cURL
```bash
# Test health endpoint
curl http://localhost:8080/api/actuator/health

# Test expenses endpoint
curl http://localhost:8080/api/expenses

# Test with authentication
curl -H "Authorization: Bearer YOUR_JWT_TOKEN" http://localhost:8080/api/expenses
```

#### Test with Postman
1. Import the API collection (if available)
2. Set base URL: `http://localhost:8080/api`
3. Test endpoints:
   - `GET /expenses`
   - `POST /auth/login`
   - `POST /expenses/scan-receipt`

### 2. Frontend Testing

#### Manual Testing
1. Open `http://localhost:3000`
2. Test the following features:
   - User registration/login
   - Adding expenses manually
   - Receipt scanning (upload image)
   - Viewing expense list
   - Analytics dashboard

#### Automated Testing
```bash
# Run frontend tests
cd frontend
npm test

# Run with coverage
npm test -- --coverage
```

### 3. OCR Testing

#### Test Receipt Scanning
1. Prepare a receipt image (JPEG, PNG, GIF, BMP)
2. Go to the Receipt Scanner page
3. Upload the image
4. Verify OCR data extraction

#### Test with Sample Receipts
```bash
# Create test receipts directory
mkdir -p test-receipts

# Add sample receipt images for testing
# Test with different receipt formats and qualities
```

## 🐛 Troubleshooting

### Common Issues and Solutions

#### Backend Issues

**Issue: Port 8080 already in use**
```bash
# Find process using port 8080
netstat -ano | findstr :8080  # Windows
lsof -i :8080                 # Linux/Mac

# Kill the process
kill -9 <PID>

# Or use different port
mvn spring-boot:run -Dspring-boot.run.arguments=--server.port=8081
```

**Issue: Java version not found**
```bash
# Set JAVA_HOME environment variable
export JAVA_HOME=/path/to/your/java  # Linux/Mac
set JAVA_HOME=C:\path\to\your\java   # Windows
```

**Issue: Maven dependencies not downloading**
```bash
# Clean and reinstall dependencies
mvn clean install -U

# Check Maven settings
mvn help:effective-settings
```

#### Frontend Issues

**Issue: Port 3000 already in use**
```bash
# Use different port
npm start -- --port 3001

# Or kill existing process
npx kill-port 3000
```

**Issue: Node modules not found**
```bash
# Clear npm cache
npm cache clean --force

# Delete node_modules and reinstall
rm -rf node_modules package-lock.json
npm install
```

**Issue: CORS errors**
```bash
# Check if backend is running on correct port
# Verify API_BASE_URL in frontend configuration
# Ensure backend CORS configuration is correct
```

#### OCR Issues

**Issue: Tesseract not found**
```bash
# Install Tesseract OCR

# Ubuntu/Debian
sudo apt-get install tesseract-ocr

# macOS
brew install tesseract

# Windows
# Download from: https://github.com/UB-Mannheim/tesseract/wiki
```

**Issue: OCR data path not found**
```bash
# Update application.yml with correct Tesseract data path
tesseract:
  data-path: /usr/share/tesseract-ocr/4.00/tessdata  # Linux
  data-path: /usr/local/share/tessdata               # macOS
  data-path: C:\Program Files\Tesseract-OCR\tessdata # Windows
```

## 📊 Monitoring and Logs

### Backend Logs
```bash
# View application logs
tail -f logs/application.log

# View Spring Boot logs in console
# Logs appear in the terminal where you started the application
```

### Frontend Logs
```bash
# View React development server logs
# Logs appear in the terminal where you ran npm start

# Check browser console for frontend errors
# Press F12 in browser to open developer tools
```

### Database Monitoring
```bash
# Access H2 Console
# Open browser: http://localhost:8080/h2-console

# Connection details:
# JDBC URL: jdbc:h2:mem:expensedb
# Username: sa
# Password: (leave empty)
```

## 🔄 Development Workflow

### 1. Making Backend Changes
```bash
# The application will auto-reload with Spring Boot DevTools
# Just save your changes and the server will restart automatically

# Or manually restart
# Stop the server (Ctrl+C) and run again
mvn spring-boot:run
```

### 2. Making Frontend Changes
```bash
# React development server has hot reload
# Changes are automatically reflected in the browser

# If hot reload doesn't work, refresh the browser
```

### 3. Database Changes
```bash
# For schema changes, update the JPA entities
# The application will auto-create tables on startup

# To reset database
# Stop the application and restart
# H2 in-memory database is recreated each time
```

## 🚀 Production Considerations

### For Production Deployment
1. **Database**: Use PostgreSQL or MySQL instead of H2
2. **File Storage**: Use cloud storage (AWS S3, Google Cloud Storage)
3. **Security**: Configure proper JWT secrets and HTTPS
4. **Monitoring**: Add application monitoring and logging
5. **Performance**: Configure connection pools and caching

### Environment Variables
```bash
# Set environment variables for production
export SPRING_PROFILES_ACTIVE=prod
export DATABASE_URL=your-production-db-url
export JWT_SECRET=your-secure-jwt-secret
```

## 📚 Additional Resources

### Documentation
- [Spring Boot Documentation](https://spring.io/projects/spring-boot)
- [React Documentation](https://reactjs.org/docs)
- [Tesseract OCR Documentation](https://tesseract-ocr.github.io/)

### API Documentation
- Swagger UI: `http://localhost:8080/api/swagger-ui.html` (if configured)
- API endpoints: See `docs/API_DOCUMENTATION.md`

### Support
- Check the main `README.md` for project overview
- Review `docs/DESIGN_DOCUMENT.html` for system architecture
- Check `docs/TESTING_STRATEGY.md` for testing guidelines

---

**Note**: This guide assumes you're running the application in development mode. For production deployment, additional configuration and security measures are required. 