# Unit Testing Plan - Expense Tracker

## 🎯 **Overview**

This document outlines the unit testing strategy for the Expense Tracker application, covering backend services, frontend components, and utility functions. Unit tests focus on testing individual components in isolation with mocked dependencies.

## 📋 **Testing Framework**

### **Backend Testing**
- **Framework**: JUnit 5 + Mockito
- **Build Tool**: Maven
- **Coverage Tool**: JaCoCo
- **Target Coverage**: >80%

### **Frontend Testing**
- **Framework**: Jest + React Testing Library
- **Build Tool**: npm
- **Coverage Tool**: Jest Coverage
- **Target Coverage**: >75%

## 🏗️ **Backend Unit Tests**

### **1. Service Layer Tests**

#### **ExpenseService Tests**
```java
@ExtendWith(MockitoExtension.class)
class ExpenseServiceTest {
    
    @Mock
    private ExpenseRepository expenseRepository;
    
    @Mock
    private UserRepository userRepository;
    
    @Mock
    private CategoryRepository categoryRepository;
    
    @InjectMocks
    private ExpenseService expenseService;
    
    @Test
    void createExpense_ValidExpense_ReturnsSavedExpense() {
        // Given
        ExpenseRequest request = new ExpenseRequest();
        request.setTitle("Test Expense");
        request.setAmount(new BigDecimal("100.00"));
        request.setCurrencyCode("USD");
        request.setDate(LocalDate.now());
        
        User user = createTestUser();
        Category category = createTestCategory();
        Expense expectedExpense = createTestExpense(user, category);
        
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(categoryRepository.findById(1L)).thenReturn(Optional.of(category));
        when(expenseRepository.save(any(Expense.class))).thenReturn(expectedExpense);
        
        // When
        Expense result = expenseService.createExpense(1L, request);
        
        // Then
        assertThat(result).isNotNull();
        assertThat(result.getTitle()).isEqualTo("Test Expense");
        assertThat(result.getAmount()).isEqualTo(new BigDecimal("100.00"));
        verify(expenseRepository).save(any(Expense.class));
    }
    
    @Test
    void createExpense_InvalidUser_ThrowsException() {
        // Given
        ExpenseRequest request = new ExpenseRequest();
        request.setTitle("Test Expense");
        
        when(userRepository.findById(999L)).thenReturn(Optional.empty());
        
        // When & Then
        assertThatThrownBy(() -> expenseService.createExpense(999L, request))
            .isInstanceOf(UserNotFoundException.class)
            .hasMessage("User not found with id: 999");
    }
    
    @Test
    void getExpenses_ValidFilters_ReturnsFilteredExpenses() {
        // Given
        User user = createTestUser();
        List<Expense> expenses = Arrays.asList(
            createTestExpense(user, "Food", new BigDecimal("50.00")),
            createTestExpense(user, "Transport", new BigDecimal("30.00"))
        );
        
        when(expenseRepository.findByUserIdAndFilters(
            eq(1L), any(), any(), any(), any(), any(), any(), any(), any()))
            .thenReturn(new PageImpl<>(expenses));
        
        // When
        Page<Expense> result = expenseService.getExpenses(
            1L, null, null, null, null, null, null, null, PageRequest.of(0, 10));
        
        // Then
        assertThat(result.getContent()).hasSize(2);
        assertThat(result.getContent().get(0).getTitle()).isEqualTo("Food");
    }
    
    @Test
    void calculateTotalSpending_ValidUserId_ReturnsCorrectTotal() {
        // Given
        when(expenseRepository.calculateTotalSpendingByUser(1L))
            .thenReturn(new BigDecimal("1500.00"));
        
        // When
        BigDecimal total = expenseService.calculateTotalSpending(1L);
        
        // Then
        assertThat(total).isEqualTo(new BigDecimal("1500.00"));
    }
}
```

