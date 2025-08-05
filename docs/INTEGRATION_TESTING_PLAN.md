# Integration Testing Plan - Expense Tracker

## 🎯 **Overview**

This document outlines the integration testing strategy for the Expense Tracker application, focusing on testing the interaction between different components, layers, and external systems. Integration tests verify that components work together correctly.

## 📋 **Testing Framework**

### **Backend Integration Testing**
- **Framework**: Spring Boot Test + TestContainers
- **Database**: MySQL Test Container
- **Build Tool**: Maven
- **Coverage Target**: >70%

### **Frontend Integration Testing**
- **Framework**: Cypress + React Testing Library
- **Build Tool**: npm
- **Coverage Target**: >60%

## 🏗️ **Backend Integration Tests**

### **1. Repository Integration Tests**

#### **ExpenseRepository Integration Tests**
```java
@DataJpaTest
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
@Testcontainers
class ExpenseRepositoryIntegrationTest {
    
    @Container
    static MySQLContainer<?> mysql = new MySQLContainer<>("mysql:8.0")
        .withDatabaseName("test_expensetracker")
        .withUsername("test_user")
        .withPassword("test_password");
    
    @Autowired
    private ExpenseRepository expenseRepository;
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private CategoryRepository categoryRepository;
    
    @Autowired
    private TestEntityManager entityManager;
    
    @DynamicPropertySource
    static void databaseProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", mysql::getJdbcUrl);
        registry.add("spring.datasource.username", mysql::getUsername);
        registry.add("spring.datasource.password", mysql::getPassword);
    }
    
    @Test
    void saveAndRetrieveExpense_ShouldPersistData() {
        // Given
        User user = createTestUser();
        Category category = createTestCategory();
        Expense expense = createTestExpense(user, category);
        
        entityManager.persist(user);
        entityManager.persist(category);
        entityManager.flush();
        
        // When
        Expense savedExpense = expenseRepository.save(expense);
        Expense retrievedExpense = expenseRepository.findById(savedExpense.getId()).orElse(null);
        
        // Then
        assertThat(retrievedExpense).isNotNull();
        assertThat(retrievedExpense.getTitle()).isEqualTo("Test Expense");
        assertThat(retrievedExpense.getUser().getId()).isEqualTo(user.getId());
        assertThat(retrievedExpense.getCategory().getId()).isEqualTo(category.getId());
    }
    
    @Test
    void findByUserIdWithFilters_ShouldReturnFilteredResults() {
        // Given
        User user = createTestUser();
        Category foodCategory = createTestCategory("Food");
        Category transportCategory = createTestCategory("Transport");
        
        Expense foodExpense = createTestExpense(user, foodCategory, "Food", new BigDecimal("50.00"));
        Expense transportExpense = createTestExpense(user, transportCategory, "Transport", new BigDecimal("30.00"));
        
        entityManager.persist(user);
        entityManager.persist(foodCategory);
        entityManager.persist(transportCategory);
        entityManager.persist(foodExpense);
        entityManager.persist(transportExpense);
        entityManager.flush();
        
        // When
        List<Expense> foodExpenses = expenseRepository.findByUserIdAndCategoryId(
            user.getId(), foodCategory.getId());
        
        // Then
        assertThat(foodExpenses).hasSize(1);
        assertThat(foodExpenses.get(0).getTitle()).isEqualTo("Food");
    }
    
    @Test
    void calculateTotalSpendingByUser_ShouldReturnCorrectTotal() {
        // Given
        User user = createTestUser();
        Category category = createTestCategory();
        
        createTestExpense(user, category, "Expense 1", new BigDecimal("100.00"));
        createTestExpense(user, category, "Expense 2", new BigDecimal("200.00"));
        createTestExpense(user, category, "Expense 3", new BigDecimal("300.00"));
        
        entityManager.persist(user);
        entityManager.persist(category);
        entityManager.flush();
        
        // When
        BigDecimal total = expenseRepository.calculateTotalSpendingByUser(user.getId());
        
        // Then
        assertThat(total).isEqualTo(new BigDecimal("600.00"));
    }
}
```

