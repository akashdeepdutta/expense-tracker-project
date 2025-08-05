# Testing Strategy - Expense Tracker

## Overview
This document outlines the comprehensive testing strategy for the Expense Tracker application, covering unit tests, integration tests, API tests, and frontend tests.

## Testing Pyramid

### 1. Unit Tests (70%)
- **Backend**: Service layer, utility classes, business logic
- **Frontend**: Component logic, utility functions, hooks
- **Coverage Target**: >80%

### 2. Integration Tests (20%)
- **Backend**: Repository layer, controller endpoints
- **Frontend**: Component integration, API service integration
- **Coverage Target**: >70%

### 3. End-to-End Tests (10%)
- **User workflows**: Complete user journeys
- **Critical paths**: Authentication, expense creation, receipt scanning
- **Coverage Target**: >50%

## Backend Testing

### Unit Tests

#### Service Layer Tests
```java
@ExtendWith(MockitoExtension.class)
class ExpenseServiceTest {
    
    @Mock
    private ExpenseRepository expenseRepository;
    
    @Mock
    private UserRepository userRepository;
    
    @InjectMocks
    private ExpenseService expenseService;
    
    @Test
    void createExpense_ValidExpense_ReturnsSavedExpense() {
        // Given
        Expense expense = new Expense();
        expense.setTitle("Test Expense");
        expense.setAmount(new BigDecimal("100.00"));
        
        User user = new User();
        user.setId(1L);
        
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(expenseRepository.save(any(Expense.class))).thenReturn(expense);
        
        // When
        Expense result = expenseService.createExpense(1L, expense);
        
        // Then
        assertThat(result).isNotNull();
        assertThat(result.getTitle()).isEqualTo("Test Expense");
        verify(expenseRepository).save(any(Expense.class));
    }
}
```

#### OCR Service Tests
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
    }
}
```

### Integration Tests

#### Repository Tests
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
        Expense expense = createTestExpense(user);
        
        // When
        List<Expense> expenses = expenseRepository.findByUserId(user.getId());
        
        // Then
        assertThat(expenses).hasSize(1);
        assertThat(expenses.get(0).getTitle()).isEqualTo("Test Expense");
    }
}
```

#### Controller Tests
```java
@WebMvcTest(ExpenseController.class)
class ExpenseControllerTest {
    
    @Autowired
    private MockMvc mockMvc;
    
    @MockBean
    private ExpenseService expenseService;
    
    @Test
    void getExpenses_ValidRequest_ReturnsExpenses() throws Exception {
        // Given
        List<Expense> expenses = Arrays.asList(createTestExpense());
        when(expenseService.getExpenses(any(), any(), any(), any(), any(), any(), any(), any(), any()))
            .thenReturn(new PageImpl<>(expenses));
        
        // When & Then
        mockMvc.perform(get("/expenses"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.content").isArray())
            .andExpect(jsonPath("$.content[0].title").value("Test Expense"));
    }
}
```

### API Tests

#### REST API Tests
```java
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class ExpenseApiTest {
    
    @Autowired
    private TestRestTemplate restTemplate;
    
    @Test
    void createExpense_ValidRequest_ReturnsCreatedExpense() {
        // Given
        ExpenseRequest request = new ExpenseRequest();
        request.setTitle("API Test Expense");
        request.setAmount(new BigDecimal("50.00"));
        request.setCurrencyCode("USD");
        request.setDate(LocalDate.now());
        
        // When
        ResponseEntity<Expense> response = restTemplate.postForEntity(
            "/api/v1/expenses", request, Expense.class);
        
        // Then
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody().getTitle()).isEqualTo("API Test Expense");
    }
}
```

## Database Testing

### MySQL Database Tests

#### Database Connection Tests
```java
@SpringBootTest
class DatabaseConnectionTest {
    
    @Autowired
    private DataSource dataSource;
    
    @Test
    void databaseConnection_ShouldBeEstablished() {
        // Given & When
        Connection connection = dataSource.getConnection();
        
        // Then
        assertThat(connection).isNotNull();
        assertThat(connection.getMetaData().getDatabaseProductName()).isEqualTo("MySQL");
        connection.close();
    }
}
```

#### Database Schema Tests
```java
@SpringBootTest
class DatabaseSchemaTest {
    
    @Autowired
    private JdbcTemplate jdbcTemplate;
    
    @Test
    void databaseSchema_ShouldHaveRequiredTables() {
        // When
        List<String> tables = jdbcTemplate.queryForList(
            "SHOW TABLES", String.class);
        
        // Then
        assertThat(tables).contains("users", "categories", "expenses", "budgets", "currencies");
    }
    
    @Test
    void databaseSchema_ShouldHaveProperIndexes() {
        // When
        List<String> indexes = jdbcTemplate.queryForList(
            "SHOW INDEX FROM expenses", String.class);
        
        // Then
        assertThat(indexes).isNotEmpty();
    }
}
```