#### **OcrService Tests**
```java
@ExtendWith(MockitoExtension.class)
class OcrServiceTest {
    
    @InjectMocks
    private OcrService ocrService;
    
    @Test
    void extractReceiptData_ValidImage_ReturnsReceiptData() {
        // Given
        String imageBase64 = "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQ...";
        
        // When
        ReceiptData result = ocrService.extractReceiptData(imageBase64, "jpeg");
        
        // Then
        assertThat(result).isNotNull();
        assertThat(result.getMerchantName()).isNotEmpty();
        assertThat(result.getTotalAmount()).isPositive();
        assertThat(result.getDate()).isNotNull();
    }
    
    @Test
    void extractReceiptData_InvalidImage_ThrowsException() {
        // Given
        String invalidImage = "invalid_base64_string";
        
        // When & Then
        assertThatThrownBy(() -> ocrService.extractReceiptData(invalidImage, "jpeg"))
            .isInstanceOf(OcrProcessingException.class)
            .hasMessage("Failed to process image");
    }
    
    @Test
    void parseReceiptText_ValidText_ExtractsCorrectData() {
        // Given
        String receiptText = """
            WALMART STORE #1234
            123 MAIN STREET
            CITY, STATE 12345
            
            BREAD                    $2.99
            MILK                     $3.49
            EGGS                     $4.99
            
            SUBTOTAL                $11.47
            TAX                     $0.92
            TOTAL                   $12.39
            """;
        
        // When
        ReceiptData result = ocrService.parseReceiptText(receiptText);
        
        // Then
        assertThat(result.getMerchantName()).isEqualTo("WALMART STORE #1234");
        assertThat(result.getTotalAmount()).isEqualTo(new BigDecimal("12.39"));
        assertThat(result.getTaxAmount()).isEqualTo(new BigDecimal("0.92"));
        assertThat(result.getItems()).hasSize(3);
    }
}
```

#### **UserService Tests**
```java
@ExtendWith(MockitoExtension.class)
class UserServiceTest {
    
    @Mock
    private UserRepository userRepository;
    
    @Mock
    private PasswordEncoder passwordEncoder;
    
    @InjectMocks
    private UserService userService;
    
    @Test
    void createUser_ValidUser_ReturnsSavedUser() {
        // Given
        UserRegistrationRequest request = new UserRegistrationRequest();
        request.setUsername("testuser");
        request.setEmail("test@example.com");
        request.setPassword("password123");
        request.setFirstName("John");
        request.setLastName("Doe");
        
        User expectedUser = createTestUser();
        expectedUser.setId(1L);
        
        when(userRepository.existsByUsername("testuser")).thenReturn(false);
        when(userRepository.existsByEmail("test@example.com")).thenReturn(false);
        when(passwordEncoder.encode("password123")).thenReturn("encoded_password");
        when(userRepository.save(any(User.class))).thenReturn(expectedUser);
        
        // When
        User result = userService.createUser(request);
        
        // Then
        assertThat(result).isNotNull();
        assertThat(result.getUsername()).isEqualTo("testuser");
        assertThat(result.getEmail()).isEqualTo("test@example.com");
        verify(passwordEncoder).encode("password123");
    }
    
    @Test
    void createUser_DuplicateUsername_ThrowsException() {
        // Given
        UserRegistrationRequest request = new UserRegistrationRequest();
        request.setUsername("existinguser");
        request.setEmail("test@example.com");
        
        when(userRepository.existsByUsername("existinguser")).thenReturn(true);
        
        // When & Then
        assertThatThrownBy(() -> userService.createUser(request))
            .isInstanceOf(UserAlreadyExistsException.class)
            .hasMessage("Username already exists");
    }
}
```

### **2. Repository Layer Tests**

