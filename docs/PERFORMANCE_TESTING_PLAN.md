# Performance Testing Plan - Expense Tracker

## 🎯 **Overview**

This document outlines the performance testing strategy for the Expense Tracker application, covering load testing, stress testing, scalability testing, and performance monitoring. The goal is to ensure the application performs well under various load conditions.

## 📋 **Testing Framework**

### **Backend Performance Testing**
- **Framework**: JMeter + Spring Boot Test
- **Database**: MySQL with realistic data
- **Monitoring**: Micrometer + Prometheus
- **Target Response Time**: <500ms for 95th percentile

### **Frontend Performance Testing**
- **Framework**: Lighthouse + WebPageTest
- **Monitoring**: React Profiler + Chrome DevTools
- **Target Load Time**: <3 seconds for initial page load

## 🏗️ **Backend Performance Tests**

### **1. API Performance Tests**

#### **Expense API Performance Tests**
```java
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@TestPropertySource(properties = {
    "spring.datasource.url=jdbc:h2:mem:testdb",
    "spring.jpa.hibernate.ddl-auto=create-drop"
})
class ExpenseApiPerformanceTest {
    
    @Autowired
    private TestRestTemplate restTemplate;
    
    @Autowired
    private ExpenseRepository expenseRepository;
    
    @Autowired
    private UserRepository userRepository;
    
    @BeforeEach
    void setUp() {
        // Create test data
        User user = createTestUser();
        userRepository.save(user);
        
        // Create 1000 test expenses
        for (int i = 0; i < 1000; i++) {
            Expense expense = createTestExpense(user, "Expense " + i, new BigDecimal("100.00"));
            expenseRepository.save(expense);
        }
    }
    
    @Test
    void getExpenses_LoadTest_ShouldHandleConcurrentRequests() {
        // Given
        int numberOfThreads = 50;
        int requestsPerThread = 20;
        CountDownLatch latch = new CountDownLatch(numberOfThreads);
        List<Long> responseTimes = Collections.synchronizedList(new ArrayList<>());
        
        // When
        ExecutorService executor = Executors.newFixedThreadPool(numberOfThreads);
        
        for (int i = 0; i < numberOfThreads; i++) {
            executor.submit(() -> {
                for (int j = 0; j < requestsPerThread; j++) {
                    long startTime = System.currentTimeMillis();
                    
                    ResponseEntity<ExpensePage> response = restTemplate.getForEntity(
                        "/api/v1/expenses?page=0&size=20", ExpensePage.class);
                    
                    long endTime = System.currentTimeMillis();
                    responseTimes.add(endTime - startTime);
                    
                    assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
                }
                latch.countDown();
            });
        }
        
        // Then
        latch.await(30, TimeUnit.SECONDS);
        executor.shutdown();
        
        // Performance assertions
        assertThat(responseTimes).hasSize(numberOfThreads * requestsPerThread);
        
        // Calculate percentiles
        Collections.sort(responseTimes);
        long p50 = responseTimes.get(responseTimes.size() * 50 / 100);
        long p95 = responseTimes.get(responseTimes.size() * 95 / 100);
        long p99 = responseTimes.get(responseTimes.size() * 99 / 100);
        
        assertThat(p50).isLessThan(200); // 50th percentile < 200ms
        assertThat(p95).isLessThan(500); // 95th percentile < 500ms
        assertThat(p99).isLessThan(1000); // 99th percentile < 1000ms
    }
    
    @Test
    void createExpense_PerformanceTest_ShouldHandleBulkCreation() {
        // Given
        int numberOfExpenses = 100;
        List<ExpenseRequest> requests = new ArrayList<>();
        
        for (int i = 0; i < numberOfExpenses; i++) {
            ExpenseRequest request = new ExpenseRequest();
            request.setTitle("Bulk Expense " + i);
            request.setAmount(new BigDecimal("100.00"));
            request.setCurrencyCode("USD");
            request.setDate(LocalDate.now());
            requests.add(request);
        }
        
        // When
        long startTime = System.currentTimeMillis();
        
        for (ExpenseRequest request : requests) {
            ResponseEntity<Expense> response = restTemplate.postForEntity(
                "/api/v1/expenses", request, Expense.class);
            assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        }
        
        long endTime = System.currentTimeMillis();
        long totalTime = endTime - startTime;
        
        // Then
        double averageTime = (double) totalTime / numberOfExpenses;
        assertThat(averageTime).isLessThan(100); // Average < 100ms per request
    }
    
    @Test
    void searchExpenses_PerformanceTest_ShouldHandleComplexQueries() {
        // Given
        String searchTerm = "Food";
        LocalDate startDate = LocalDate.now().minusDays(30);
        LocalDate endDate = LocalDate.now();
        
        // When
        long startTime = System.currentTimeMillis();
        
        ResponseEntity<ExpensePage> response = restTemplate.getForEntity(
            "/api/v1/expenses?search=" + searchTerm + 
            "&startDate=" + startDate + 
            "&endDate=" + endDate + 
            "&page=0&size=50", ExpensePage.class);
        
        long endTime = System.currentTimeMillis();
        long responseTime = endTime - startTime;
        
        // Then
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(responseTime).isLessThan(300); // Response time < 300ms
    }
}
```