#### Data Persistence Tests
```java
@Transactional
@SpringBootTest
class DataPersistenceTest {
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private ExpenseRepository expenseRepository;
    
    @Test
    void saveAndRetrieveUser_ShouldPersistData() {
        // Given
        User user = new User();
        user.setUsername("testuser");
        user.setEmail("test@example.com");
        user.setPasswordHash("hashedpassword");
        
        // When
        User savedUser = userRepository.save(user);
        User retrievedUser = userRepository.findById(savedUser.getId()).orElse(null);
        
        // Then
        assertThat(retrievedUser).isNotNull();
        assertThat(retrievedUser.getUsername()).isEqualTo("testuser");
    }
}
```

### Database Performance Tests

#### Query Performance Tests
```java
@SpringBootTest
class DatabasePerformanceTest {
    
    @Autowired
    private ExpenseRepository expenseRepository;
    
    @Test
    void findByUserId_ShouldBeOptimized() {
        // Given
        User user = createTestUser();
        createMultipleExpenses(user, 1000);
        
        // When
        long startTime = System.currentTimeMillis();
        List<Expense> expenses = expenseRepository.findByUserId(user.getId());
        long endTime = System.currentTimeMillis();
        
        // Then
        assertThat(endTime - startTime).isLessThan(1000); // Should complete within 1 second
        assertThat(expenses).hasSize(1000);
    }
}
```

## Frontend Testing

### Unit Tests

#### Component Tests
```typescript
import { render, screen, fireEvent } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from 'react-query';
import Dashboard from '../Dashboard';

const queryClient = new QueryClient();

describe('Dashboard', () => {
  it('renders dashboard with statistics', () => {
    render(
      <QueryClientProvider client={queryClient}>
        <Dashboard />
      </QueryClientProvider>
    );
    
    expect(screen.getByText('Dashboard')).toBeInTheDocument();
    expect(screen.getByText('Total Spending')).toBeInTheDocument();
  });
});
```

#### Service Tests
```typescript
import { getExpenses, createExpense } from '../services/api';
import { rest } from 'msw';
import { setupServer } from 'msw/node';

const server = setupServer(
  rest.get('/api/v1/expenses', (req, res, ctx) => {
    return res(
      ctx.json({
        content: [
          {
            id: 1,
            title: 'Test Expense',
            amount: 100.00,
            currencyCode: 'USD'
          }
        ],
        totalElements: 1
      })
    );
  })
);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

describe('API Services', () => {
  it('fetches expenses successfully', async () => {
    const result = await getExpenses();
    
    expect(result.content).toHaveLength(1);
    expect(result.content[0].title).toBe('Test Expense');
  });
});
```

### Integration Tests

#### Component Integration
```typescript
import { render, screen, waitFor } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from 'react-query';
import ReceiptScanner from '../ReceiptScanner';

describe('ReceiptScanner Integration', () => {
  it('processes uploaded receipt image', async () => {
    const file = new File(['receipt'], 'receipt.jpg', { type: 'image/jpeg' });
    
    render(
      <QueryClientProvider client={queryClient}>
        <ReceiptScanner />
      </QueryClientProvider>
    );
    
    const dropzone = screen.getByText('Upload receipt image');
    fireEvent.drop(dropzone, {
      dataTransfer: {
        files: [file]
      }
    });
    
    await waitFor(() => {
      expect(screen.getByText('Extracted Data')).toBeInTheDocument();
    });
  });
});
```

## End-to-End Testing

### Cypress Tests
```typescript
describe('Expense Tracker E2E', () => {
  beforeEach(() => {
    cy.visit('http://localhost:3000');
  });
  
  it('creates expense from receipt scan', () => {
    // Navigate to receipt scanner
    cy.get('[data-testid="scan-receipt-link"]').click();
    
    // Upload receipt image
    cy.get('[data-testid="receipt-dropzone"]')
      .attachFile('sample-receipt.jpg');
    
    // Verify extracted data
    cy.get('[data-testid="merchant-name"]')
      .should('contain', 'Sample Merchant');
    
    // Create expense
    cy.get('[data-testid="create-expense-btn"]').click();
    
    // Verify expense created
    cy.get('[data-testid="success-message"]')
      .should('contain', 'Expense created successfully');
  });
  
  it('manages expenses list', () => {
    // Navigate to expenses
    cy.get('[data-testid="expenses-link"]').click();
    
    // Add new expense
    cy.get('[data-testid="add-expense-btn"]').click();
    
    // Fill expense form
    cy.get('[data-testid="expense-title"]').type('Test Expense');
    cy.get('[data-testid="expense-amount"]').type('100.00');
    cy.get('[data-testid="expense-category"]').select('Food & Dining');
    
    // Submit form
    cy.get('[data-testid="submit-expense-btn"]').click();
    
    // Verify expense in list
    cy.get('[data-testid="expense-list"]')
      .should('contain', 'Test Expense');
  });
});
```

