# Expense Tracker - Step by Step Local Setup Guide

## 🎯 **Overview**

This guide will walk you through setting up and running the Expense Tracker application locally on your machine. The application consists of a Spring Boot backend with MySQL database and a React frontend.

## 📋 **Prerequisites**

Before starting, ensure you have the following installed:

### **Required Software**
- **Java 17** or higher
- **Node.js 16** or higher
- **Maven 3.6** or higher
- **MySQL 8.0** or higher
- **Git** (for cloning the repository)

### **Verify Installation**
```bash
# Check Java version
java -version

# Check Node.js version
node --version

# Check npm version
npm --version

# Check Maven version
mvn --version

# Check MySQL version
mysql --version
```

## 🚀 **Step 1: Clone and Navigate to Project**

```bash
# Clone the repository (if not already done)
git clone <repository-url>
cd expense-tracker-project

# Verify project structure
ls -la
```

**Expected Structure:**
```
expense-tracker-project/
├── backend/
├── frontend/
├── database/
├── demo/
├── docs/
├── setup.sh
├── setup.bat
├── quick-start.sh
├── quick-start.bat
└── README.md
```

## 🗄️ **Step 2: MySQL Database Setup**

### **2.1 Install MySQL**
```bash
# Navigate to database directory
cd database

# Run MySQL setup script
# For Linux/Mac:
chmod +x setup-mysql.sh
./setup-mysql.sh

# For Windows:
setup-mysql.bat
```

### **2.2 Verify MySQL Installation**
```bash
# Test MySQL connection
mysql -u expensetracker_user -pexpensetracker_password -h localhost expensetracker -e "SELECT 'Connection successful!' AS status;"
```

**Expected Output:**
```
+----------------------+
| status               |
+----------------------+
| Connection successful!|
+----------------------+
```

## 🔧 **Step 3: Backend Setup**

### **3.1 Navigate to Backend Directory**
```bash
cd backend
```

### **3.2 Verify Maven Configuration**
```bash
# Check if pom.xml exists
ls pom.xml

# Verify Maven dependencies
mvn dependency:tree
```

### **3.3 Build the Backend**
```bash
# Clean and compile
mvn clean compile

# Run tests (optional)
mvn test

# Package the application
mvn package -DskipTests
```

### **3.4 Start the Backend Server**
```bash
# Run the Spring Boot application
mvn spring-boot:run
```

**Expected Output:**
```
  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::                (v3.2.0)

2024-01-15 10:30:00.000  INFO 12345 --- [main] c.e.ExpenseTrackerApplication : Starting ExpenseTrackerApplication...
2024-01-15 10:30:00.000  INFO 12345 --- [main] c.e.ExpenseTrackerApplication : Started ExpenseTrackerApplication in 2.5s
```

### **3.5 Verify Backend is Running**
```bash
# Test the health endpoint
curl http://localhost:8080/api/health

# Or open in browser
open http://localhost:8080/api/health  # Mac
start http://localhost:8080/api/health  # Windows
xdg-open http://localhost:8080/api/health  # Linux
```

**Expected Response:**
```json
{
  "status": "UP",
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

## ⚛️ **Step 4: Frontend Setup**

### **4.1 Open New Terminal Window**
Keep the backend running and open a new terminal window.

### **4.2 Navigate to Frontend Directory**
```bash
cd expense-tracker-project/frontend
```

### **4.3 Install Dependencies**
```bash
# Install Node.js dependencies
npm install

# Verify installation
npm list --depth=0
```

### **4.4 Start the Frontend Development Server**
```bash
# Start React development server
npm start
```

**Expected Output:**
```
Compiled successfully!

You can now view expense-tracker-frontend in the browser.

  Local:            http://localhost:3000
  On Your Network:  http://192.168.1.100:3000

Note that the development build is not optimized.
To create a production build, use npm run build.
```

### **4.5 Verify Frontend is Running**
Open your browser and navigate to:
```
http://localhost:3000
```

You should see the Expense Tracker application interface.

## 🔗 **Step 5: Verify Full Application**

### **5.1 Test Backend API**
```bash
# Test expenses endpoint
curl http://localhost:8080/api/expenses

# Test categories endpoint
curl http://localhost:8080/api/categories

# Test health endpoint
curl http://localhost:8080/api/health
```

### **5.2 Test Frontend-Backend Communication**
1. Open browser to `http://localhost:3000`
2. Navigate to different sections
3. Check browser console for any errors
4. Verify API calls are working

## 🛠️ **Step 6: Database Management (Optional)**

### **6.1 MySQL Command Line**
```bash
# Connect to MySQL
mysql -u expensetracker_user -pexpensetracker_password -h localhost expensetracker

# Show tables
SHOW TABLES;

# View data
SELECT * FROM categories;
SELECT * FROM currencies;
```

### **6.2 MySQL Workbench or phpMyAdmin**
- Use MySQL Workbench for GUI management
- Or phpMyAdmin if using XAMPP/WAMP

## 🎯 **Step 7: Test Key Features**

### **7.1 Test Receipt Scanning**
1. Navigate to Receipt Scanner in the app
2. Upload a test image
3. Verify OCR processing simulation

### **7.2 Test Expense Management**
1. Add a new expense
2. Edit an existing expense
3. Delete an expense
4. Test filtering and search

### **7.3 Test Analytics**
1. View spending charts
2. Check category breakdown
3. Test export functionality

