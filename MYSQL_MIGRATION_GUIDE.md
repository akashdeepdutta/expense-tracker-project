# MySQL Migration Guide

## 🎯 **Overview**

This guide explains how to migrate the Expense Tracker application from H2 in-memory database to MySQL persistent database.

## 📋 **What Changed**

### **Backend Changes**
- **Dependencies**: Replaced H2 with MySQL connector
- **Configuration**: Updated `application.yml` for MySQL connection
- **Database**: Changed from in-memory to persistent storage

### **Key Differences**

| Feature | H2 (Previous) | MySQL (Current) |
|---------|---------------|-----------------|
| **Storage** | In-memory | Persistent |
| **Data Loss** | Yes (on restart) | No |
| **Performance** | Fast startup | Slower startup |
| **Scalability** | Limited | Production ready |
| **Backup** | Not needed | Required |
| **Console** | Web-based | Command line/GUI |

## 🚀 **Migration Steps**

### **Step 1: Install MySQL**

#### **Windows**
1. Download MySQL from https://dev.mysql.com/downloads/mysql/
2. Or use XAMPP: https://www.apachefriends.org/
3. Or use WAMP: https://www.wampserver.com/

#### **macOS**
```bash
# Using Homebrew
brew install mysql
brew services start mysql
```

#### **Linux (Ubuntu/Debian)**
```bash
sudo apt-get update
sudo apt-get install mysql-server
sudo systemctl start mysql
sudo systemctl enable mysql
```

### **Step 2: Setup Database**

#### **Automated Setup**
```bash
# Navigate to database directory
cd database

# Run setup script
# Linux/Mac:
chmod +x setup-mysql.sh
./setup-mysql.sh

# Windows:
setup-mysql.bat
```

#### **Manual Setup**
```bash
# Connect to MySQL as root
mysql -u root -p

# Run the setup script
source setup-mysql.sql;
```

### **Step 3: Update Application**

The application has already been updated with:
- MySQL dependency in `pom.xml`
- MySQL configuration in `application.yml`
- Database setup scripts

### **Step 4: Test Migration**

```bash
# Test database connection
mysql -u expensetracker_user -pexpensetracker_password -h localhost expensetracker -e "SELECT 'Connection successful!' AS status;"

# Start the application
cd backend
mvn spring-boot:run
```

## 🔧 **Configuration Details**

### **Database Connection**
```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/expensetracker?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true
    driver-class-name: com.mysql.cj.jdbc.Driver
    username: expensetracker_user
    password: expensetracker_password
```

### **JPA Configuration**
```yaml
jpa:
  hibernate:
    ddl-auto: update  # Changed from create-drop
  properties:
    hibernate:
      dialect: org.hibernate.dialect.MySQLDialect
```

## 📊 **Database Schema**

### **Tables Created**
- `users` - User accounts and profiles
- `categories` - Expense categories
- `currencies` - Supported currencies
- `expenses` - Expense records
- `budgets` - Budget configurations
- `budget_alerts` - Budget alert settings

### **Default Data**
- **Categories**: Food & Dining, Transportation, Shopping, etc.
- **Currencies**: USD, EUR, GBP, JPY, CAD, AUD, CHF, CNY

## 🛠️ **Database Management**

### **Command Line Access**
```bash
# Connect to database
mysql -u expensetracker_user -pexpensetracker_password -h localhost expensetracker

# Show tables
SHOW TABLES;

# View data
SELECT * FROM categories;
SELECT * FROM currencies;
SELECT * FROM expenses;
```

### **GUI Tools**
- **MySQL Workbench**: Official MySQL GUI
- **phpMyAdmin**: Web-based management (with XAMPP/WAMP)
- **DBeaver**: Universal database tool

### **Backup and Restore**
```bash
# Create backup
mysqldump -u expensetracker_user -pexpensetracker_password expensetracker > backup.sql

# Restore backup
mysql -u expensetracker_user -pexpensetracker_password expensetracker < backup.sql
```

## 🔍 **Troubleshooting**

