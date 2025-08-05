@echo off
echo ========================================
echo    Expense Tracker - Application Runner
echo ========================================
echo
echo This script will set up and run the Expense Tracker application
echo

REM Check if we're in the correct directory
if not exist "backend" (
    echo Error: Please run this script from the expense-tracker-project directory
    echo Current directory: %CD%
    pause
    exit /b 1
)

echo [1/9] Checking prerequisites...
echo

REM Check Java
java -version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Java is not installed or not in PATH
    echo Please install Java 17 or higher
    pause
    exit /b 1
) else (
    echo ✓ Java is installed
)

REM Check Node.js
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Node.js is not installed or not in PATH
    echo Please install Node.js 16 or higher
    pause
    exit /b 1
) else (
    echo ✓ Node.js is installed
)

REM Check Maven
mvn --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Maven is not installed or not in PATH
    echo Please install Maven 3.6 or higher
    pause
    exit /b 1
) else (
    echo ✓ Maven is installed
)

REM Check MySQL
mysql --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: MySQL is not installed or not in PATH
    echo Please install MySQL 8.0 or higher
    pause
    exit /b 1
) else (
    echo ✓ MySQL is installed
)

echo.
echo [2/9] Setting up MySQL database...
echo

REM Check if MySQL is running
net start | findstr "MySQL" >nul
if %errorlevel% neq 0 (
    echo Starting MySQL service...
    net start MySQL
    if %errorlevel% neq 0 (
        echo ERROR: Could not start MySQL service
        echo Please start MySQL manually and run this script again.
        pause
        exit /b 1
    )
)

REM Test MySQL connection
echo Testing MySQL connection...
mysql -u expensetracker_user -pexpensetracker_password -h localhost expensetracker -e "SELECT 'Connection successful!' AS status;" >nul
if %errorlevel% neq 0 (
    echo ERROR: MySQL connection failed
    echo Please run database/setup-mysql.bat first to setup the database.
    pause
    exit /b 1
)

echo ✓ MySQL database is ready

echo.
echo [3/9] Setting up backend...
echo

REM Navigate to backend directory
cd backend

REM Clean and build backend
echo Building backend application...
mvn clean compile -q
if %errorlevel% neq 0 (
    echo ERROR: Backend build failed
    pause
    exit /b 1
)

echo ✓ Backend built successfully

REM Start backend in background
echo Starting backend server...
start "Backend Server" cmd /k "mvn spring-boot:run"

REM Wait for backend to start
echo Waiting for backend to start...
timeout /t 15 /nobreak >nul

REM Test backend health
echo Testing backend health...
curl -s http://localhost:8080/api/health >nul
if %errorlevel% neq 0 (
    echo WARNING: Backend may not be fully started yet
    echo Please wait a moment and check http://localhost:8080/api/health
) else (
    echo ✓ Backend is running on http://localhost:8080
)

echo.
echo [4/9] Setting up frontend...
echo

REM Navigate to frontend directory
cd ..\frontend

REM Install frontend dependencies
echo Installing frontend dependencies...
npm install --silent
if %errorlevel% neq 0 (
    echo ERROR: Frontend dependencies installation failed
    pause
    exit /b 1
)

echo ✓ Frontend dependencies installed

REM Start frontend in background
echo Starting frontend development server...
start "Frontend Server" cmd /k "npm start"

REM Wait for frontend to start
echo Waiting for frontend to start...
timeout /t 10 /nobreak >nul

echo.
echo [5/9] Opening application in browser...
echo

REM Open application in browser
timeout /t 3 /nobreak >nul
start http://localhost:3000

echo.
echo [6/9] Opening API documentation...
echo

REM Open API documentation
timeout /t 2 /nobreak >nul
start docs\API_DOCUMENTATION.md

echo.
echo [7/9] Opening demo pages...
echo

REM Open demo pages
timeout /t 2 /nobreak >nul
start demo\index.html

echo.
echo [8/9] Opening database management...
echo

REM Open MySQL Workbench or phpMyAdmin if available
timeout /t 2 /nobreak >nul
echo MySQL Database Details:
echo - Host: localhost
echo - Port: 3306
echo - Database: expensetracker
echo - Username: expensetracker_user
echo - Password: expensetracker_password

echo.
echo [9/9] Application setup complete!
echo

echo ========================================
echo    Application Successfully Started!
echo ========================================
echo
echo Application URLs:
echo - Frontend: http://localhost:3000
echo - Backend API: http://localhost:8080/api
echo - MySQL Database: localhost:3306/expensetracker
echo - Demo Pages: demo/index.html
echo
echo Backend Terminal: Check the "Backend Server" window
echo Frontend Terminal: Check the "Frontend Server" window
echo
echo To stop the application:
echo 1. Close the terminal windows (Backend Server and Frontend Server)
echo 2. Or press Ctrl+C in each terminal
echo
echo MySQL Database Details:
echo - Host: localhost
echo - Port: 3306
echo - Database: expensetracker
echo - Username: expensetracker_user
echo - Password: expensetracker_password
echo
echo Connection URL:
echo jdbc:mysql://localhost:3306/expensetracker?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true
echo
pause 