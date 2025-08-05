# API Documentation - Expense Tracker

## Overview

This document provides comprehensive API documentation for the Expense Tracker application with receipt scanning capabilities. The API is built using Spring Boot and uses MySQL database for persistent data storage.

## Database Information
- **Database**: MySQL 8.0
- **Connection**: jdbc:mysql://localhost:3306/expensetracker
- **Persistence**: ACID compliant with automatic backups
- **Performance**: Optimized with proper indexing and connection pooling

## Base URL
```
http://localhost:8080/api/v1
```

## Authentication
All endpoints require Bearer token authentication except for login/register endpoints.

### Headers
```
Authorization: Bearer <jwt_token>
Content-Type: application/json
```

## Endpoints

### Authentication

#### POST /auth/login
Login with username/email and password.

**Request Body:**
```json
{
  "username": "user@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "username": "user@example.com",
    "firstName": "John",
    "lastName": "Doe",
    "defaultCurrency": "USD"
  }
}
```

#### POST /auth/register
Register a new user.

**Request Body:**
```json
{
  "username": "newuser@example.com",
  "password": "password123",
  "firstName": "Jane",
  "lastName": "Smith",
  "defaultCurrency": "USD"
}
```

### Users

#### GET /users/profile
Get current user profile.

**Response:**
```json
{
  "id": 1,
  "username": "user@example.com",
  "firstName": "John",
  "lastName": "Doe",
  "defaultCurrency": "USD",
  "createdAt": "2024-01-01T00:00:00Z"
}
```

#### PUT /users/profile
Update user profile.

**Request Body:**
```json
{
  "firstName": "John",
  "lastName": "Doe",
  "defaultCurrency": "EUR"
}
```

### Categories

#### GET /categories
Get all categories for current user.

**Query Parameters:**
- `includeDefault` (boolean): Include default categories (default: true)

**Response:**
```json
[
  {
    "id": 1,
    "name": "Food & Dining",
    "description": "Restaurants, groceries, and dining expenses",
    "icon": "🍽️",
    "color": "#FF6B6B",
    "isDefault": true
  }
]
```

#### POST /categories
Create a new category.

**Request Body:**
```json
{
  "name": "Custom Category",
  "description": "My custom category",
  "icon": "🎯",
  "color": "#FF5733"
}
```

#### PUT /categories/{id}
Update a category.

#### DELETE /categories/{id}
Delete a category.

### Expenses

#### GET /expenses
Get all expenses for current user.

**Query Parameters:**
- `page` (int): Page number (default: 0)
- `size` (int): Page size (default: 20)
- `categoryId` (long): Filter by category
- `startDate` (date): Filter by start date (YYYY-MM-DD)
- `endDate` (date): Filter by end date (YYYY-MM-DD)
- `currency` (string): Filter by currency code
- `minAmount` (decimal): Minimum amount filter
- `maxAmount` (decimal): Maximum amount filter
- `tags` (string): Filter by tags (comma-separated)

**Response:**
```json
{
  "content": [
    {
      "id": 1,
      "title": "Lunch at Restaurant",
      "description": "Business lunch",
      "amount": 45.50,
      "currencyCode": "USD",
      "date": "2024-01-15",
      "category": {
        "id": 1,
        "name": "Food & Dining"
      },
      "receiptImageUrl": "https://example.com/receipt.jpg",
      "location": "New York, NY",
      "tags": "business,lunch",
      "isReimbursable": true,
      "status": "PENDING",
      "createdAt": "2024-01-15T12:00:00Z"
    }
  ],
  "totalElements": 1,
  "totalPages": 1,
  "currentPage": 0
}
```

#### POST /expenses
Create a new expense.

**Request Body:**
```json
{
  "title": "Lunch at Restaurant",
  "description": "Business lunch",
  "amount": 45.50,
  "currencyCode": "USD",
  "date": "2024-01-15",
  "categoryId": 1,
  "location": "New York, NY",
  "tags": "business,lunch",
  "isReimbursable": true
}
```

#### GET /expenses/{id}
Get expense by ID.

#### PUT /expenses/{id}
Update an expense.

#### DELETE /expenses/{id}
Delete an expense.

### Receipt Scanning

#### POST /expenses/scan-receipt
Scan receipt image and extract data.

**Request Body:**
```json
{
  "imageBase64": "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQ...",
  "imageFormat": "jpeg"
}
```

