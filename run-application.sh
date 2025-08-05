#!/bin/bash

echo "========================================"
echo "   Expense Tracker - Application Runner"
echo "========================================"
echo
echo "This script will set up and run the Expense Tracker application"
echo

# Check if we're in the correct directory
if [ ! -d "backend" ]; then
    echo "Error: Please run this script from the expense-tracker-project directory"
    echo "Current directory: $(pwd)"
    exit 1
fi

echo "[1/9] Checking prerequisites..."
echo

# Check Java
if ! command -v java &> /dev/null; then
    echo "ERROR: Java is not installed or not in PATH"
    echo "Please install Java 17 or higher"
    exit 1
else
    echo "✓ Java is installed"
fi

# Check Node.js
if ! command -v node &> /dev/null; then
    echo "ERROR: Node.js is not installed or not in PATH"
    echo "Please install Node.js 16 or higher"
    exit 1
else
    echo "✓ Node.js is installed"
fi

# Check Maven
if ! command -v mvn &> /dev/null; then
    echo "ERROR: Maven is not installed or not in PATH"
    echo "Please install Maven 3.6 or higher"
    exit 1
else
    echo "✓ Maven is installed"
fi

# Check MySQL
if ! command -v mysql &> /dev/null; then
    echo "ERROR: MySQL is not installed or not in PATH"
    echo "Please install MySQL 8.0 or higher"
    exit 1
else
    echo "✓ MySQL is installed"
fi

echo
echo "[2/9] Setting up MySQL database..."
echo

# Check if MySQL is running
if ! mysqladmin ping -u root -p --silent 2>/dev/null; then
    echo "Starting MySQL service..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew services start mysql
    else
        sudo systemctl start mysql
    fi
    
    # Wait for MySQL to start
    sleep 5
fi

# Test MySQL connection
echo "Testing MySQL connection..."
if mysql -u expensetracker_user -pexpensetracker_password -h localhost expensetracker -e "SELECT 'Connection successful!' AS status;" 2>/dev/null; then
    echo "✓ MySQL database is ready"
else
    echo "ERROR: MySQL connection failed"
    echo "Please run database/setup-mysql.sh first to setup the database."
    exit 1
fi

echo
echo "[3/9] Setting up backend..."
echo

# Navigate to backend directory
cd backend

# Clean and build backend
echo "Building backend application..."
if ! mvn clean compile -q; then
    echo "ERROR: Backend build failed"
    exit 1
fi

echo "✓ Backend built successfully"

# Start backend in background
echo "Starting backend server..."
nohup mvn spring-boot:run > ../backend.log 2>&1 &
BACKEND_PID=$!

# Wait for backend to start
echo "Waiting for backend to start..."
sleep 15

# Test backend health
echo "Testing backend health..."
if curl -s http://localhost:8080/api/health > /dev/null; then
    echo "✓ Backend is running on http://localhost:8080"
else
    echo "WARNING: Backend may not be fully started yet"
    echo "Please wait a moment and check http://localhost:8080/api/health"
fi

echo
echo "[4/9] Setting up frontend..."
echo

# Navigate to frontend directory
cd ../frontend

# Install frontend dependencies
echo "Installing frontend dependencies..."
if ! npm install --silent; then
    echo "ERROR: Frontend dependencies installation failed"
    exit 1
fi

echo "✓ Frontend dependencies installed"

# Start frontend in background
echo "Starting frontend development server..."
nohup npm start > ../frontend.log 2>&1 &
FRONTEND_PID=$!

# Wait for frontend to start
echo "Waiting for frontend to start..."
sleep 10

echo
echo "[5/9] Opening application in browser..."
echo

# Function to open URL based on OS
open_url() {
    local url="$1"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        open "$url"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        if command -v xdg-open > /dev/null; then
            xdg-open "$url"
        elif command -v gnome-open > /dev/null; then
            gnome-open "$url"
        else
            echo "Could not open browser automatically. Please open $url manually."
        fi
    else
        echo "Unsupported OS. Please open $url manually."
    fi
}

# Open application in browser
sleep 3
open_url "http://localhost:3000"

echo
echo "[6/9] Opening API documentation..."
echo

# Open API documentation
sleep 2
if [[ "$OSTYPE" == "darwin"* ]]; then
    open "docs/API_DOCUMENTATION.md"
else
    echo "Please open docs/API_DOCUMENTATION.md manually"
fi

echo
echo "[7/9] Opening demo pages..."
echo

# Open demo pages
sleep 2
open_url "demo/index.html"

echo
echo "[8/9] Database information..."
echo

# Show database information
echo "MySQL Database Details:"
echo "- Host: localhost"
echo "- Port: 3306"
echo "- Database: expensetracker"
echo "- Username: expensetracker_user"
echo "- Password: expensetracker_password"
echo
echo "Connection URL:"
echo "jdbc:mysql://localhost:3306/expensetracker?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true"

echo
echo "[9/9] Application setup complete!"
echo

echo "========================================"
echo "    Application Successfully Started!"
echo "========================================"
echo
echo "Application URLs:"
echo "- Frontend: http://localhost:3000"
echo "- Backend API: http://localhost:8080/api"
echo "- MySQL Database: localhost:3306/expensetracker"
echo "- Demo Pages: demo/index.html"
echo
echo "Backend Logs: tail -f backend.log"
echo "Frontend Logs: tail -f frontend.log"
echo
echo "To stop the application:"
echo "1. Press Ctrl+C in this terminal"
echo "2. Or kill the processes: kill $BACKEND_PID $FRONTEND_PID"
echo
echo "MySQL Database Details:"
echo "- Host: localhost"
echo "- Port: 3306"
echo "- Database: expensetracker"
echo "- Username: expensetracker_user"
echo "- Password: expensetracker_password"
echo
echo "Connection URL:"
echo "jdbc:mysql://localhost:3306/expensetracker?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true"
echo

# Function to cleanup on exit
cleanup() {
    echo
    echo "Stopping application..."
    kill $BACKEND_PID $FRONTEND_PID 2>/dev/null
    echo "Application stopped."
    exit 0
}

# Set up signal handlers
trap cleanup SIGINT SIGTERM

echo "Press Ctrl+C to stop the application"
echo

# Keep script running
while true; do
    sleep 1
done 