### **Common Issues**

#### **Connection Refused**
```bash
# Check if MySQL is running
sudo systemctl status mysql  # Linux
brew services list | grep mysql  # macOS
net start | findstr MySQL  # Windows

# Start MySQL if not running
sudo systemctl start mysql  # Linux
brew services start mysql  # macOS
net start MySQL  # Windows
```

#### **Access Denied**
```bash
# Reset user password
mysql -u root -p
ALTER USER 'expensetracker_user'@'localhost' IDENTIFIED BY 'expensetracker_password';
FLUSH PRIVILEGES;
```

#### **Database Not Found**
```bash
# Create database manually
mysql -u root -p
CREATE DATABASE expensetracker;
GRANT ALL PRIVILEGES ON expensetracker.* TO 'expensetracker_user'@'localhost';
FLUSH PRIVILEGES;
```

#### **Application Won't Start**
```bash
# Check application logs
tail -f logs/application.log

# Verify database connection
mysql -u expensetracker_user -pexpensetracker_password -h localhost expensetracker -e "SELECT 1;"
```

## 📈 **Performance Considerations**

### **MySQL Optimization**
```sql
-- Create indexes for better performance
CREATE INDEX idx_expenses_user_id ON expenses(user_id);
CREATE INDEX idx_expenses_date ON expenses(date);
CREATE INDEX idx_expenses_category_id ON expenses(category_id);
```

### **Connection Pooling**
The application uses HikariCP for connection pooling:
```yaml
spring:
  datasource:
    hikari:
      maximum-pool-size: 10
      minimum-idle: 5
      connection-timeout: 30000
```

## 🔒 **Security Considerations**

### **Database Security**
- Use strong passwords
- Limit user privileges
- Enable SSL connections in production
- Regular security updates

### **Application Security**
- JWT token authentication
- Input validation
- SQL injection prevention (JPA handles this)
- CORS configuration

## 📚 **Production Deployment**

### **Environment Variables**
```bash
# Set database credentials as environment variables
export DB_HOST=localhost
export DB_PORT=3306
export DB_NAME=expensetracker
export DB_USER=expensetracker_user
export DB_PASSWORD=expensetracker_password
```

### **Docker Support**
```dockerfile
# Example Docker configuration
FROM mysql:8.0
ENV MYSQL_DATABASE=expensetracker
ENV MYSQL_USER=expensetracker_user
ENV MYSQL_PASSWORD=expensetracker_password
ENV MYSQL_ROOT_PASSWORD=root_password
```

## 🔄 **Rollback Plan**

If you need to revert to H2:

### **1. Update Dependencies**
```xml
<!-- Replace MySQL with H2 -->
<dependency>
    <groupId>com.h2database</groupId>
    <artifactId>h2</artifactId>
    <scope>runtime</scope>
</dependency>
```

### **2. Update Configuration**
```yaml
spring:
  datasource:
    url: jdbc:h2:mem:expensetracker
    driver-class-name: org.h2.Driver
    username: sa
    password: password
  jpa:
    hibernate:
      ddl-auto: create-drop
    properties:
      hibernate:
        dialect: org.hibernate.dialect.H2Dialect
  h2:
    console:
      enabled: true
      path: /h2-console
```

## ✅ **Migration Checklist**

- [ ] MySQL installed and running
- [ ] Database created and configured
- [ ] User permissions set correctly
- [ ] Application configuration updated
- [ ] Database connection tested
- [ ] Application starts successfully
- [ ] Data persistence verified
- [ ] Performance acceptable
- [ ] Backup strategy in place

## 🎉 **Benefits of MySQL Migration**

### **Production Ready**
- Persistent data storage
- ACID compliance
- Scalability
- Backup and recovery

### **Better Performance**
- Optimized queries
- Connection pooling
- Index optimization
- Query caching

### **Enhanced Features**
- Complex queries
- Stored procedures
- Triggers
- Foreign key constraints

---

**Migration Complete!** 🎉 Your Expense Tracker application is now using MySQL for persistent data storage. 