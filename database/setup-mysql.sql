-- MySQL Setup Script for Expense Tracker Application
-- Run this script as MySQL root user or a user with CREATE DATABASE privileges

-- Create the database
CREATE DATABASE IF NOT EXISTS expensetracker
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

-- Create the application user
CREATE USER IF NOT EXISTS 'expensetracker_user'@'localhost' IDENTIFIED BY 'expensetracker_password';

-- Grant privileges to the user
GRANT ALL PRIVILEGES ON expensetracker.* TO 'expensetracker_user'@'localhost';

-- Grant additional privileges for development
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON expensetracker.* TO 'expensetracker_user'@'localhost';

-- Flush privileges to apply changes
FLUSH PRIVILEGES;

-- Use the database
USE expensetracker;

-- Create tables (these will be created automatically by JPA, but here for reference)
CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    default_currency VARCHAR(3) DEFAULT 'USD',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    icon VARCHAR(50),
    color VARCHAR(7),
    is_default BOOLEAN DEFAULT FALSE,
    user_id BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS currencies (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(3) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    symbol VARCHAR(5),
    exchange_rate DECIMAL(10,4) DEFAULT 1.0000,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS budgets (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    category_id BIGINT,
    name VARCHAR(100) NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    currency_code VARCHAR(3) DEFAULT 'USD',
    period VARCHAR(20) DEFAULT 'MONTHLY',
    start_date DATE,
    end_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS expenses (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    category_id BIGINT,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    amount DECIMAL(10,2) NOT NULL,
    currency_code VARCHAR(3) DEFAULT 'USD',
    date DATE NOT NULL,
    receipt_image_url VARCHAR(500),
    ocr_data JSON,
    location VARCHAR(200),
    tags VARCHAR(500),
    is_reimbursable BOOLEAN DEFAULT FALSE,
    status VARCHAR(20) DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS budget_alerts (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    budget_id BIGINT NOT NULL,
    alert_type VARCHAR(20) NOT NULL,
    threshold_percentage DECIMAL(5,2),
    message TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (budget_id) REFERENCES budgets(id) ON DELETE CASCADE
);

-- Insert default categories
INSERT INTO categories (name, description, icon, color, is_default) VALUES
('Food & Dining', 'Restaurants, groceries, and food delivery', 'utensils', '#3B82F6', TRUE),
('Transportation', 'Gas, public transit, and vehicle expenses', 'car', '#10B981', TRUE),
('Shopping', 'Retail purchases and online shopping', 'shopping-bag', '#8B5CF6', TRUE),
('Entertainment', 'Movies, games, and leisure activities', 'film', '#F59E0B', TRUE),
('Utilities', 'Electricity, water, internet, and phone bills', 'bolt', '#EF4444', TRUE),
('Healthcare', 'Medical expenses and insurance', 'heart', '#EC4899', TRUE),
('Education', 'Books, courses, and educational materials', 'graduation-cap', '#06B6D4', TRUE),
('Travel', 'Vacations and business trips', 'plane', '#84CC16', TRUE);

-- Insert default currencies
INSERT INTO currencies (code, name, symbol, exchange_rate) VALUES
('USD', 'US Dollar', '$', 1.0000),
('EUR', 'Euro', '€', 0.8500),
('GBP', 'British Pound', '£', 0.7300),
('JPY', 'Japanese Yen', '¥', 110.0000),
('CAD', 'Canadian Dollar', 'C$', 1.2500),
('AUD', 'Australian Dollar', 'A$', 1.3500),
('CHF', 'Swiss Franc', 'CHF', 0.9200),
('CNY', 'Chinese Yuan', '¥', 6.4500);

-- Create indexes for better performance
CREATE INDEX idx_expenses_user_id ON expenses(user_id);
CREATE INDEX idx_expenses_category_id ON expenses(category_id);
CREATE INDEX idx_expenses_date ON expenses(date);
CREATE INDEX idx_expenses_status ON expenses(status);
CREATE INDEX idx_budgets_user_id ON budgets(user_id);
CREATE INDEX idx_categories_user_id ON categories(user_id);

-- Show the created database and user
SELECT 'Database and user created successfully!' AS status;
SHOW DATABASES LIKE 'expensetracker';
SELECT User, Host FROM mysql.user WHERE User = 'expensetracker_user'; 