#### **UserRepository Integration Tests**
```java
@DataJpaTest
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
@Testcontainers
class UserRepositoryIntegrationTest {
    
    @Container
    static MySQLContainer<?> mysql = new MySQLContainer<>("mysql:8.0")
        .withDatabaseName("test_expensetracker")
        .withUsername("test_user")
        .withPassword("test_password");
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private TestEntityManager entityManager;
    
    @DynamicPropertySource
    static void databaseProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", mysql::getJdbcUrl);
        registry.add("spring.datasource.username", mysql::getUsername);
        registry.add("spring.datasource.password", mysql::getPassword);
    }
    
    @Test
    void saveAndRetrieveUser_ShouldPersistData() {
        // Given
        User user = new User();
        user.setUsername("testuser");
        user.setEmail("test@example.com");
        user.setPasswordHash("hashed_password");
        user.setFirstName("John");
        user.setLastName("Doe");
        user.setDefaultCurrency("USD");
        
        // When
        User savedUser = userRepository.save(user);
        User retrievedUser = userRepository.findById(savedUser.getId()).orElse(null);
        
        // Then
        assertThat(retrievedUser).isNotNull();
        assertThat(retrievedUser.getUsername()).isEqualTo("testuser");
        assertThat(retrievedUser.getEmail()).isEqualTo("test@example.com");
    }
    
    @Test
    void findByUsername_ShouldReturnUser() {
        // Given
        User user = createTestUser();
        entityManager.persist(user);
        entityManager.flush();
        
        // When
        Optional<User> foundUser = userRepository.findByUsername("testuser");
        
        // Then
        assertThat(foundUser).isPresent();
        assertThat(foundUser.get().getUsername()).isEqualTo("testuser");
    }
    
    @Test
    void existsByUsername_DuplicateUsername_ShouldReturnTrue() {
        // Given
        User user1 = createTestUser("user1");
        User user2 = createTestUser("user1"); // Same username
        
        entityManager.persist(user1);
        entityManager.flush();
        
        // When
        boolean exists = userRepository.existsByUsername("user1");
        
        // Then
        assertThat(exists).isTrue();
    }
}
```

### **2. Service Integration Tests**

