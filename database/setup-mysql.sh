#!/bin/bash

echo "========================================"
echo "   MySQL Setup for Expense Tracker"
echo "========================================"
echo

# Function to detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macOS"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "Linux"
    else
        echo "Unknown"
    fi
}

# Function to install MySQL on macOS
install_mysql_macos() {
    echo "Installing MySQL on macOS..."
    
    # Check if Homebrew is installed
    if ! command -v brew &> /dev/null; then
        echo "Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    
    # Install MySQL
    brew install mysql
    
    # Start MySQL service
    brew services start mysql
    
    echo "MySQL installed and started on macOS"
}

# Function to install MySQL on Linux
install_mysql_linux() {
    echo "Installing MySQL on Linux..."
    
    # Detect Linux distribution
    if command -v apt-get &> /dev/null; then
        # Ubuntu/Debian
        sudo apt-get update
        sudo apt-get install -y mysql-server
        sudo systemctl start mysql
        sudo systemctl enable mysql
    elif command -v yum &> /dev/null; then
        # CentOS/RHEL
        sudo yum install -y mysql-server
        sudo systemctl start mysqld
        sudo systemctl enable mysqld
    elif command -v dnf &> /dev/null; then
        # Fedora
        sudo dnf install -y mysql-server
        sudo systemctl start mysqld
        sudo systemctl enable mysqld
    else
        echo "Unsupported Linux distribution. Please install MySQL manually."
        exit 1
    fi
    
    echo "MySQL installed and started on Linux"
}

# Function to secure MySQL installation
secure_mysql() {
    echo "Securing MySQL installation..."
    
    # Set root password (you may need to adjust this based on your MySQL version)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        mysql_secure_installation
    else
        # For Linux, you might need to set a temporary password first
        echo "Please run 'sudo mysql_secure_installation' to secure your MySQL installation"
        echo "You may need to set a root password first:"
        echo "sudo mysql -u root"
        echo "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'your_password';"
        echo "FLUSH PRIVILEGES;"
        echo "EXIT;"
    fi
}

# Function to setup database
setup_database() {
    echo "Setting up Expense Tracker database..."
    
    # Check if MySQL is running
    if ! mysqladmin ping -u root -p --silent; then
        echo "MySQL is not running. Please start MySQL first."
        exit 1
    fi
    
    # Run the setup script
    mysql -u root -p < setup-mysql.sql
    
    echo "Database setup completed!"
}

# Function to test connection
test_connection() {
    echo "Testing database connection..."
    
    mysql -u expensetracker_user -pexpensetracker_password -h localhost expensetracker -e "SELECT 'Connection successful!' AS status;"
    
    if [ $? -eq 0 ]; then
        echo "✓ Database connection successful!"
    else
        echo "✗ Database connection failed!"
        echo "Please check your MySQL installation and credentials."
    fi
}

# Main script
OS=$(detect_os)
echo "Detected OS: $OS"

# Check if MySQL is already installed
if command -v mysql &> /dev/null; then
    echo "✓ MySQL is already installed"
else
    echo "MySQL not found. Installing..."
    
    case $OS in
        "macOS")
            install_mysql_macos
            ;;
        "Linux")
            install_mysql_linux
            ;;
        *)
            echo "Unsupported OS. Please install MySQL manually."
            exit 1
            ;;
    esac
fi

# Secure MySQL installation
echo
echo "Do you want to secure your MySQL installation? (y/n)"
read -r secure_response
if [[ $secure_response =~ ^[Yy]$ ]]; then
    secure_mysql
fi

# Setup database
echo
echo "Setting up the Expense Tracker database..."
echo "You will be prompted for the MySQL root password."
setup_database

# Test connection
echo
test_connection

echo
echo "========================================"
echo "   MySQL Setup Complete!"
echo "========================================"
echo
echo "Database Details:"
echo "- Database Name: expensetracker"
echo "- Username: expensetracker_user"
echo "- Password: expensetracker_password"
echo "- Host: localhost"
echo "- Port: 3306"
echo
echo "Connection URL:"
echo "jdbc:mysql://localhost:3306/expensetracker?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true"
echo
echo "You can now start the Expense Tracker application!" 