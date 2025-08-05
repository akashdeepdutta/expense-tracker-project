@echo off
echo ========================================
echo    MySQL Setup for Expense Tracker
echo ========================================
echo

REM Check if MySQL is already installed
mysql --version >nul 2>&1
if %errorlevel% equ 0 (
    echo ✓ MySQL is already installed
    goto :setup_database
) else (
    echo MySQL not found. Please install MySQL manually.
    echo.
    echo Installation options:
    echo 1. Download from https://dev.mysql.com/downloads/mysql/
    echo 2. Use XAMPP: https://www.apachefriends.org/
    echo 3. Use WAMP: https://www.wampserver.com/
    echo.
    echo After installation, run this script again.
    pause
    exit /b 1
)

:setup_database
echo.
echo Setting up the Expense Tracker database...
echo.

REM Check if MySQL service is running
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

REM Run the setup script
echo Running database setup script...
mysql -u root -p < setup-mysql.sql
if %errorlevel% neq 0 (
    echo ERROR: Database setup failed
    echo Please check your MySQL installation and try again.
    pause
    exit /b 1
)

echo.
echo Testing database connection...
mysql -u expensetracker_user -pexpensetracker_password -h localhost expensetracker -e "SELECT 'Connection successful!' AS status;"
if %errorlevel% equ 0 (
    echo ✓ Database connection successful!
) else (
    echo ✗ Database connection failed!
    echo Please check your MySQL installation and credentials.
)

echo.
echo ========================================
echo    MySQL Setup Complete!
echo ========================================
echo.
echo Database Details:
echo - Database Name: expensetracker
echo - Username: expensetracker_user
echo - Password: expensetracker_password
echo - Host: localhost
echo - Port: 3306
echo.
echo Connection URL:
echo jdbc:mysql://localhost:3306/expensetracker?useSSL=false^&serverTimezone=UTC^&allowPublicKeyRetrieval=true
echo.
echo You can now start the Expense Tracker application!
echo.
pause 