#### **Analytics API Performance Tests**
```java
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class AnalyticsApiPerformanceTest {
    
    @Autowired
    private TestRestTemplate restTemplate;
    
    @Autowired
    private ExpenseRepository expenseRepository;
    
    @BeforeEach
    void setUp() {
        // Create large dataset for analytics
        User user = createTestUser();
        userRepository.save(user);
        
        // Create expenses across different categories and dates
        createAnalyticsTestData(user);
    }
    
    @Test
    void getSpendingAnalytics_PerformanceTest_ShouldHandleComplexAggregations() {
        // Given
        LocalDate startDate = LocalDate.now().minusMonths(6);
        LocalDate endDate = LocalDate.now();
        
        // When
        long startTime = System.currentTimeMillis();
        
        ResponseEntity<SpendingAnalytics> response = restTemplate.getForEntity(
            "/api/v1/analytics/spending?startDate=" + startDate + 
            "&endDate=" + endDate, SpendingAnalytics.class);
        
        long endTime = System.currentTimeMillis();
        long responseTime = endTime - startTime;
        
        // Then
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(responseTime).isLessThan(500); // Response time < 500ms
    }
    
    @Test
    void getCategoryBreakdown_PerformanceTest_ShouldHandleGroupByQueries() {
        // Given
        LocalDate startDate = LocalDate.now().minusMonths(3);
        LocalDate endDate = LocalDate.now();
        
        // When
        long startTime = System.currentTimeMillis();
        
        ResponseEntity<List<CategorySpending>> response = restTemplate.getForEntity(
            "/api/v1/analytics/categories?startDate=" + startDate + 
            "&endDate=" + endDate, new ParameterizedTypeReference<List<CategorySpending>>() {});
        
        long endTime = System.currentTimeMillis();
        long responseTime = endTime - startTime;
        
        // Then
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(responseTime).isLessThan(300); // Response time < 300ms
    }
}
```

### **2. Database Performance Tests**

#### **Query Performance Tests**
```java
@SpringBootTest
@Transactional
class DatabasePerformanceTest {
    
    @Autowired
    private ExpenseRepository expenseRepository;
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private JdbcTemplate jdbcTemplate;
    
    @BeforeEach
    void setUp() {
        // Create large dataset
        User user = createTestUser();
        userRepository.save(user);
        
        // Create 10,000 expenses
        for (int i = 0; i < 10000; i++) {
            Expense expense = createTestExpense(user, "Expense " + i, new BigDecimal("100.00"));
            expenseRepository.save(expense);
        }
    }
    
    @Test
    void findByUserId_PerformanceTest_ShouldUseIndex() {
        // Given
        User user = userRepository.findByUsername("testuser").orElse(null);
        assertThat(user).isNotNull();
        
        // When
        long startTime = System.currentTimeMillis();
        
        List<Expense> expenses = expenseRepository.findByUserId(user.getId());
        
        long endTime = System.currentTimeMillis();
        long queryTime = endTime - startTime;
        
        // Then
        assertThat(expenses).hasSize(10000);
        assertThat(queryTime).isLessThan(1000); // Query time < 1000ms
        
        // Verify index usage
        String explainPlan = jdbcTemplate.queryForObject(
            "EXPLAIN SELECT * FROM expenses WHERE user_id = ?", String.class, user.getId());
        assertThat(explainPlan).contains("Using index");
    }
    
    @Test
    void findByUserIdAndDateBetween_PerformanceTest_ShouldHandleDateRangeQueries() {
        // Given
        User user = userRepository.findByUsername("testuser").orElse(null);
        LocalDate startDate = LocalDate.now().minusDays(30);
        LocalDate endDate = LocalDate.now();
        
        // When
        long startTime = System.currentTimeMillis();
        
        List<Expense> expenses = expenseRepository.findByUserIdAndDateBetween(
            user.getId(), startDate, endDate);
        
        long endTime = System.currentTimeMillis();
        long queryTime = endTime - startTime;
        
        // Then
        assertThat(queryTime).isLessThan(500); // Query time < 500ms
    }
    
    @Test
    void calculateTotalSpendingByUser_PerformanceTest_ShouldHandleAggregations() {
        // Given
        User user = userRepository.findByUsername("testuser").orElse(null);
        
        // When
        long startTime = System.currentTimeMillis();
        
        BigDecimal total = expenseRepository.calculateTotalSpendingByUser(user.getId());
        
        long endTime = System.currentTimeMillis();
        long queryTime = endTime - startTime;
        
        // Then
        assertThat(total).isPositive();
        assertThat(queryTime).isLessThan(200); // Query time < 200ms
    }
}
```