#### **ExpenseService Integration Tests**
```java
@SpringBootTest
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
@Testcontainers
@Transactional
class ExpenseServiceIntegrationTest {
    
    @Container
    static MySQLContainer<?> mysql = new MySQLContainer<>("mysql:8.0")
        .withDatabaseName("test_expensetracker")
        .withUsername("test_user")
        .withPassword("test_password");
    
    @Autowired
    private ExpenseService expenseService;
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private CategoryRepository categoryRepository;
    
    @Autowired
    private ExpenseRepository expenseRepository;
    
    @DynamicPropertySource
    static void databaseProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", mysql::getJdbcUrl);
        registry.add("spring.datasource.username", mysql::getUsername);
        registry.add("spring.datasource.password", mysql::getPassword);
    }
    
    @Test
    void createExpense_ValidRequest_ShouldCreateExpense() {
        // Given
        User user = createTestUser();
        Category category = createTestCategory();
        
        userRepository.save(user);
        categoryRepository.save(category);
        
        ExpenseRequest request = new ExpenseRequest();
        request.setTitle("Integration Test Expense");
        request.setAmount(new BigDecimal("150.00"));
        request.setCurrencyCode("USD");
        request.setDate(LocalDate.now());
        request.setCategoryId(category.getId());
        
        // When
        Expense createdExpense = expenseService.createExpense(user.getId(), request);
        
        // Then
        assertThat(createdExpense).isNotNull();
        assertThat(createdExpense.getTitle()).isEqualTo("Integration Test Expense");
        assertThat(createdExpense.getAmount()).isEqualTo(new BigDecimal("150.00"));
        assertThat(createdExpense.getUser().getId()).isEqualTo(user.getId());
        assertThat(createdExpense.getCategory().getId()).isEqualTo(category.getId());
        
        // Verify persistence
        Optional<Expense> savedExpense = expenseRepository.findById(createdExpense.getId());
        assertThat(savedExpense).isPresent();
    }
    
    @Test
    void getExpenses_WithFilters_ShouldReturnFilteredResults() {
        // Given
        User user = createTestUser();
        Category foodCategory = createTestCategory("Food");
        Category transportCategory = createTestCategory("Transport");
        
        userRepository.save(user);
        categoryRepository.save(foodCategory);
        categoryRepository.save(transportCategory);
        
        // Create multiple expenses
        createTestExpense(user, foodCategory, "Food 1", new BigDecimal("50.00"));
        createTestExpense(user, foodCategory, "Food 2", new BigDecimal("75.00"));
        createTestExpense(user, transportCategory, "Transport 1", new BigDecimal("30.00"));
        
        // When
        Page<Expense> foodExpenses = expenseService.getExpenses(
            user.getId(), foodCategory.getId(), null, null, null, null, null, null, 
            PageRequest.of(0, 10));
        
        // Then
        assertThat(foodExpenses.getContent()).hasSize(2);
        assertThat(foodExpenses.getContent()).allMatch(expense -> 
            expense.getCategory().getName().equals("Food"));
    }
    
    @Test
    void calculateTotalSpending_ShouldReturnCorrectTotal() {
        // Given
        User user = createTestUser();
        Category category = createTestCategory();
        
        userRepository.save(user);
        categoryRepository.save(category);
        
        // Create expenses
        createTestExpense(user, category, "Expense 1", new BigDecimal("100.00"));
        createTestExpense(user, category, "Expense 2", new BigDecimal("200.00"));
        createTestExpense(user, category, "Expense 3", new BigDecimal("300.00"));
        
        // When
        BigDecimal total = expenseService.calculateTotalSpending(user.getId());
        
        // Then
        assertThat(total).isEqualTo(new BigDecimal("600.00"));
    }
}
```

### **3. Controller Integration Tests**

