# Database Schema - Expense Tracker

## Overview
The application uses MySQL 8.0 database with JPA/Hibernate for data persistence. The schema is designed to support multi-currency expenses, receipt scanning, and comprehensive reporting with ACID compliance and robust backup capabilities.

## Database Configuration

### MySQL Settings
- **Database Name**: expensetracker
- **Character Set**: utf8mb4
- **Collation**: utf8mb4_unicode_ci
- **Storage Engine**: InnoDB (for ACID compliance)
- **Connection URL**: jdbc:mysql://localhost:3306/expensetracker?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true

### Connection Details
- **Host**: localhost
- **Port**: 3306
- **Username**: expensetracker_user
- **Password**: expensetracker_password

## Entity Relationships

### Core Entities

#### 1. User Entity
```sql
CREATE TABLE users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    default_currency VARCHAR(3) DEFAULT 'USD',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### 2. Category Entity
```sql
CREATE TABLE categories (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    icon VARCHAR(50),
    color VARCHAR(7),
    is_default BOOLEAN DEFAULT FALSE,
    user_id BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);
```

#### 3. Currency Entity
```sql
CREATE TABLE currencies (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    code VARCHAR(3) UNIQUE NOT NULL,
    name VARCHAR(50) NOT NULL,
    symbol VARCHAR(5),
    exchange_rate DECIMAL(10,6) DEFAULT 1.0,
    is_active BOOLEAN DEFAULT TRUE,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### 4. Budget Entity
```sql
CREATE TABLE budgets (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    category_id BIGINT,
    name VARCHAR(100) NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    currency_code VARCHAR(3) NOT NULL,
    period_type ENUM('MONTHLY', 'YEARLY', 'CUSTOM') DEFAULT 'MONTHLY',
    start_date DATE NOT NULL,
    end_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (category_id) REFERENCES categories(id),
    FOREIGN KEY (currency_code) REFERENCES currencies(code)
);
```

#### 5. Expense Entity
```sql
CREATE TABLE expenses (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    category_id BIGINT,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    amount DECIMAL(15,2) NOT NULL,
    currency_code VARCHAR(3) NOT NULL,
    date DATE NOT NULL,
    receipt_image_url VARCHAR(500),
    ocr_data JSON,
    location VARCHAR(200),
    tags VARCHAR(500),
    is_reimbursable BOOLEAN DEFAULT FALSE,
    status ENUM('PENDING', 'APPROVED', 'REJECTED') DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (category_id) REFERENCES categories(id),
    FOREIGN KEY (currency_code) REFERENCES currencies(code)
);
```

#### 6. Receipt Entity
```sql
CREATE TABLE receipts (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    expense_id BIGINT NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    ocr_text TEXT,
    ocr_confidence DECIMAL(5,2),
    merchant_name VARCHAR(200),
    total_amount DECIMAL(15,2),
    tax_amount DECIMAL(15,2),
    date_from_receipt DATE,
    items JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (expense_id) REFERENCES expenses(id)
);
```

#### 7. Budget Alert Entity
```sql
CREATE TABLE budget_alerts (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    budget_id BIGINT NOT NULL,
    alert_type ENUM('WARNING', 'CRITICAL', 'EXCEEDED') NOT NULL,
    threshold_percentage DECIMAL(5,2) NOT NULL,
    message TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (budget_id) REFERENCES budgets(id)
);
```

## Indexes for Performance
```sql
-- Expense indexes
CREATE INDEX idx_expenses_user_date ON expenses(user_id, date);
CREATE INDEX idx_expenses_category ON expenses(category_id);
CREATE INDEX idx_expenses_currency ON expenses(currency_code);

-- Budget indexes
CREATE INDEX idx_budgets_user ON budgets(user_id);
CREATE INDEX idx_budgets_category ON budgets(category_id);

-- Receipt indexes
CREATE INDEX idx_receipts_expense ON receipts(expense_id);
```

## Sample Data

### Default Categories
```sql
INSERT INTO categories (name, description, icon, color, is_default) VALUES
('Food & Dining', 'Restaurants, groceries, and dining expenses', '🍽️', '#FF6B6B', TRUE),
('Transportation', 'Gas, public transport, rideshare', '🚗', '#4ECDC4', TRUE),
('Shopping', 'Clothing, electronics, general shopping', '🛍️', '#45B7D1', TRUE),
('Entertainment', 'Movies, games, hobbies', '🎬', '#96CEB4', TRUE),
('Healthcare', 'Medical expenses, prescriptions', '🏥', '#FFEAA7', TRUE),
('Utilities', 'Electricity, water, internet', '⚡', '#DDA0DD', TRUE),
('Travel', 'Hotels, flights, vacation expenses', '✈️', '#98D8C8', TRUE),
('Business', 'Work-related expenses', '💼', '#F7DC6F', TRUE);
```

### Default Currencies
```sql
INSERT INTO currencies (code, name, symbol, exchange_rate) VALUES
('USD', 'US Dollar', '$', 1.0),
('EUR', 'Euro', '€', 0.85),
('GBP', 'British Pound', '£', 0.73),
('JPY', 'Japanese Yen', '¥', 110.0),
('CAD', 'Canadian Dollar', 'C$', 1.25),
('AUD', 'Australian Dollar', 'A$', 1.35),
('CHF', 'Swiss Franc', 'CHF', 0.92),
('CNY', 'Chinese Yuan', '¥', 6.45);
```

## Data Validation Rules
1. All amounts must be positive
2. Currency codes must exist in currencies table
3. User must exist for all user-related entities
4. Category must exist for categorized expenses
5. Budget dates must be valid (start_date <= end_date)
6. OCR confidence must be between 0 and 100

## Backup Strategy
- Daily automated backups of MySQL database
- Export functionality for CSV/JSON data
- Cloud storage integration for receipt images 