### **3. OCR Performance Tests**

#### **Receipt Processing Performance Tests**
```java
@SpringBootTest
class OcrPerformanceTest {
    
    @Autowired
    private OcrService ocrService;
    
    @Test
    void extractReceiptData_PerformanceTest_ShouldProcessQuickly() {
        // Given
        String imageBase64 = loadLargeTestImage("large_receipt.jpg");
        
        // When
        long startTime = System.currentTimeMillis();
        
        ReceiptData result = ocrService.extractReceiptData(imageBase64, "jpeg");
        
        long endTime = System.currentTimeMillis();
        long processingTime = endTime - startTime;
        
        // Then
        assertThat(result).isNotNull();
        assertThat(processingTime).isLessThan(5000); // Processing time < 5 seconds
    }
    
    @Test
    void processMultipleReceipts_PerformanceTest_ShouldHandleBulkProcessing() {
        // Given
        List<String> images = loadMultipleTestImages(10);
        
        // When
        long startTime = System.currentTimeMillis();
        
        List<ReceiptData> results = images.parallelStream()
            .map(image -> ocrService.extractReceiptData(image, "jpeg"))
            .collect(Collectors.toList());
        
        long endTime = System.currentTimeMillis();
        long totalTime = endTime - startTime;
        
        // Then
        assertThat(results).hasSize(10);
        assertThat(results).allMatch(result -> result != null);
        assertThat(totalTime).isLessThan(30000); // Total time < 30 seconds
    }
}
```

## ⚛️ **Frontend Performance Tests**

### **1. Component Performance Tests**

#### **Dashboard Performance Tests**
```typescript
import { render, screen, waitFor } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from 'react-query';
import Dashboard from '../Dashboard';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: false,
    },
  },
});

describe('Dashboard Performance Tests', () => {
  beforeEach(() => {
    queryClient.clear();
  });

  it('renders dashboard within performance budget', async () => {
    // Given
    const startTime = performance.now();
    
    // When
    render(
      <QueryClientProvider client={queryClient}>
        <Dashboard />
      </QueryClientProvider>
    );
    
    // Then
    await waitFor(() => {
      expect(screen.getByText('Total Spending')).toBeInTheDocument();
    });
    
    const endTime = performance.now();
    const renderTime = endTime - startTime;
    
    expect(renderTime).toBeLessThan(1000); // Render time < 1000ms
  });

  it('handles large dataset rendering', async () => {
    // Given
    const largeDataset = Array.from({ length: 1000 }, (_, i) => ({
      id: i,
      title: `Expense ${i}`,
      amount: 100.00,
    }));
    
    // Mock API to return large dataset
    global.fetch = jest.fn().mockResolvedValue({
      ok: true,
      json: async () => ({ content: largeDataset }),
    });
    
    // When
    const startTime = performance.now();
    
    render(
      <QueryClientProvider client={queryClient}>
        <Dashboard />
      </QueryClientProvider>
    );
    
    // Then
    await waitFor(() => {
      expect(screen.getByTestId('expense-list')).toBeInTheDocument();
    });
    
    const endTime = performance.now();
    const renderTime = endTime - startTime;
    
    expect(renderTime).toBeLessThan(2000); // Render time < 2000ms
  });
});
```

#### **Chart Performance Tests**
```typescript
import { render, screen, waitFor } from '@testing-library/react';
import SpendingChart from '../components/SpendingChart';

describe('SpendingChart Performance Tests', () => {
  it('renders chart with large dataset efficiently', async () => {
    // Given
    const largeDataset = Array.from({ length: 100 }, (_, i) => ({
      category: `Category ${i}`,
      amount: Math.random() * 1000,
    }));
    
    // When
    const startTime = performance.now();
    
    render(<SpendingChart data={largeDataset} />);
    
    // Then
    await waitFor(() => {
      expect(screen.getByTestId('spending-chart')).toBeInTheDocument();
    });
    
    const endTime = performance.now();
    const renderTime = endTime - startTime;
    
    expect(renderTime).toBeLessThan(500); // Chart render time < 500ms
  });

  it('updates chart smoothly on data change', async () => {
    // Given
    const initialData = [{ category: 'Food', amount: 100 }];
    const updatedData = [{ category: 'Food', amount: 150 }];
    
    const { rerender } = render(<SpendingChart data={initialData} />);
    
    // When
    const startTime = performance.now();
    
    rerender(<SpendingChart data={updatedData} />);
    
    // Then
    await waitFor(() => {
      expect(screen.getByTestId('spending-chart')).toBeInTheDocument();
    });
    
    const endTime = performance.now();
    const updateTime = endTime - startTime;
    
    expect(updateTime).toBeLessThan(200); // Update time < 200ms
  });
});
```