### **7.4 Test Budget Tracking**
1. Set up a budget
2. Add expenses
3. Check budget alerts

## 🚨 **Troubleshooting**

### **Common Issues and Solutions**

#### **MySQL Issues**

**Issue: MySQL service not running**
```bash
# Start MySQL service
# Linux:
sudo systemctl start mysql

# macOS:
brew services start mysql

# Windows:
net start MySQL
```

**Issue: Connection refused**
```bash
# Check if MySQL is running
mysqladmin ping -u root -p

# Check MySQL status
sudo systemctl status mysql  # Linux
brew services list | grep mysql  # macOS
```

**Issue: Access denied for user**
```bash
# Reset MySQL user password
mysql -u root -p
ALTER USER 'expensetracker_user'@'localhost' IDENTIFIED BY 'expensetracker_password';
FLUSH PRIVILEGES;
```

#### **Backend Issues**

**Issue: Port 8080 already in use**
```bash
# Find process using port 8080
lsof -i :8080  # Mac/Linux
netstat -ano | findstr :8080  # Windows

# Kill the process
kill -9 <PID>  # Mac/Linux
taskkill /PID <PID> /F  # Windows
```

**Issue: Maven build fails**
```bash
# Clean and rebuild
mvn clean install

# Check Java version
java -version
```

**Issue: Application won't start**
```bash
# Check application logs
tail -f logs/application.log

# Verify application.yml configuration
cat src/main/resources/application.yml
```

#### **Frontend Issues**

**Issue: Port 3000 already in use**
```bash
# Find process using port 3000
lsof -i :3000  # Mac/Linux
netstat -ano | findstr :3000  # Windows

# Kill the process
kill -9 <PID>  # Mac/Linux
taskkill /PID <PID> /F  # Windows
```

**Issue: npm install fails**
```bash
# Clear npm cache
npm cache clean --force

# Delete node_modules and reinstall
rm -rf node_modules package-lock.json
npm install
```

**Issue: Frontend can't connect to backend**
```bash
# Check if backend is running
curl http://localhost:8080/api/health

# Check CORS configuration in backend
# Verify proxy settings in package.json
```

## 📊 **Step 8: Monitoring and Logs**

### **8.1 Backend Logs**
```bash
# View application logs
tail -f logs/application.log

# Check for errors
grep ERROR logs/application.log
```

### **8.2 Frontend Logs**
Check browser console (F12) for:
- JavaScript errors
- Network request failures
- API call issues

### **8.3 MySQL Logs**
```bash
# View MySQL error log
sudo tail -f /var/log/mysql/error.log  # Linux
tail -f /usr/local/var/mysql/*.err  # macOS
```

### **8.4 Application Health**
```bash
# Check backend health
curl http://localhost:8080/api/health

# Check application metrics
curl http://localhost:8080/api/actuator/health
```

## 🔄 **Step 9: Development Workflow**

### **9.1 Making Changes**
1. **Backend Changes**: Restart the Spring Boot application
2. **Frontend Changes**: React will auto-reload
3. **Database Changes**: Restart the application

### **9.2 Hot Reload**
- Frontend: Changes auto-reload in browser
- Backend: Use Spring Boot DevTools for hot reload

### **9.3 Debugging**
- **Backend**: Use IDE debugger or add logging
- **Frontend**: Use browser developer tools
- **Database**: Use MySQL Workbench or command line

## 🛑 **Step 10: Stopping the Application**

### **10.1 Stop Frontend**
```bash
# In frontend terminal
Ctrl + C
```

### **10.2 Stop Backend**
```bash
# In backend terminal
Ctrl + C
```

### **10.3 Stop MySQL (Optional)**
```bash
# Linux:
sudo systemctl stop mysql

# macOS:
brew services stop mysql

# Windows:
net stop MySQL
```

### **10.4 Verify Clean Shutdown**
```bash
# Check if ports are free
lsof -i :3000  # Frontend port
lsof -i :8080  # Backend port
lsof -i :3306  # MySQL port
```

## 🎉 **Step 11: Success Verification**

### **11.1 Application Features Working**
- ✅ MySQL database connected
- ✅ Backend API responding
- ✅ Frontend loading correctly
- ✅ Receipt scanning simulation
- ✅ Expense management
- ✅ Analytics and charts
- ✅ Budget tracking
- ✅ User settings

### **11.2 Performance Check**
- ✅ Backend startup time < 10 seconds
- ✅ Frontend load time < 5 seconds
- ✅ API response time < 500ms
- ✅ Database connection < 100ms
- ✅ No console errors

## 📚 **Next Steps**

After successful setup:
1. **Explore the API**: Check `docs/API_DOCUMENTATION.md`
2. **Review the code**: Examine backend and frontend implementations
3. **Test the demos**: Run `demo/launch-demos.bat` or `demo/launch-demos.sh`
4. **Customize**: Modify configurations and add features
5. **Deploy**: Follow deployment guidelines in `README.md`

## 🆘 **Getting Help**

If you encounter issues:
1. Check the troubleshooting section above
2. Review the logs for error messages
3. Verify all prerequisites are installed
4. Check the main `README.md` for additional information
5. Ensure firewall/antivirus isn't blocking ports
6. Verify MySQL service is running

---

**Congratulations!** 🎉 You have successfully set up and are running the Expense Tracker application with MySQL database locally. 