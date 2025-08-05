# Expense Tracker with Receipt Scanning

A comprehensive expense management application with OCR receipt scanning, smart categorization, budget tracking, and multi-currency support.

## 🚀 Features

### Core Features
- **OCR Receipt Scanning**: Automatic data extraction from receipt images using Tesseract OCR
- **Smart Categorization**: AI-powered expense categorization with suggestions
- **Budget Tracking**: Real-time budget monitoring with alerts and notifications
- **Multi-Currency Support**: International expense tracking with exchange rates
- **Expense Reports**: Tax preparation and reimbursement reports
- **Data Export**: CSV export capabilities

### Technical Features
- **React Frontend**: Modern, responsive UI with TypeScript
- **Spring Boot Backend**: RESTful API with JPA/Hibernate
- **H2 Database**: In-memory database for development
- **JWT Authentication**: Secure user authentication
- **Real-time Analytics**: Charts and spending insights
- **File Upload**: Receipt image processing and storage

## 🛠️ Technology Stack

### Backend
- **Java 17** with Spring Boot 3.2.0
- **Spring Security** with JWT authentication
- **Spring Data JPA** with Hibernate
- **MySQL 8.0** (Persistent Database)
- **Tesseract OCR** for receipt scanning
- **Maven** for dependency management

### Frontend
- **React 18** with TypeScript
- **React Router** for navigation
- **React Query** for data fetching
- **Chart.js** for analytics visualization
- **Tailwind CSS** for styling
- **Lucide React** for icons
- **React Dropzone** for file uploads

### Database
- **MySQL 8.0** with InnoDB storage engine
- **ACID Compliance** for data integrity
- **Connection Pooling** with HikariCP
- **Optimized Indexing** for performance

## 📁 Project Structure

```
expense-tracker-project/
├── backend/                          # Spring Boot application
│   ├── src/main/java/com/expensetracker/
│   │   ├── controller/              # REST controllers
│   │   ├── model/                   # JPA entities
│   │   ├── repository/              # Data access layer
│   │   ├── service/                 # Business logic
│   │   └── config/                  # Configuration classes
│   ├── src/main/resources/
│   │   └── application.yml          # Application configuration
│   └── pom.xml                      # Maven dependencies
├── frontend/                        # React application
│   ├── src/
│   │   ├── components/              # React components
│   │   ├── services/                # API services
│   │   └── types/                   # TypeScript types
│   ├── public/
│   └── package.json                 # Node.js dependencies
├── database/                        # Database setup scripts
│   ├── setup-mysql.sql             # MySQL schema and data
│   ├── setup-mysql.sh              # Linux/Mac setup script
│   └── setup-mysql.bat             # Windows setup script
├── docs/                            # Documentation
│   ├── API_DOCUMENTATION.md
│   ├── DATABASE_SCHEMA.md
│   ├── DESIGN_DOCUMENT.html
│   ├── TESTING_STRATEGY.md
│   ├── UNIT_TESTING_PLAN.md
│   ├── INTEGRATION_TESTING_PLAN.md
│   └── PERFORMANCE_TESTING_PLAN.md
├── demo/                            # Demo pages
│   ├── index.html                   # Main demo page
│   ├── dashboard.html               # Dashboard demo
│   ├── receipt-scanner.html         # Receipt scanner demo
│   ├── expense-management.html      # Expense management demo
│   └── analytics.html               # Analytics demo
├── run-application.bat              # Windows automated runner
├── run-application.sh               # Linux/Mac automated runner
├── STEP_BY_STEP_SETUP.md           # Detailed setup guide
├── MYSQL_MIGRATION_GUIDE.md        # MySQL migration guide
└── README.md                        # This file
```

## 🚀 Quick Start

### Prerequisites
- Java 17 or higher
- Node.js 16 or higher
- Maven 3.6 or higher
- Git

### 🚀 Automated Setup (Recommended)

#### For Windows Users
```bash
# Navigate to project directory
cd expense-tracker-project

# Run the quick start script
quick-start.bat
```

#### For Linux/Mac Users
```bash
# Navigate to project directory
cd expense-tracker-project

# Make script executable
chmod +x quick-start.sh

# Run the quick start script
./quick-start.sh
```

### �� Manual Setup

#### Database Setup

1. **Install MySQL** (if not already installed)
   ```bash
   # Windows: Download from https://dev.mysql.com/downloads/mysql/
   # macOS: brew install mysql
   # Linux: sudo apt-get install mysql-server
   ```

2. **Setup Database**
   ```bash
   cd database
   # Linux/Mac:
   chmod +x setup-mysql.sh
   ./setup-mysql.sh
   # Windows:
   setup-mysql.bat
   ```

#### Backend Setup

1. **Navigate to backend directory**
   ```bash
   cd expense-tracker-project/backend
   ```

2. **Build the application**
   ```bash
   mvn clean install
   ```

3. **Run the Spring Boot application**
   ```bash
   mvn spring-boot:run
   ```

4. **Access the application**
   - API Base URL: `http://localhost:8080/api`
   - MySQL Database: `localhost:3306/expensetracker`
   - Database URL: `jdbc:mysql://localhost:3306/expensetracker`
   - Username: `expensetracker_user`
   - Password: `expensetracker_password`

### Frontend Setup

1. **Navigate to frontend directory**
   ```bash
   cd expense-tracker-project/frontend
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Start the development server**
   ```bash
   npm start
   ```

4. **Access the application**
   - Frontend URL: `http://localhost:3000`