#### **ExpenseController Integration Tests**
```java
@WebMvcTest(ExpenseController.class)
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
@Testcontainers
class ExpenseControllerIntegrationTest {
    
    @Container
    static MySQLContainer<?> mysql = new MySQLContainer<>("mysql:8.0")
        .withDatabaseName("test_expensetracker")
        .withUsername("test_user")
        .withPassword("test_password");
    
    @Autowired
    private MockMvc mockMvc;
    
    @MockBean
    private ExpenseService expenseService;
    
    @MockBean
    private UserService userService;
    
    @Autowired
    private ObjectMapper objectMapper;
    
    @DynamicPropertySource
    static void databaseProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", mysql::getJdbcUrl);
        registry.add("spring.datasource.username", mysql::getUsername);
        registry.add("spring.datasource.password", mysql::getPassword);
    }
    
    @Test
    void createExpense_ValidRequest_ShouldReturnCreatedExpense() throws Exception {
        // Given
        ExpenseRequest request = new ExpenseRequest();
        request.setTitle("API Test Expense");
        request.setAmount(new BigDecimal("100.00"));
        request.setCurrencyCode("USD");
        request.setDate(LocalDate.now());
        
        Expense expectedExpense = createTestExpense();
        expectedExpense.setTitle("API Test Expense");
        
        when(expenseService.createExpense(eq(1L), any(ExpenseRequest.class)))
            .thenReturn(expectedExpense);
        
        // When & Then
        mockMvc.perform(post("/api/v1/expenses")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request))
                .header("Authorization", "Bearer test-token"))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.title").value("API Test Expense"))
            .andExpect(jsonPath("$.amount").value(100.00));
    }
    
    @Test
    void getExpenses_ValidRequest_ShouldReturnExpenses() throws Exception {
        // Given
        List<Expense> expenses = Arrays.asList(
            createTestExpense("Food", new BigDecimal("50.00")),
            createTestExpense("Transport", new BigDecimal("30.00"))
        );
        
        Page<Expense> expensePage = new PageImpl<>(expenses);
        
        when(expenseService.getExpenses(eq(1L), any(), any(), any(), any(), any(), any(), any(), any(), any()))
            .thenReturn(expensePage);
        
        // When & Then
        mockMvc.perform(get("/api/v1/expenses")
                .header("Authorization", "Bearer test-token"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.content").isArray())
            .andExpect(jsonPath("$.content", hasSize(2)))
            .andExpect(jsonPath("$.content[0].title").value("Food"))
            .andExpect(jsonPath("$.content[1].title").value("Transport"));
    }
    
    @Test
    void getExpense_ValidId_ShouldReturnExpense() throws Exception {
        // Given
        Expense expense = createTestExpense("Test Expense", new BigDecimal("100.00"));
        
        when(expenseService.getExpenseById(eq(1L), eq(1L)))
            .thenReturn(expense);
        
        // When & Then
        mockMvc.perform(get("/api/v1/expenses/1")
                .header("Authorization", "Bearer test-token"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.title").value("Test Expense"))
            .andExpect(jsonPath("$.amount").value(100.00));
    }
    
    @Test
    void updateExpense_ValidRequest_ShouldReturnUpdatedExpense() throws Exception {
        // Given
        ExpenseUpdateRequest request = new ExpenseUpdateRequest();
        request.setTitle("Updated Expense");
        request.setAmount(new BigDecimal("150.00"));
        
        Expense updatedExpense = createTestExpense("Updated Expense", new BigDecimal("150.00"));
        
        when(expenseService.updateExpense(eq(1L), eq(1L), any(ExpenseUpdateRequest.class)))
            .thenReturn(updatedExpense);
        
        // When & Then
        mockMvc.perform(put("/api/v1/expenses/1")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request))
                .header("Authorization", "Bearer test-token"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.title").value("Updated Expense"))
            .andExpect(jsonPath("$.amount").value(150.00));
    }
    
    @Test
    void deleteExpense_ValidId_ShouldReturnNoContent() throws Exception {
        // Given
        doNothing().when(expenseService).deleteExpense(eq(1L), eq(1L));
        
        // When & Then
        mockMvc.perform(delete("/api/v1/expenses/1")
                .header("Authorization", "Bearer test-token"))
            .andExpect(status().isNoContent());
        
        verify(expenseService).deleteExpense(1L, 1L);
    }
}
```

### **4. OCR Service Integration Tests**

#### **OcrService Integration Tests**
```java
@SpringBootTest
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
@Testcontainers
class OcrServiceIntegrationTest {
    
    @Container
    static MySQLContainer<?> mysql = new MySQLContainer<>("mysql:8.0")
        .withDatabaseName("test_expensetracker")
        .withUsername("test_user")
        .withPassword("test_password");
    
    @Autowired
    private OcrService ocrService;
    
    @DynamicPropertySource
    static void databaseProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", mysql::getJdbcUrl);
        registry.add("spring.datasource.username", mysql::getUsername);
        registry.add("spring.datasource.password", mysql::getPassword);
    }
    
    @Test
    void extractReceiptData_ValidImage_ShouldExtractData() {
        // Given
        String imageBase64 = loadTestImage("sample_receipt.jpg");
        
        // When
        ReceiptData result = ocrService.extractReceiptData(imageBase64, "jpeg");
        
        // Then
        assertThat(result).isNotNull();
        assertThat(result.getMerchantName()).isNotEmpty();
        assertThat(result.getTotalAmount()).isPositive();
        assertThat(result.getDate()).isNotNull();
        assertThat(result.getItems()).isNotEmpty();
    }
    
    @Test
    void extractReceiptData_InvalidImage_ShouldThrowException() {
        // Given
        String invalidImage = "invalid_base64_string";
        
        // When & Then
        assertThatThrownBy(() -> ocrService.extractReceiptData(invalidImage, "jpeg"))
            .isInstanceOf(OcrProcessingException.class);
    }
    
    @Test
    void parseReceiptText_ValidText_ShouldParseCorrectly() {
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
        assertThat(result.getItems().get(0).getName()).isEqualTo("BREAD");
        assertThat(result.getItems().get(0).getAmount()).isEqualTo(new BigDecimal("2.99"));
    }
}
```