### **2. API Performance Tests**

#### **API Response Time Tests**
```typescript
import { renderHook, waitFor } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from 'react-query';
import { useExpenses } from '../services/api';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: false,
    },
  },
});

describe('API Performance Tests', () => {
  beforeEach(() => {
    queryClient.clear();
  });

  it('fetches expenses within performance budget', async () => {
    // Given
    const mockExpenses = Array.from({ length: 100 }, (_, i) => ({
      id: i,
      title: `Expense ${i}`,
      amount: 100.00,
    }));

    global.fetch = jest.fn().mockResolvedValue({
      ok: true,
      json: async () => ({ content: mockExpenses }),
    });

    // When
    const startTime = performance.now();
    
    const { result } = renderHook(() => useExpenses(), {
      wrapper: ({ children }) => (
        <QueryClientProvider client={queryClient}>
          {children}
        </QueryClientProvider>
      ),
    });

    // Then
    await waitFor(() => {
      expect(result.current.data).toBeDefined();
    });

    const endTime = performance.now();
    const fetchTime = endTime - startTime;

    expect(fetchTime).toBeLessThan(1000); // Fetch time < 1000ms
  });

  it('handles concurrent API requests efficiently', async () => {
    // Given
    const concurrentRequests = 10;
    const promises = [];

    // When
    const startTime = performance.now();

    for (let i = 0; i < concurrentRequests; i++) {
      promises.push(
        fetch('/api/v1/expenses').then(response => response.json())
      );
    }

    await Promise.all(promises);

    const endTime = performance.now();
    const totalTime = endTime - startTime;

    // Then
    expect(totalTime).toBeLessThan(5000); // Total time < 5000ms
  });
});
```

## 📊 **Load Testing with JMeter**

### **1. JMeter Test Plan**

#### **Expense API Load Test**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<jmeterTestPlan version="1.2" properties="5.0">
  <hashTree>
    <TestPlan guiclass="TestPlanGui" testclass="TestPlan" testname="Expense API Load Test">
      <elementProp name="TestPlan.arguments" elementType="Arguments">
        <collectionProp name="Arguments.arguments"/>
      </elementProp>
      <boolProp name="TestPlan.functional_mode">false</boolProp>
      <boolProp name="TestPlan.tearDown_on_shutdown">true</boolProp>
      <boolProp name="TestPlan.serialize_threadgroups">false</boolProp>
      <stringProp name="TestPlan.comments"></stringProp>
      <stringProp name="TestPlan.user_define_classpath"></stringProp>
    </TestPlan>
    <hashTree>
      <ThreadGroup guiclass="ThreadGroupGui" testclass="ThreadGroup" testname="Expense API Thread Group">
        <elementProp name="ThreadGroup.main_controller" elementType="LoopController">
          <boolProp name="LoopController.continue_forever">false</boolProp>
          <stringProp name="LoopController.loops">10</stringProp>
        </elementProp>
        <stringProp name="ThreadGroup.on_sample_error">continue</stringProp>
        <elementProp name="ThreadGroup.scheduler" elementType="ThreadGroupScheduler">
          <boolProp name="ThreadGroupScheduler.duration">false</boolProp>
          <boolProp name="ThreadGroupScheduler.delay">false</boolProp>
          <stringProp name="ThreadGroupScheduler.duration">300</stringProp>
          <stringProp name="ThreadGroupScheduler.delay">0</stringProp>
        </elementProp>
        <stringProp name="ThreadGroup.num_threads">50</stringProp>
        <stringProp name="ThreadGroup.ramp_time">10</stringProp>
        <boolProp name="ThreadGroup.scheduler">false</boolProp>
        <stringProp name="ThreadGroup.duration"></stringProp>
        <stringProp name="ThreadGroup.delay"></stringProp>
      </ThreadGroup>
      <hashTree>
        <HTTPSamplerProxy guiclass="HttpTestSampleGui" testclass="HTTPSamplerProxy" testname="Get Expenses">
          <elementProp name="HTTPsampler.Arguments" elementType="Arguments">
            <collectionProp name="Arguments.arguments"/>
          </elementProp>
          <stringProp name="HTTPSampler.domain">localhost</stringProp>
          <stringProp name="HTTPSampler.port">8080</stringProp>
          <stringProp name="HTTPSampler.protocol">http</stringProp>
          <stringProp name="HTTPSampler.path">/api/v1/expenses</stringProp>
          <stringProp name="HTTPSampler.method">GET</stringProp>
          <boolProp name="HTTPSampler.follow_redirects">true</boolProp>
          <boolProp name="HTTPSampler.auto_redirects">false</boolProp>
          <boolProp name="HTTPSampler.use_keepalive">true</boolProp>
          <boolProp name="HTTPSampler.DO_MULTIPART_POST">false</boolProp>
          <stringProp name="HTTPSampler.embedded_url_re"></stringProp>
          <stringProp name="HTTPSampler.connect_timeout"></stringProp>
          <stringProp name="HTTPSampler.response_timeout"></stringProp>
        </HTTPSamplerProxy>
        <hashTree/>
      </hashTree>
    </hashTree>
  </hashTree>