### 🧪 Test the Application

After starting the application, you can run the demo test:

#### For Windows Users
```bash
demo-test.bat
```

#### For Linux/Mac Users
```bash
chmod +x demo-test.sh
./demo-test.sh
```

### 📖 Detailed Setup Guide

For comprehensive setup instructions, troubleshooting, and configuration details, see:
- **Local Setup Guide**: `LOCAL_SETUP_GUIDE.md`

## 📊 API Endpoints

### Authentication
- `POST /auth/login` - User login
- `POST /auth/register` - User registration

### Expenses
- `GET /expenses` - Get all expenses (with pagination and filters)
- `POST /expenses` - Create new expense
- `GET /expenses/{id}` - Get expense by ID
- `PUT /expenses/{id}` - Update expense
- `DELETE /expenses/{id}` - Delete expense

### Receipt Scanning
- `POST /expenses/scan-receipt` - Scan receipt image
- `POST /expenses/{id}/receipt` - Upload receipt for existing expense

### Analytics
- `GET /expenses/statistics` - Get expense statistics
- `GET /expenses/analytics/spending-by-category` - Spending by category
- `GET /expenses/analytics/spending-trend` - Spending trend over time

### Categories
- `GET /categories` - Get all categories
- `POST /categories` - Create new category
- `PUT /categories/{id}` - Update category
- `DELETE /categories/{id}` - Delete category

## 🔧 Configuration

### Backend Configuration
The application uses `application.yml` for configuration:

```yaml
server:
  port: 8080
  servlet:
    context-path: /api/v1

spring:
  datasource:
    url: jdbc:h2:mem:expensetracker
    driver-class-name: org.h2.Driver
    username: sa
    password: password

jwt:
  secret: your-secret-key-here
  expiration: 86400000

ocr:
  tesseract:
    data-path: /usr/share/tessdata
    language: eng
    confidence-threshold: 60.0
```

### Frontend Configuration
The frontend uses environment variables:

```env
REACT_APP_API_BASE_URL=http://localhost:8080/api/v1
```

## 🧪 Testing

### Backend Tests
```bash
cd backend
mvn test
```

### Frontend Tests
```bash
cd frontend
npm test
```

## 📈 Features in Detail

### OCR Receipt Scanning
- Supports multiple image formats (JPEG, PNG, GIF, BMP)
- Extracts merchant name, total amount, tax, date, and line items
- Confidence scoring for extracted data
- Automatic expense creation from scanned data

### Smart Categorization
- Default categories: Food & Dining, Transportation, Shopping, etc.
- Custom category creation
- Category-based spending analytics
- Color-coded category visualization

### Budget Tracking
- Monthly/yearly budget setting
- Real-time budget vs actual spending
- Budget alerts and notifications
- Category-specific budgets

### Multi-Currency Support
- Support for 8+ currencies (USD, EUR, GBP, JPY, etc.)
- Exchange rate integration
- Currency conversion for reporting
- Default currency per user

### Analytics & Reporting
- Spending by category charts
- Monthly spending trends
- Daily average spending
- Export to CSV
- Tax preparation reports

## 🔒 Security

- JWT-based authentication
- Password hashing with BCrypt
- CORS configuration
- Input validation and sanitization
- Rate limiting (100 requests/minute per user)

## 🚀 Deployment

### Backend Deployment
1. Build the JAR file:
   ```bash
   mvn clean package
   ```

2. Run the JAR:
   ```bash
   java -jar target/expense-tracker-backend-1.0.0.jar
   ```

### Frontend Deployment
1. Build the production bundle:
   ```bash
   npm run build
   ```

2. Deploy the `build` folder to your web server

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📚 Documentation

### Core Documentation
- **API Documentation**: `docs/API_DOCUMENTATION.md` - Comprehensive REST API documentation
- **Database Schema**: `docs/DATABASE_SCHEMA.md` - MySQL database schema and configuration
- **Design Document**: `docs/DESIGN_DOCUMENT.html` - Complete system design and architecture

### Testing Documentation
- **Testing Strategy**: `docs/TESTING_STRATEGY.md` - Overall testing methodology
- **Unit Testing Plan**: `docs/UNIT_TESTING_PLAN.md` - Detailed unit testing strategy
- **Integration Testing Plan**: `docs/INTEGRATION_TESTING_PLAN.md` - Component integration testing
- **Performance Testing Plan**: `docs/PERFORMANCE_TESTING_PLAN.md` - Load and stress testing

### Setup Documentation
- **Step-by-Step Setup**: `STEP_BY_STEP_SETUP.md` - Detailed local setup guide
- **MySQL Migration**: `MYSQL_MIGRATION_GUIDE.md` - Database migration guide

## 🆘 Support

For support and questions:
- Create an issue in the GitHub repository
- Check the documentation in the `docs/` folder
- Review the API documentation

## 🎯 Roadmap

### Phase 1 (Current)
- ✅ Basic expense management
- ✅ OCR receipt scanning
- ✅ User authentication
- ✅ Basic analytics

### Phase 2 (Next)
- 🔄 Advanced analytics dashboard
- 🔄 Budget alerts and notifications
- 🔄 Multi-currency exchange rates
- 🔄 Export functionality

### Phase 3 (Future)
- 📋 Mobile app development
- 📋 Bank account integration
- 📋 Receipt storage in cloud
- 📋 AI-powered spending insights

---

**Built with ❤️ using Spring Boot and React** 