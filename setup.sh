#!/bin/bash

echo "🚀 Setting up Expense Tracker with Receipt Scanning"
echo "=================================================="

# Check if Java is installed
if ! command -v java &> /dev/null; then
    echo "❌ Java is not installed. Please install Java 17 or higher."
    exit 1
fi

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js 16 or higher."
    exit 1
fi

# Check if Maven is installed
if ! command -v mvn &> /dev/null; then
    echo "❌ Maven is not installed. Please install Maven 3.6 or higher."
    exit 1
fi

echo "✅ Prerequisites check passed"

# Create data directory if it doesn't exist
mkdir -p data

# Create sample data files
echo "📊 Creating sample data files..."

cat > data/categories.csv << EOF
id,name,description,icon,color,is_default
1,Food & Dining,Restaurants groceries and dining expenses,🍽️,#FF6B6B,true
2,Transportation,Gas public transport rideshare,🚗,#4ECDC4,true
3,Shopping,Clothing electronics general shopping,🛍️,#45B7D1,true
4,Entertainment,Movies games hobbies,🎬,#96CEB4,true
5,Healthcare,Medical expenses prescriptions,🏥,#FFEAA7,true
6,Utilities,Electricity water internet,⚡,#DDA0DD,true
7,Travel,Hotels flights vacation expenses,✈️,#98D8C8,true
8,Business,Work-related expenses,💼,#F7DC6F,true
EOF

cat > data/currencies.csv << EOF
code,name,symbol,exchange_rate,is_active
USD,US Dollar,$,1.0,true
EUR,Euro,€,0.85,true
GBP,British Pound,£,0.73,true
JPY,Japanese Yen,¥,110.0,true
CAD,Canadian Dollar,C$,1.25,true
AUD,Australian Dollar,A$,1.35,true
CHF,Swiss Franc,CHF,0.92,true
CNY,Chinese Yuan,¥,6.45,true
EOF

echo "✅ Sample data files created"

# Backend setup
echo "🔧 Setting up backend..."
cd backend

# Build the backend
echo "📦 Building Spring Boot application..."
mvn clean install -DskipTests

if [ $? -eq 0 ]; then
    echo "✅ Backend build successful"
else
    echo "❌ Backend build failed"
    exit 1
fi

cd ..

# Frontend setup
echo "🔧 Setting up frontend..."
cd frontend

# Install dependencies
echo "📦 Installing Node.js dependencies..."
npm install

if [ $? -eq 0 ]; then
    echo "✅ Frontend dependencies installed"
else
    echo "❌ Frontend dependency installation failed"
    exit 1
fi

cd ..

echo ""
echo "🎉 Setup completed successfully!"
echo ""
echo "📋 Next steps:"
echo "1. Start the backend: cd backend && mvn spring-boot:run"
echo "2. Start the frontend: cd frontend && npm start"
echo "3. Access the application at http://localhost:3000"
echo "4. API documentation available at http://localhost:8080/api/v1"
echo "5. H2 Database console at http://localhost:8080/h2-console"
echo ""
echo "📚 For more information, see the README.md file" 