#### **ExpenseRepository Tests**
```java
@DataJpaTest
class ExpenseRepositoryTest {
    
    @Autowired
    private ExpenseRepository expenseRepository;
    
    @Autowired
    private TestEntityManager entityManager;
    
    @Test
    void findByUserId_ValidUserId_ReturnsExpenses() {
        // Given
        User user = createTestUser();
        Expense expense1 = createTestExpense(user, "Food", new BigDecimal("50.00"));
        Expense expense2 = createTestExpense(user, "Transport", new BigDecimal("30.00"));
        
        entityManager.persist(user);
        entityManager.persist(expense1);
        entityManager.persist(expense2);
        entityManager.flush();
        
        // When
        List<Expense> expenses = expenseRepository.findByUserId(user.getId());
        
        // Then
        assertThat(expenses).hasSize(2);
        assertThat(expenses).extracting("title")
            .containsExactlyInAnyOrder("Food", "Transport");
    }
    
    @Test
    void findByUserIdAndDateBetween_ValidRange_ReturnsExpenses() {
        // Given
        User user = createTestUser();
        LocalDate startDate = LocalDate.now().minusDays(7);
        LocalDate endDate = LocalDate.now();
        
        Expense expense1 = createTestExpense(user, "Food", new BigDecimal("50.00"));
        expense1.setDate(LocalDate.now().minusDays(3));
        
        Expense expense2 = createTestExpense(user, "Transport", new BigDecimal("30.00"));
        expense2.setDate(LocalDate.now().minusDays(10)); // Outside range
        
        entityManager.persist(user);
        entityManager.persist(expense1);
        entityManager.persist(expense2);
        entityManager.flush();
        
        // When
        List<Expense> expenses = expenseRepository.findByUserIdAndDateBetween(
            user.getId(), startDate, endDate);
        
        // Then
        assertThat(expenses).hasSize(1);
        assertThat(expenses.get(0).getTitle()).isEqualTo("Food");
    }
    
    @Test
    void calculateTotalSpendingByUser_ValidUserId_ReturnsCorrectTotal() {
        // Given
        User user = createTestUser();
        createTestExpense(user, "Food", new BigDecimal("50.00"));
        createTestExpense(user, "Transport", new BigDecimal("30.00"));
        
        entityManager.persist(user);
        entityManager.flush();
        
        // When
        BigDecimal total = expenseRepository.calculateTotalSpendingByUser(user.getId());
        
        // Then
        assertThat(total).isEqualTo(new BigDecimal("80.00"));
    }
}
```

### **3. Utility Class Tests**

#### **DateUtils Tests**
```java
class DateUtilsTest {
    
    @Test
    void formatDate_ValidDate_ReturnsFormattedString() {
        // Given
        LocalDate date = LocalDate.of(2024, 1, 15);
        
        // When
        String result = DateUtils.formatDate(date);
        
        // Then
        assertThat(result).isEqualTo("2024-01-15");
    }
    
    @Test
    void parseDate_ValidString_ReturnsLocalDate() {
        // Given
        String dateString = "2024-01-15";
        
        // When
        LocalDate result = DateUtils.parseDate(dateString);
        
        // Then
        assertThat(result).isEqualTo(LocalDate.of(2024, 1, 15));
    }
    
    @Test
    void getCurrentMonthRange_ReturnsCorrectRange() {
        // When
        DateRange result = DateUtils.getCurrentMonthRange();
        
        // Then
        assertThat(result.getStartDate()).isEqualTo(LocalDate.now().withDayOfMonth(1));
        assertThat(result.getEndDate()).isEqualTo(LocalDate.now().withDayOfMonth(
            LocalDate.now().lengthOfMonth()));
    }
}
```

#### **ValidationUtils Tests**
```java
class ValidationUtilsTest {
    
    @Test
    void isValidEmail_ValidEmail_ReturnsTrue() {
        // Given
        String validEmail = "test@example.com";
        
        // When
        boolean result = ValidationUtils.isValidEmail(validEmail);
        
        // Then
        assertThat(result).isTrue();
    }
    
    @Test
    void isValidEmail_InvalidEmail_ReturnsFalse() {
        // Given
        String invalidEmail = "invalid-email";
        
        // When
        boolean result = ValidationUtils.isValidEmail(invalidEmail);
        
        // Then
        assertThat(result).isFalse();
    }
    
    @Test
    void isValidAmount_PositiveAmount_ReturnsTrue() {
        // Given
        BigDecimal amount = new BigDecimal("100.50");
        
        // When
        boolean result = ValidationUtils.isValidAmount(amount);
        
        // Then
        assertThat(result).isTrue();
    }
    
    @Test
    void isValidAmount_NegativeAmount_ReturnsFalse() {
        // Given
        BigDecimal amount = new BigDecimal("-50.00");
        
        // When
        boolean result = ValidationUtils.isValidAmount(amount);
        
        // Then
        assertThat(result).isFalse();
    }
}
```

## ⚛️ **Frontend Unit Tests**

### **1. Component Tests**

