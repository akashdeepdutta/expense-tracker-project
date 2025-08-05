@echo off
setlocal enabledelayedexpansion

echo 🚀 Quick Start - Expense Tracker Application
echo =============================================

REM Check if required tools are installed
echo [INFO] Checking prerequisites...

REM Check Java
java -version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Java is not installed. Please install Java 17 or higher.
    pause
    exit /b 1
)

REM Check Node.js
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Node.js is not installed. Please install Node.js 16 or higher.
    pause
    exit /b 1
)

REM Check Maven
mvn --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Maven is not installed. Please install Maven 3.6 or higher.
    pause
    exit /b 1
)

echo [SUCCESS] All prerequisites are installed!

echo.
echo [INFO] Starting Expense Tracker Application...
echo.

REM Start backend
echo [INFO] Starting backend server...
cd backend

REM Check if target directory exists, if not build the project
if not exist "target" (
    echo [INFO] Building backend project...
    mvn clean compile -q
    if %errorlevel% neq 0 (
        echo [ERROR] Backend build failed!
        pause
        exit /b 1
    )
)

REM Start the backend server in background
echo [INFO] Starting Spring Boot application...
start /B mvn spring-boot:run -q

REM Wait for backend to start
echo [INFO] Waiting for backend to start...
timeout /t 10 /nobreak >nul

cd ..

REM Start frontend
echo [INFO] Starting frontend application...
cd frontend

REM Check if node_modules exists, if not install dependencies
if not exist "node_modules" (
    echo [INFO] Installing frontend dependencies...
    npm install -q
    if %errorlevel% neq 0 (
        echo [ERROR] Frontend dependency installation failed!
        pause
        exit /b 1
    )
)

REM Start the frontend server in background
echo [INFO] Starting React development server...
start /B npm start

REM Wait for frontend to start
echo [INFO] Waiting for frontend to start...
timeout /t 15 /nobreak >nul

cd ..

echo.
echo [SUCCESS] 🎉 Application is starting up!
echo.
echo 📱 Frontend: http://localhost:3000
echo 🔧 Backend API: http://localhost:8080/api
echo 🗄️  H2 Database Console: http://localhost:8080/h2-console
echo.
echo 📋 Connection details for H2 Console:
echo    JDBC URL: jdbc:h2:mem:expensedb
echo    Username: sa
echo    Password: (leave empty)
echo.
echo [INFO] Applications are running in background.
echo [INFO] Press any key to stop all applications...
echo.

REM Wait for user input
pause >nul

REM Stop applications
echo [INFO] Shutting down applications...

REM Find and kill Java processes (Spring Boot)
for /f "tokens=2" %%a in ('tasklist /fi "imagename eq java.exe" /fo csv ^| find "java.exe"') do (
    taskkill /PID %%a /F >nul 2>&1
)

REM Find and kill Node.js processes (React)
for /f "tokens=2" %%a in ('tasklist /fi "imagename eq node.exe" /fo csv ^| find "node.exe"') do (
    taskkill /PID %%a /F >nul 2>&1
)

echo [SUCCESS] All applications stopped
pause 