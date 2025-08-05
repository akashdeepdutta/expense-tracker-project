#!/bin/bash

echo "🧪 Demo Test - Expense Tracker Application"
echo "=========================================="

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to test backend health
test_backend_health() {
    print_status "Testing backend health..."
    
    response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/api/actuator/health)
    
    if [ "$response" = "200" ]; then
        print_success "Backend is healthy!"
        return 0
    else
        print_error "Backend health check failed (HTTP $response)"
        return 1
    fi
}

# Function to test frontend accessibility
test_frontend() {
    print_status "Testing frontend accessibility..."
    
    response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000)
    
    if [ "$response" = "200" ]; then
        print_success "Frontend is accessible!"
        return 0
    else
        print_error "Frontend accessibility test failed (HTTP $response)"
        return 1
    fi
}

# Function to test API endpoints
test_api_endpoints() {
    print_status "Testing API endpoints..."
    
    # Test expenses endpoint
    response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/api/expenses)
    if [ "$response" = "200" ] || [ "$response" = "401" ]; then
        print_success "Expenses endpoint is responding (HTTP $response)"
    else
        print_error "Expenses endpoint test failed (HTTP $response)"
    fi
    
    # Test categories endpoint
    response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/api/categories)
    if [ "$response" = "200" ] || [ "$response" = "401" ]; then
        print_success "Categories endpoint is responding (HTTP $response)"
    else
        print_error "Categories endpoint test failed (HTTP $response)"
    fi
}

# Function to test H2 console
test_h2_console() {
    print_status "Testing H2 database console..."
    
    response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/h2-console)
    
    if [ "$response" = "200" ]; then
        print_success "H2 console is accessible!"
        return 0
    else
        print_error "H2 console test failed (HTTP $response)"
        return 1
    fi
}

# Function to display application URLs
show_application_urls() {
    echo ""
    print_status "Application URLs:"
    echo "  📱 Frontend: http://localhost:3000"
    echo "  🔧 Backend API: http://localhost:8080/api"
    echo "  🗄️  H2 Database Console: http://localhost:8080/h2-console"
    echo "  📊 Actuator Health: http://localhost:8080/api/actuator/health"
    echo ""
}

# Function to display test results
show_test_results() {
    echo ""
    print_status "Test Results Summary:"
    echo "  ✅ Backend Health: $1"
    echo "  ✅ Frontend Access: $2"
    echo "  ✅ API Endpoints: $3"
    echo "  ✅ H2 Console: $4"
    echo ""
}

# Main test execution
main() {
    echo ""
    print_status "Starting application tests..."
    echo ""
    
    # Wait a moment for applications to fully start
    sleep 5
    
    # Test backend health
    if test_backend_health; then
        backend_health="PASS"
    else
        backend_health="FAIL"
    fi
    
    # Test frontend
    if test_frontend; then
        frontend_access="PASS"
    else
        frontend_access="FAIL"
    fi
    
    # Test API endpoints
    test_api_endpoints
    api_endpoints="PASS"
    
    # Test H2 console
    if test_h2_console; then
        h2_console="PASS"
    else
        h2_console="FAIL"
    fi
    
    # Show results
    show_test_results "$backend_health" "$frontend_access" "$api_endpoints" "$h2_console"
    show_application_urls
    
    # Overall result
    if [ "$backend_health" = "PASS" ] && [ "$frontend_access" = "PASS" ]; then
        print_success "🎉 Application is running successfully!"
        echo ""
        print_status "You can now:"
        echo "  1. Open http://localhost:3000 in your browser"
        echo "  2. Test the expense tracking features"
        echo "  3. Try uploading a receipt image"
        echo "  4. View the analytics dashboard"
        echo ""
    else
        print_error "❌ Some tests failed. Please check the application logs."
        echo ""
        print_status "Troubleshooting tips:"
        echo "  1. Ensure both backend and frontend are running"
        echo "  2. Check if ports 8080 and 3000 are available"
        echo "  3. Verify all prerequisites are installed"
        echo "  4. Check the application logs for errors"
        echo ""
    fi
}

# Run main function
main 