package com.expensetracker.controller;

import com.expensetracker.model.Expense;
import com.expensetracker.service.ExpenseService;
import com.expensetracker.service.OcrService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Map;

@RestController
@RequestMapping("/expenses")
@CrossOrigin(origins = "*")
public class ExpenseController {

    @Autowired
    private ExpenseService expenseService;

    @Autowired
    private OcrService ocrService;

    /**
     * Get all expenses with pagination and filters
     */
    @GetMapping
    public ResponseEntity<Page<Expense>> getExpenses(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            @RequestParam(required = false) String currency,
            @RequestParam(required = false) BigDecimal minAmount,
            @RequestParam(required = false) BigDecimal maxAmount,
            @RequestParam(required = false) String tags) {

        // TODO: Get current user ID from security context
        Long userId = 1L; // Placeholder

        Pageable pageable = PageRequest.of(page, size);
        Page<Expense> expenses = expenseService.getExpenses(userId, pageable, categoryId, 
                startDate, endDate, currency, minAmount, maxAmount, tags);

        return ResponseEntity.ok(expenses);
    }

    /**
     * Get expense by ID
     */
    @GetMapping("/{id}")
    public ResponseEntity<Expense> getExpense(@PathVariable Long id) {
        // TODO: Get current user ID from security context
        Long userId = 1L; // Placeholder

        return expenseService.getExpenseById(id, userId)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    /**
     * Create new expense
     */
    @PostMapping
    public ResponseEntity<Expense> createExpense(@Valid @RequestBody Expense expense) {
        // TODO: Get current user ID from security context
        Long userId = 1L; // Placeholder

        Expense createdExpense = expenseService.createExpense(userId, expense);
        return ResponseEntity.ok(createdExpense);
    }

    /**
     * Update expense
     */
    @PutMapping("/{id}")
    public ResponseEntity<Expense> updateExpense(@PathVariable Long id, 
                                               @Valid @RequestBody Expense expense) {
        // TODO: Get current user ID from security context
        Long userId = 1L; // Placeholder

        try {
            Expense updatedExpense = expenseService.updateExpense(id, userId, expense);
            return ResponseEntity.ok(updatedExpense);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    /**
     * Delete expense
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteExpense(@PathVariable Long id) {
        // TODO: Get current user ID from security context
        Long userId = 1L; // Placeholder

        try {
            expenseService.deleteExpense(id, userId);
            return ResponseEntity.noContent().build();
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    /**
     * Scan receipt and extract data
     */
    @PostMapping("/scan-receipt")
    public ResponseEntity<OcrService.ReceiptData> scanReceipt(@RequestBody Map<String, String> request) {
        String imageBase64 = request.get("imageBase64");
        String imageFormat = request.get("imageFormat");

        if (imageBase64 == null || imageFormat == null) {
            return ResponseEntity.badRequest().build();
        }

        try {
            OcrService.ReceiptData receiptData = ocrService.extractReceiptData(imageBase64, imageFormat);
            return ResponseEntity.ok(receiptData);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }

    /**
     * Upload receipt for existing expense
     */
    @PostMapping("/{id}/receipt")
    public ResponseEntity<Expense> uploadReceipt(@PathVariable Long id, 
                                               @RequestBody Map<String, String> request) {
        // TODO: Get current user ID from security context
        Long userId = 1L; // Placeholder

        String imageBase64 = request.get("imageBase64");
        String imageFormat = request.get("imageFormat");

        if (imageBase64 == null || imageFormat == null) {
            return ResponseEntity.badRequest().build();
        }

        try {
            // Extract receipt data
            OcrService.ReceiptData receiptData = ocrService.extractReceiptData(imageBase64, imageFormat);
            
            // Update expense with receipt data
            Expense expense = expenseService.getExpenseById(id, userId)
                    .orElseThrow(() -> new RuntimeException("Expense not found"));
            
            // TODO: Save image to storage and get URL
            expense.setReceiptImageUrl("receipt_" + id + ".jpg");
            
            // Update expense with extracted data
            if (receiptData.getMerchantName() != null) {
                expense.setTitle(receiptData.getMerchantName());
            }
            if (receiptData.getTotalAmount() != null) {
                expense.setAmount(receiptData.getTotalAmount());
            }
            if (receiptData.getDate() != null) {
                expense.setDate(receiptData.getDate());
            }

            Expense updatedExpense = expenseService.updateExpense(id, userId, expense);
            return ResponseEntity.ok(updatedExpense);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }

    /**
     * Get expense statistics
     */
    @GetMapping("/statistics")
    public ResponseEntity<Map<String, Object>> getStatistics(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {

        // TODO: Get current user ID from security context
        Long userId = 1L; // Placeholder

        if (startDate == null) {
            startDate = LocalDate.now().minusMonths(1);
        }
        if (endDate == null) {
            endDate = LocalDate.now();
        }

        Map<String, Object> statistics = expenseService.getExpenseStatistics(userId, startDate, endDate);
        return ResponseEntity.ok(statistics);
    }

    /**
     * Get spending by category
     */
    @GetMapping("/analytics/spending-by-category")
    public ResponseEntity<Map<String, Object>> getSpendingByCategory(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {

        // TODO: Get current user ID from security context
        Long userId = 1L; // Placeholder

        if (startDate == null) {
            startDate = LocalDate.now().minusMonths(1);
        }
        if (endDate == null) {
            endDate = LocalDate.now();
        }

        Map<String, Object> spendingByCategory = expenseService.getSpendingByCategory(userId, startDate, endDate);
        return ResponseEntity.ok(spendingByCategory);
    }

    /**
     * Get spending trend
     */
    @GetMapping("/analytics/spending-trend")
    public ResponseEntity<Map<String, Object>> getSpendingTrend(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {

        // TODO: Get current user ID from security context
        Long userId = 1L; // Placeholder

        if (startDate == null) {
            startDate = LocalDate.now().minusMonths(1);
        }
        if (endDate == null) {
            endDate = LocalDate.now();
        }

        Map<String, Object> trend = Map.of("trends", expenseService.getSpendingTrend(userId, startDate, endDate));
        return ResponseEntity.ok(trend);
    }

    /**
     * Get reimbursable expenses
     */
    @GetMapping("/reimbursable")
    public ResponseEntity<Map<String, Object>> getReimbursableExpenses() {
        // TODO: Get current user ID from security context
        Long userId = 1L; // Placeholder

        Map<String, Object> response = Map.of("expenses", expenseService.getReimbursableExpenses(userId));
        return ResponseEntity.ok(response);
    }
} 