#### **Dashboard Component Tests**
```typescript
import { render, screen, waitFor } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from 'react-query';
import Dashboard from '../Dashboard';
import { mockExpenseData, mockCategoryData } from '../__mocks__/data';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: false,
    },
  },
});

describe('Dashboard Component', () => {
  beforeEach(() => {
    queryClient.clear();
  });

  it('renders dashboard with statistics', async () => {
    // Given
    render(
      <QueryClientProvider client={queryClient}>
        <Dashboard />
      </QueryClientProvider>
    );

    // When & Then
    await waitFor(() => {
      expect(screen.getByText('Total Spending')).toBeInTheDocument();
      expect(screen.getByText('Total Expenses')).toBeInTheDocument();
      expect(screen.getByText('Daily Average')).toBeInTheDocument();
    });
  });

  it('displays spending chart', async () => {
    // Given
    render(
      <QueryClientProvider client={queryClient}>
        <Dashboard />
      </QueryClientProvider>
    );

    // When & Then
    await waitFor(() => {
      expect(screen.getByText('Spending by Category')).toBeInTheDocument();
    });
  });

  it('shows quick action buttons', () => {
    // Given
    render(
      <QueryClientProvider client={queryClient}>
        <Dashboard />
      </QueryClientProvider>
    );

    // When & Then
    expect(screen.getByText('Add Expense')).toBeInTheDocument();
    expect(screen.getByText('Scan Receipt')).toBeInTheDocument();
    expect(screen.getByText('View Analytics')).toBeInTheDocument();
  });
});
```

#### **ReceiptScanner Component Tests**
```typescript
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from 'react-query';
import ReceiptScanner from '../ReceiptScanner';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: false,
    },
  },
});

describe('ReceiptScanner Component', () => {
  beforeEach(() => {
    queryClient.clear();
  });

  it('renders upload area', () => {
    // Given
    render(
      <QueryClientProvider client={queryClient}>
        <ReceiptScanner />
      </QueryClientProvider>
    );

    // When & Then
    expect(screen.getByText('Drop receipt image here')).toBeInTheDocument();
    expect(screen.getByText('or click to browse')).toBeInTheDocument();
  });

  it('handles file upload', async () => {
    // Given
    const file = new File(['test'], 'receipt.jpg', { type: 'image/jpeg' });
    
    render(
      <QueryClientProvider client={queryClient}>
        <ReceiptScanner />
      </QueryClientProvider>
    );

    // When
    const uploadArea = screen.getByTestId('upload-area');
    fireEvent.drop(uploadArea, {
      dataTransfer: {
        files: [file],
      },
    });

    // Then
    await waitFor(() => {
      expect(screen.getByText('Processing receipt...')).toBeInTheDocument();
    });
  });

  it('displays extracted data after processing', async () => {
    // Given
    render(
      <QueryClientProvider client={queryClient}>
        <ReceiptScanner />
      </QueryClientProvider>
    );

    // When
    // Simulate successful OCR processing
    await waitFor(() => {
      expect(screen.getByText('Merchant')).toBeInTheDocument();
      expect(screen.getByText('Amount')).toBeInTheDocument();
      expect(screen.getByText('Date')).toBeInTheDocument();
    });

    // Then
    expect(screen.getByText('Create Expense')).toBeInTheDocument();
  });
});
```

### **2. Service Tests**

#### **API Service Tests**
```typescript
import { renderHook, waitFor } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from 'react-query';
import { useExpenses, useCreateExpense } from '../services/api';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: false,
    },
  },
});

describe('API Service Tests', () => {
  beforeEach(() => {
    queryClient.clear();
  });

  it('fetches expenses successfully', async () => {
    // Given
    const mockExpenses = [
      { id: 1, title: 'Food', amount: 50.00 },
      { id: 2, title: 'Transport', amount: 30.00 },
    ];

    global.fetch = jest.fn().mockResolvedValue({
      ok: true,
      json: async () => ({ content: mockExpenses }),
    });

    // When
    const { result } = renderHook(() => useExpenses(), {
      wrapper: ({ children }) => (
        <QueryClientProvider client={queryClient}>
          {children}
        </QueryClientProvider>
      ),
    });

    // Then
    await waitFor(() => {
      expect(result.current.data).toEqual({ content: mockExpenses });
    });
  });

  it('creates expense successfully', async () => {
    // Given
    const newExpense = {
      title: 'Test Expense',
      amount: 100.00,
      currencyCode: 'USD',
      date: '2024-01-15',
    };

    global.fetch = jest.fn().mockResolvedValue({
      ok: true,
      json: async () => ({ id: 1, ...newExpense }),
    });

    // When
    const { result } = renderHook(() => useCreateExpense(), {
      wrapper: ({ children }) => (
        <QueryClientProvider client={queryClient}>
          {children}
        </QueryClientProvider>
      ),
    });

    // Then
    const mutation = result.current;
    await mutation.mutateAsync(newExpense);

    expect(mutation.isSuccess).toBe(true);
  });
});
```