## ⚛️ **Frontend Integration Tests**

### **1. Component Integration Tests**

#### **Dashboard Integration Tests**
```typescript
import { render, screen, waitFor } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from 'react-query';
import { BrowserRouter } from 'react-router-dom';
import Dashboard from '../Dashboard';
import { mockExpenseData, mockCategoryData } from '../__mocks__/data';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: false,
    },
  },
});

const renderWithProviders = (component: React.ReactElement) => {
  return render(
    <QueryClientProvider client={queryClient}>
      <BrowserRouter>
        {component}
      </BrowserRouter>
    </QueryClientProvider>
  );
};

describe('Dashboard Integration Tests', () => {
  beforeEach(() => {
    queryClient.clear();
  });

  it('loads and displays expense statistics', async () => {
    // Given
    renderWithProviders(<Dashboard />);

    // When & Then
    await waitFor(() => {
      expect(screen.getByText('Total Spending')).toBeInTheDocument();
      expect(screen.getByText('Total Expenses')).toBeInTheDocument();
      expect(screen.getByText('Daily Average')).toBeInTheDocument();
    });
  });

  it('displays spending chart with real data', async () => {
    // Given
    renderWithProviders(<Dashboard />);

    // When & Then
    await waitFor(() => {
      expect(screen.getByText('Spending by Category')).toBeInTheDocument();
      expect(screen.getByTestId('spending-chart')).toBeInTheDocument();
    });
  });

  it('navigates to add expense page when button is clicked', async () => {
    // Given
    renderWithProviders(<Dashboard />);

    // When
    const addExpenseButton = screen.getByText('Add Expense');
    addExpenseButton.click();

    // Then
    await waitFor(() => {
      expect(window.location.pathname).toBe('/add-expense');
    });
  });
});
```

#### **ReceiptScanner Integration Tests**
```typescript
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from 'react-query';
import { BrowserRouter } from 'react-router-dom';
import ReceiptScanner from '../ReceiptScanner';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: false,
    },
  },
});

const renderWithProviders = (component: React.ReactElement) => {
  return render(
    <QueryClientProvider client={queryClient}>
      <BrowserRouter>
        {component}
      </BrowserRouter>
    </QueryClientProvider>
  );
};

describe('ReceiptScanner Integration Tests', () => {
  beforeEach(() => {
    queryClient.clear();
  });

  it('uploads and processes receipt image', async () => {
    // Given
    const file = new File(['test'], 'receipt.jpg', { type: 'image/jpeg' });
    
    renderWithProviders(<ReceiptScanner />);

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

    await waitFor(() => {
      expect(screen.getByText('Merchant')).toBeInTheDocument();
      expect(screen.getByText('Amount')).toBeInTheDocument();
      expect(screen.getByText('Date')).toBeInTheDocument();
    });
  });

  it('creates expense from scanned receipt data', async () => {
    // Given
    renderWithProviders(<ReceiptScanner />);

    // When
    const createExpenseButton = screen.getByText('Create Expense');
    createExpenseButton.click();

    // Then
    await waitFor(() => {
      expect(screen.getByText('Expense created successfully')).toBeInTheDocument();
    });
  });
});
```

