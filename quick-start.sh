#!/bin/bash

echo "🚀 Quick Start - Expense Tracker Application"
echo "============================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required tools are installed
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check Java
    if ! command -v java &> /dev/null; then
        print_error "Java is not installed. Please install Java 17 or higher."
        exit 1
    fi
    
    # Check Node.js
    if ! command -v node &> /dev/null; then
        print_error "Node.js is not installed. Please install Node.js 16 or higher."
        exit 1
    fi
    
    # Check Maven
    if ! command -v mvn &> /dev/null; then
        print_error "Maven is not installed. Please install Maven 3.6 or higher."
        exit 1
    fi
    
    print_success "All prerequisites are installed!"
}

# Build and start backend
start_backend() {
    print_status "Starting backend server..."
    
    cd backend
    
    # Check if target directory exists, if not build the project
    if [ ! -d "target" ]; then
        print_status "Building backend project..."
        mvn clean compile -q
        if [ $? -ne 0 ]; then
            print_error "Backend build failed!"
            exit 1
        fi
    fi
    
    # Start the backend server in background
    print_status "Starting Spring Boot application..."
    mvn spring-boot:run -q &
    BACKEND_PID=$!
    
    # Wait for backend to start
    print_status "Waiting for backend to start..."
    sleep 10
    
    # Check if backend is running
    if curl -s http://localhost:8080/api/actuator/health > /dev/null; then
        print_success "Backend is running on http://localhost:8080"
    else
        print_warning "Backend might still be starting up..."
    fi
    
    cd ..
}

# Start frontend
start_frontend() {
    print_status "Starting frontend application..."
    
    cd frontend
    
    # Check if node_modules exists, if not install dependencies
    if [ ! -d "node_modules" ]; then
        print_status "Installing frontend dependencies..."
        npm install -q
        if [ $? -ne 0 ]; then
            print_error "Frontend dependency installation failed!"
            exit 1
        fi
    fi
    
    # Start the frontend server in background
    print_status "Starting React development server..."
    npm start &
    FRONTEND_PID=$!
    
    # Wait for frontend to start
    print_status "Waiting for frontend to start..."
    sleep 15
    
    # Check if frontend is running
    if curl -s http://localhost:3000 > /dev/null; then
        print_success "Frontend is running on http://localhost:3000"
    else
        print_warning "Frontend might still be starting up..."
    fi
    
    cd ..
}

# Function to handle cleanup on script exit
cleanup() {
    print_status "Shutting down applications..."
    
    if [ ! -z "$BACKEND_PID" ]; then
        kill $BACKEND_PID 2>/dev/null
        print_status "Backend stopped"
    fi
    
    if [ ! -z "$FRONTEND_PID" ]; then
        kill $FRONTEND_PID 2>/dev/null
        print_status "Frontend stopped"
    fi
    
    print_success "All applications stopped"
    exit 0
}

# Set up signal handlers
trap cleanup SIGINT SIGTERM

# Main execution
main() {
    echo ""
    print_status "Starting Expense Tracker Application..."
    echo ""
    
    # Check prerequisites
    check_prerequisites
    
    # Start backend
    start_backend
    
    # Start frontend
    start_frontend
    
    echo ""
    print_success "🎉 Application is starting up!"
    echo ""
    echo "📱 Frontend: http://localhost:3000"
    echo "🔧 Backend API: http://localhost:8080/api"
    echo "🗄️  H2 Database Console: http://localhost:8080/h2-console"
    echo ""
    echo "📋 Connection details for H2 Console:"
    echo "   JDBC URL: jdbc:h2:mem:expensedb"
    echo "   Username: sa"
    echo "   Password: (leave empty)"
    echo ""
    print_status "Press Ctrl+C to stop all applications"
    echo ""
    
    # Wait for user to stop the applications
    wait
}

# Run main function
main 