</jmeterTestPlan>
```

### **2. Performance Monitoring**

#### **Micrometer Metrics**
```java
@Component
public class PerformanceMetrics {
    
    private final MeterRegistry meterRegistry;
    private final Timer expenseApiTimer;
    private final Counter expenseApiCounter;
    private final Gauge activeUsersGauge;
    
    public PerformanceMetrics(MeterRegistry meterRegistry) {
        this.meterRegistry = meterRegistry;
        this.expenseApiTimer = Timer.builder("expense.api.duration")
            .description("Expense API response time")
            .register(meterRegistry);
        this.expenseApiCounter = Counter.builder("expense.api.requests")
            .description("Expense API request count")
            .register(meterRegistry);
        this.activeUsersGauge = Gauge.builder("active.users")
            .description("Number of active users")
            .register(meterRegistry, this, PerformanceMetrics::getActiveUsers);
    }
    
    public Timer.Sample startTimer() {
        return Timer.start(meterRegistry);
    }
    
    public void recordApiCall(Timer.Sample sample) {
        sample.stop(expenseApiTimer);
        expenseApiCounter.increment();
    }
    
    private double getActiveUsers() {
        // Implementation to get active users count
        return 0.0;
    }
}
```

## 📈 **Performance Benchmarks**

### **Backend Performance Targets**
- **API Response Time**: <500ms (95th percentile)
- **Database Query Time**: <200ms (average)
- **OCR Processing Time**: <5 seconds (per receipt)
- **Concurrent Users**: 100+ simultaneous users
- **Throughput**: 1000+ requests per minute

### **Frontend Performance Targets**
- **Initial Page Load**: <3 seconds
- **Component Render Time**: <1 second
- **Chart Rendering**: <500ms
- **API Response Time**: <1 second
- **User Interaction**: <200ms

### **Database Performance Targets**
- **Query Response Time**: <100ms (indexed queries)
- **Connection Pool**: 20-50 connections
- **Index Hit Ratio**: >95%
- **Lock Wait Time**: <50ms

## 🚀 **Running Performance Tests**

### **Backend Performance Tests**
```bash
# Run performance tests
mvn test -Dtest="*PerformanceTest"

# Run with specific profiles
mvn test -Dspring.profiles.active=performance

# Run JMeter tests
jmeter -n -t performance-test-plan.jmx -l results.jtl
```

### **Frontend Performance Tests**
```bash
# Run Lighthouse tests
npm run lighthouse

# Run WebPageTest
npm run webpagetest

# Run performance tests
npm run test:performance
```

## 📊 **Performance Monitoring**

### **Application Metrics**
- **Response Time**: Average, 95th percentile, 99th percentile
- **Throughput**: Requests per second
- **Error Rate**: Percentage of failed requests
- **Resource Usage**: CPU, Memory, Disk I/O

### **Database Metrics**
- **Query Performance**: Slow query analysis
- **Connection Pool**: Active connections
- **Index Usage**: Index hit ratio
- **Lock Contention**: Lock wait time

### **Frontend Metrics**
- **Page Load Time**: First Contentful Paint, Largest Contentful Paint
- **Time to Interactive**: User interaction readiness
- **Bundle Size**: JavaScript bundle optimization
- **Memory Usage**: Heap size and garbage collection

This comprehensive performance testing plan ensures the Expense Tracker application meets performance requirements under various load conditions! 🎯 