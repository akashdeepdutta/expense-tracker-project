@echo off
echo 🚀 Setting up Expense Tracker with Receipt Scanning
echo ==================================================

REM Check if Java is installed
java -version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Java is not installed. Please install Java 17 or higher.
    pause
    exit /b 1
)

REM Check if Node.js is installed
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Node.js is not installed. Please install Node.js 16 or higher.
    pause
    exit /b 1
)

REM Check if Maven is installed
mvn --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Maven is not installed. Please install Maven 3.6 or higher.
    pause
    exit /b 1
)

echo ✅ Prerequisites check passed

REM Create data directory if it doesn't exist
if not exist "data" mkdir data

REM Create sample data files
echo 📊 Creating sample data files...

echo id,name,description,icon,color,is_default > data\categories.csv
echo 1,Food & Dining,Restaurants groceries and dining expenses,🍽️,#FF6B6B,true >> data\categories.csv
echo 2,Transportation,Gas public transport rideshare,🚗,#4ECDC4,true >> data\categories.csv
echo 3,Shopping,Clothing electronics general shopping,🛍️,#45B7D1,true >> data\categories.csv
echo 4,Entertainment,Movies games hobbies,🎬,#96CEB4,true >> data\categories.csv
echo 5,Healthcare,Medical expenses prescriptions,🏥,#FFEAA7,true >> data\categories.csv
echo 6,Utilities,Electricity water internet,⚡,#DDA0DD,true >> data\categories.csv
echo 7,Travel,Hotels flights vacation expenses,✈️,#98D8C8,true >> data\categories.csv
echo 8,Business,Work-related expenses,💼,#F7DC6F,true >> data\categories.csv

echo code,name,symbol,exchange_rate,is_active > data\currencies.csv
echo USD,US Dollar,$,1.0,true >> data\currencies.csv
echo EUR,Euro,€,0.85,true >> data\currencies.csv
echo GBP,British Pound,£,0.73,true >> data\currencies.csv
echo JPY,Japanese Yen,¥,110.0,true >> data\currencies.csv
echo CAD,Canadian Dollar,C$,1.25,true >> data\currencies.csv
echo AUD,Australian Dollar,A$,1.35,true >> data\currencies.csv
echo CHF,Swiss Franc,CHF,0.92,true >> data\currencies.csv
echo CNY,Chinese Yuan,¥,6.45,true >> data\currencies.csv

echo ✅ Sample data files created

REM Backend setup
echo 🔧 Setting up backend...
cd backend

REM Build the backend
echo 📦 Building Spring Boot application...
call mvn clean install -DskipTests

if %errorlevel% equ 0 (
    echo ✅ Backend build successful
) else (
    echo ❌ Backend build failed
    pause
    exit /b 1
)

cd ..

REM Frontend setup
echo 🔧 Setting up frontend...
cd frontend

REM Install dependencies
echo 📦 Installing Node.js dependencies...
call npm install

if %errorlevel% equ 0 (
    echo ✅ Frontend dependencies installed
) else (
    echo ❌ Frontend dependency installation failed
    pause
    exit /b 1
)

cd ..

echo.
echo 🎉 Setup completed successfully!
echo.
echo 📋 Next steps:
echo 1. Start the backend: cd backend ^&^& mvn spring-boot:run
echo 2. Start the frontend: cd frontend ^&^& npm start
echo 3. Access the application at http://localhost:3000
echo 4. API documentation available at http://localhost:8080/api/v1
echo 5. H2 Database console at http://localhost:8080/h2-console
echo.
echo 📚 For more information, see the README.md file
pause 