### **3. Utility Function Tests**

#### **Date Utils Tests**
```typescript
import { formatDate, parseDate, getMonthRange } from '../utils/dateUtils';

describe('Date Utils', () => {
  it('formats date correctly', () => {
    // Given
    const date = new Date('2024-01-15');

    // When
    const result = formatDate(date);

    // Then
    expect(result).toBe('2024-01-15');
  });

  it('parses date string correctly', () => {
    // Given
    const dateString = '2024-01-15';

    // When
    const result = parseDate(dateString);

    // Then
    expect(result).toEqual(new Date('2024-01-15'));
  });

  it('gets current month range', () => {
    // When
    const result = getMonthRange();

    // Then
    expect(result.start).toBeDefined();
    expect(result.end).toBeDefined();
    expect(result.start.getMonth()).toBe(result.end.getMonth());
  });
});
```

#### **Validation Utils Tests**
```typescript
import { isValidEmail, isValidAmount, isValidDate } from '../utils/validationUtils';

describe('Validation Utils', () => {
  describe('isValidEmail', () => {
    it('returns true for valid email', () => {
      expect(isValidEmail('test@example.com')).toBe(true);
    });

    it('returns false for invalid email', () => {
      expect(isValidEmail('invalid-email')).toBe(false);
    });
  });

  describe('isValidAmount', () => {
    it('returns true for positive amount', () => {
      expect(isValidAmount(100.50)).toBe(true);
    });

    it('returns false for negative amount', () => {
      expect(isValidAmount(-50.00)).toBe(false);
    });

    it('returns false for zero amount', () => {
      expect(isValidAmount(0)).toBe(false);
    });
  });

  describe('isValidDate', () => {
    it('returns true for valid date', () => {
      expect(isValidDate('2024-01-15')).toBe(true);
    });

    it('returns false for invalid date', () => {
      expect(isValidDate('invalid-date')).toBe(false);
    });
  });
});
```

## 📊 **Test Coverage Requirements**

### **Backend Coverage Targets**
- **Service Layer**: >85%
- **Repository Layer**: >80%
- **Controller Layer**: >75%
- **Utility Classes**: >90%

### **Frontend Coverage Targets**
- **Components**: >75%
- **Services**: >80%
- **Utils**: >90%
- **Hooks**: >80%

## 🚀 **Running Unit Tests**

### **Backend Tests**
```bash
# Run all tests
mvn test

# Run specific test class
mvn test -Dtest=ExpenseServiceTest

# Run with coverage
mvn test jacoco:report

# Run tests in parallel
mvn test -Dparallel=methods -DthreadCount=4
```

### **Frontend Tests**
```bash
# Run all tests
npm test

# Run tests with coverage
npm test -- --coverage

# Run tests in watch mode
npm test -- --watch

# Run specific test file
npm test -- ReceiptScanner.test.tsx
```

## 📈 **Test Quality Metrics**

### **Code Quality**
- **Cyclomatic Complexity**: <10 per method
- **Lines of Code**: <50 per method
- **Test Method Naming**: Descriptive and clear
- **Test Organization**: Arrange-Act-Assert pattern

### **Test Quality**
- **Test Isolation**: No dependencies between tests
- **Mock Usage**: Appropriate mocking of external dependencies
- **Assertion Quality**: Specific and meaningful assertions
- **Test Data**: Realistic and comprehensive test data

## 🔄 **Continuous Integration**

### **GitHub Actions Workflow**
```yaml
name: Unit Tests

on: [push, pull_request]

jobs:
  backend-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-java@v3
        with:
          java-version: '17'
      - run: mvn test
      - run: mvn jacoco:report
      - uses: codecov/codecov-action@v3

  frontend-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      - run: npm ci
      - run: npm test -- --coverage --watchAll=false
```

This comprehensive unit testing plan ensures high code quality, maintainability, and reliability of the Expense Tracker application! 🎯 