**Response:**
```json
{
  "merchantName": "McDonald's",
  "totalAmount": 12.99,
  "taxAmount": 1.08,
  "date": "2024-01-15",
  "items": [
    {
      "name": "Big Mac",
      "price": 8.99,
      "quantity": 1
    }
  ],
  "confidence": 95.5,
  "ocrText": "McDonald's\nBig Mac $8.99\nTax $1.08\nTotal $12.99"
}
```

#### POST /expenses/{id}/receipt
Upload receipt for existing expense.

**Request Body:**
```json
{
  "imageBase64": "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQ...",
  "imageFormat": "jpeg"
}
```

### Budgets

#### GET /budgets
Get all budgets for current user.

**Response:**
```json
[
  {
    "id": 1,
    "name": "Monthly Food Budget",
    "amount": 500.00,
    "currencyCode": "USD",
    "periodType": "MONTHLY",
    "startDate": "2024-01-01",
    "endDate": "2024-01-31",
    "category": {
      "id": 1,
      "name": "Food & Dining"
    },
    "spentAmount": 350.00,
    "remainingAmount": 150.00,
    "percentageUsed": 70.0,
    "isActive": true
  }
]
```

#### POST /budgets
Create a new budget.

**Request Body:**
```json
{
  "name": "Monthly Food Budget",
  "amount": 500.00,
  "currencyCode": "USD",
  "periodType": "MONTHLY",
  "startDate": "2024-01-01",
  "endDate": "2024-01-31",
  "categoryId": 1
}
```

#### GET /budgets/{id}/alerts
Get budget alerts.

#### POST /budgets/{id}/alerts
Create budget alert.

### Currencies

#### GET /currencies
Get all available currencies.

**Response:**
```json
[
  {
    "code": "USD",
    "name": "US Dollar",
    "symbol": "$",
    "exchangeRate": 1.0,
    "isActive": true
  }
]
```

### Analytics

#### GET /analytics/spending-by-category
Get spending breakdown by category.

**Query Parameters:**
- `startDate` (date): Start date (YYYY-MM-DD)
- `endDate` (date): End date (YYYY-MM-DD)
- `currency` (string): Currency code for conversion

**Response:**
```json
{
  "categories": [
    {
      "categoryId": 1,
      "categoryName": "Food & Dining",
      "totalAmount": 450.00,
      "percentage": 45.0,
      "count": 15
    }
  ],
  "totalAmount": 1000.00
}
```

#### GET /analytics/spending-trend
Get spending trend over time.

**Query Parameters:**
- `period` (string): Period type (daily, weekly, monthly)
- `startDate` (date): Start date
- `endDate` (date): End date

**Response:**
```json
{
  "trends": [
    {
      "period": "2024-01-01",
      "amount": 150.00,
      "count": 5
    }
  ]
}
```

#### GET /analytics/budget-vs-actual
Get budget vs actual spending.

**Response:**
```json
{
  "budgets": [
    {
      "budgetId": 1,
      "budgetName": "Monthly Food Budget",
      "budgetAmount": 500.00,
      "actualAmount": 450.00,
      "difference": 50.00,
      "percentageUsed": 90.0
    }
  ]
}
```

### Reports

#### GET /reports/expense-summary
Generate expense summary report.

**Query Parameters:**
- `startDate` (date): Start date
- `endDate` (date): End date
- `format` (string): Report format (csv, json)

#### GET /reports/tax-report
Generate tax report.

**Query Parameters:**
- `year` (int): Tax year
- `format` (string): Report format

### Export

#### GET /export/expenses
Export expenses to CSV.

**Query Parameters:**
- `startDate` (date): Start date
- `endDate` (date): End date
- `categoryId` (long): Filter by category

## Error Responses

### Standard Error Format
```json
{
  "timestamp": "2024-01-15T12:00:00Z",
  "status": 400,
  "error": "Bad Request",
  "message": "Validation failed",
  "path": "/api/v1/expenses",
  "details": [
    {
      "field": "amount",
      "message": "Amount must be positive"
    }
  ]
}
```

### Common HTTP Status Codes
- `200`: Success
- `201`: Created
- `400`: Bad Request
- `401`: Unauthorized
- `403`: Forbidden
- `404`: Not Found
- `422`: Unprocessable Entity
- `500`: Internal Server Error

## Rate Limiting
- 100 requests per minute per user
- 1000 requests per hour per user

## Pagination
All list endpoints support pagination with the following parameters:
- `page`: Page number (0-based)
- `size`: Page size (default: 20, max: 100)

Response includes pagination metadata:
```json
{
  "content": [...],
  "totalElements": 100,
  "totalPages": 5,
  "currentPage": 0,
  "size": 20,
  "first": true,
  "last": false
}
``` 