### **2. API Integration Tests**

#### **API Service Integration Tests**
```typescript
import { renderHook, waitFor } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from 'react-query';
import { useExpenses, useCreateExpense, useUpdateExpense } from '../services/api';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: false,
    },
  },
});

const wrapper = ({ children }: { children: React.ReactNode }) => (
  <QueryClientProvider client={queryClient}>
    {children}
  </QueryClientProvider>
);

describe('API Service Integration Tests', () => {
  beforeEach(() => {
    queryClient.clear();
  });

  it('fetches expenses from API', async () => {
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
    const { result } = renderHook(() => useExpenses(), { wrapper });

    // Then
    await waitFor(() => {
      expect(result.current.data).toEqual({ content: mockExpenses });
    });
  });

  it('creates expense via API', async () => {
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
    const { result } = renderHook(() => useCreateExpense(), { wrapper });

    // Then
    const mutation = result.current;
    await mutation.mutateAsync(newExpense);

    expect(mutation.isSuccess).toBe(true);
  });

  it('updates expense via API', async () => {
    // Given
    const updatedExpense = {
      id: 1,
      title: 'Updated Expense',
      amount: 150.00,
    };

    global.fetch = jest.fn().mockResolvedValue({
      ok: true,
      json: async () => updatedExpense,
    });

    // When
    const { result } = renderHook(() => useUpdateExpense(), { wrapper });

    // Then
    const mutation = result.current;
    await mutation.mutateAsync({ id: 1, ...updatedExpense });

    expect(mutation.isSuccess).toBe(true);
  });
});
```

## 📊 **Test Coverage Requirements**

### **Backend Integration Coverage**
- **Repository Layer**: >80%
- **Service Layer**: >75%
- **Controller Layer**: >70%
- **OCR Service**: >60%

### **Frontend Integration Coverage**
- **Component Integration**: >70%
- **API Integration**: >80%
- **User Workflows**: >60%

## 🚀 **Running Integration Tests**

### **Backend Integration Tests**
```bash
# Run all integration tests
mvn test -Dtest="*IntegrationTest"

# Run specific integration test
mvn test -Dtest=ExpenseServiceIntegrationTest

# Run with test containers
mvn test -Dspring.profiles.active=test-containers
```

### **Frontend Integration Tests**
```bash
# Run integration tests
npm run test:integration

# Run with Cypress
npm run cypress:run

# Run specific test file
npm test -- ReceiptScanner.integration.test.tsx
```

## 📈 **Test Quality Metrics**

### **Integration Test Quality**
- **Test Isolation**: Each test is independent
- **Data Cleanup**: Proper cleanup after each test
- **Realistic Scenarios**: Tests real user workflows
- **Error Handling**: Tests error conditions
- **Performance**: Tests complete within reasonable time

### **Test Data Management**
- **Test Data Factory**: Reusable test data creation
- **Database Seeding**: Consistent test data setup
- **Cleanup Strategy**: Proper test data cleanup
- **Isolation**: Tests don't interfere with each other

## 🔄 **Continuous Integration**

### **GitHub Actions Integration Tests**
```yaml
name: Integration Tests

on: [push, pull_request]

jobs:
  backend-integration-tests:
    runs-on: ubuntu-latest
    services:
      mysql:
        image: mysql:8.0
        env:
          MYSQL_ROOT_PASSWORD: root
          MYSQL_DATABASE: test_expensetracker
        ports:
          - 3306:3306
        options: --health-cmd="mysqladmin ping" --health-interval=10s --health-timeout=5s --health-retries=3
    
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-java@v3
        with:
          java-version: '17'
      - run: mvn test -Dtest="*IntegrationTest"

  frontend-integration-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      - run: npm ci
      - run: npm run test:integration
```

This comprehensive integration testing plan ensures that all components work together correctly and provides confidence in the application's reliability! 🎯 