## Performance Testing

### Load Testing
```java
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class PerformanceTest {
    
    @Test
    void expenseCreation_ConcurrentRequests_HandlesLoad() {
        // Given
        int concurrentUsers = 100;
        CountDownLatch latch = new CountDownLatch(concurrentUsers);
        ExecutorService executor = Executors.newFixedThreadPool(concurrentUsers);
        
        // When
        for (int i = 0; i < concurrentUsers; i++) {
            executor.submit(() -> {
                try {
                    createExpenseRequest();
                    latch.countDown();
                } catch (Exception e) {
                    fail("Request failed: " + e.getMessage());
                }
            });
        }
        
        // Then
        assertThat(latch.await(30, TimeUnit.SECONDS)).isTrue();
    }
}
```

## Security Testing

### Authentication Tests
```java
@Test
void accessProtectedEndpoint_WithoutToken_ReturnsUnauthorized() {
    mockMvc.perform(get("/api/v1/expenses"))
        .andExpect(status().isUnauthorized());
}

@Test
void accessProtectedEndpoint_WithValidToken_ReturnsOk() {
    String token = generateValidToken();
    
    mockMvc.perform(get("/api/v1/expenses")
        .header("Authorization", "Bearer " + token))
        .andExpect(status().isOk());
}
```

### Input Validation Tests
```java
@Test
void createExpense_InvalidAmount_ReturnsBadRequest() {
    ExpenseRequest request = new ExpenseRequest();
    request.setAmount(new BigDecimal("-10.00"));
    
    mockMvc.perform(post("/api/v1/expenses")
        .contentType(MediaType.APPLICATION_JSON)
        .content(objectMapper.writeValueAsString(request)))
        .andExpect(status().isBadRequest());
}
```

## Test Data Management

### Test Fixtures
```java
@Component
public class TestDataBuilder {
    
    public User createTestUser() {
        User user = new User();
        user.setUsername("testuser");
        user.setEmail("test@example.com");
        user.setPasswordHash("hashedpassword");
        return user;
    }
    
    public Expense createTestExpense(User user) {
        Expense expense = new Expense();
        expense.setTitle("Test Expense");
        expense.setAmount(new BigDecimal("100.00"));
        expense.setCurrencyCode("USD");
        expense.setDate(LocalDate.now());
        expense.setUser(user);
        return expense;
    }
}
```

## Continuous Integration

### GitHub Actions Workflow
```yaml
name: Test Suite
on: [push, pull_request]

jobs:
  backend-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-java@v2
        with:
          java-version: '17'
      - run: cd backend && mvn test
      
  frontend-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-node@v2
        with:
          node-version: '16'
      - run: cd frontend && npm install
      - run: cd frontend && npm test -- --coverage
      
  e2e-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - run: npm install
      - run: npm run test:e2e
```

## Test Coverage Goals

- **Unit Tests**: >80% coverage
- **Integration Tests**: >70% coverage
- **API Tests**: >90% endpoint coverage
- **E2E Tests**: >50% critical path coverage

## Test Execution

### Running Tests Locally

#### Backend Tests
```bash
cd backend
mvn test
mvn test -Dtest=ExpenseServiceTest
mvn jacoco:report
```

#### Frontend Tests
```bash
cd frontend
npm test
npm test -- --coverage
npm run test:watch
```

#### E2E Tests
```bash
npm run test:e2e
npm run test:e2e:headed
```

## Monitoring and Reporting

### Test Reports
- **JUnit Reports**: Backend test results
- **Jest Reports**: Frontend test results
- **Cypress Reports**: E2E test results
- **Coverage Reports**: Code coverage metrics

### Quality Gates
- All tests must pass
- Coverage thresholds must be met
- No critical security vulnerabilities
- Performance benchmarks must be met

## Conclusion

This testing strategy ensures comprehensive coverage of the Expense Tracker application, from unit tests to end-to-end scenarios. The combination of automated testing, continuous integration, and quality gates helps maintain code quality and reliability throughout the development lifecycle. 