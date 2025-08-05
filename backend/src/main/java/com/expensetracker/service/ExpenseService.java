package com.expensetracker.service;


import com.expensetracker.model.Expense;
import com.expensetracker.model.User;
import com.expensetracker.repository.ExpenseRepository;
import com.expensetracker.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@Transactional
public class ExpenseService {

    @Autowired
    private ExpenseRepository expenseRepository;

    @Autowired
    private UserRepository userRepository;



    /**
     * Create a new expense
     */
    public Expense createExpense(Long userId, Expense expense) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        expense.setUser(user);
        
        // Set default currency if not provided
        if (expense.getCurrencyCode() == null) {
            expense.setCurrencyCode(user.getDefaultCurrency());
        }
        
        return expenseRepository.save(expense);
    }

    /**
     * Get expenses for user with pagination and filters
     */
    public Page<Expense> getExpenses(Long userId, Pageable pageable, 
                                   Long categoryId, LocalDate startDate, LocalDate endDate,
                                   String currency, BigDecimal minAmount, BigDecimal maxAmount,
                                   String tags) {
        
        Page<Expense> expenses = expenseRepository.findByUserId(userId, pageable);
        
        // Apply filters
        List<Expense> filteredExpenses = expenses.getContent().stream()
                .filter(expense -> categoryId == null || 
                        (expense.getCategory() != null && expense.getCategory().getId().equals(categoryId)))
                .filter(expense -> startDate == null || !expense.getDate().isBefore(startDate))
                .filter(expense -> endDate == null || !expense.getDate().isAfter(endDate))
                .filter(expense -> currency == null || expense.getCurrencyCode().equals(currency))
                .filter(expense -> minAmount == null || expense.getAmount().compareTo(minAmount) >= 0)
                .filter(expense -> maxAmount == null || expense.getAmount().compareTo(maxAmount) <= 0)
                .filter(expense -> tags == null || 
                        (expense.getTags() != null && expense.getTags().contains(tags)))
                .collect(Collectors.toList());
        
        return new org.springframework.data.domain.PageImpl<>(filteredExpenses, pageable, expenses.getTotalElements());
    }

    /**
     * Get expense by ID
     */
    public Optional<Expense> getExpenseById(Long expenseId, Long userId) {
        return expenseRepository.findById(expenseId)
                .filter(expense -> expense.getUser().getId().equals(userId));
    }

    /**
     * Update expense
     */
    public Expense updateExpense(Long expenseId, Long userId, Expense updatedExpense) {
        Expense existingExpense = expenseRepository.findById(expenseId)
                .filter(expense -> expense.getUser().getId().equals(userId))
                .orElseThrow(() -> new RuntimeException("Expense not found"));
        
        existingExpense.setTitle(updatedExpense.getTitle());
        existingExpense.setDescription(updatedExpense.getDescription());
        existingExpense.setAmount(updatedExpense.getAmount());
        existingExpense.setCurrencyCode(updatedExpense.getCurrencyCode());
        existingExpense.setDate(updatedExpense.getDate());
        existingExpense.setCategory(updatedExpense.getCategory());
        existingExpense.setLocation(updatedExpense.getLocation());
        existingExpense.setTags(updatedExpense.getTags());
        existingExpense.setIsReimbursable(updatedExpense.getIsReimbursable());
        existingExpense.setStatus(updatedExpense.getStatus());
        
        return expenseRepository.save(existingExpense);
    }

    /**
     * Delete expense
     */
    public void deleteExpense(Long expenseId, Long userId) {
        Expense expense = expenseRepository.findById(expenseId)
                .filter(e -> e.getUser().getId().equals(userId))
                .orElseThrow(() -> new RuntimeException("Expense not found"));
        
        expenseRepository.delete(expense);
    }

    /**
     * Get total spending for user in date range
     */
    public BigDecimal getTotalSpending(Long userId, LocalDate startDate, LocalDate endDate) {
        BigDecimal total = expenseRepository.getTotalAmountByUserIdAndDateBetween(userId, startDate, endDate);
        return total != null ? total : BigDecimal.ZERO;
    }

    /**
     * Get spending by category
     */
    public Map<String, Object> getSpendingByCategory(Long userId, LocalDate startDate, LocalDate endDate) {
        List<Object[]> results = expenseRepository.getSpendingByCategory(userId, startDate, endDate);
        
        List<Map<String, Object>> categories = results.stream()
                .map(row -> Map.of(
                    "categoryId", row[0],
                    "categoryName", row[1],
                    "totalAmount", row[2],
                    "count", row[3]
                ))
                .collect(Collectors.toList());
        
        BigDecimal totalAmount = categories.stream()
                .map(cat -> (BigDecimal) cat.get("totalAmount"))
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        
        return Map.of(
            "categories", categories,
            "totalAmount", totalAmount
        );
    }

    /**
     * Get spending trend
     */
    public List<Map<String, Object>> getSpendingTrend(Long userId, LocalDate startDate, LocalDate endDate) {
        List<Object[]> results = expenseRepository.getSpendingTrend(userId, startDate, endDate);
        
        return results.stream()
                .map(row -> Map.of(
                    "date", row[0],
                    "amount", row[1],
                    "count", row[2]
                ))
                .collect(Collectors.toList());
    }

    /**
     * Get monthly spending
     */
    public List<Map<String, Object>> getMonthlySpending(Long userId, LocalDate startDate, LocalDate endDate) {
        List<Object[]> results = expenseRepository.getMonthlySpending(userId, startDate, endDate);
        
        return results.stream()
                .map(row -> Map.of(
                    "year", row[0],
                    "month", row[1],
                    "amount", row[2]
                ))
                .collect(Collectors.toList());
    }

    /**
     * Get average daily spending
     */
    public BigDecimal getAverageDailySpending(Long userId, LocalDate startDate, LocalDate endDate) {
        BigDecimal average = expenseRepository.getAverageDailySpending(userId, startDate, endDate);
        return average != null ? average : BigDecimal.ZERO;
    }

    /**
     * Get expenses with receipts
     */
    public List<Expense> getExpensesWithReceipts(Long userId) {
        return expenseRepository.findExpensesWithReceipts(userId);
    }

    /**
     * Get reimbursable expenses
     */
    public List<Expense> getReimbursableExpenses(Long userId) {
        return expenseRepository.findByUserIdAndIsReimbursableTrue(userId);
    }

    /**
     * Update expense status
     */
    public Expense updateExpenseStatus(Long expenseId, Long userId, Expense.ExpenseStatus status) {
        Expense expense = expenseRepository.findById(expenseId)
                .filter(e -> e.getUser().getId().equals(userId))
                .orElseThrow(() -> new RuntimeException("Expense not found"));
        
        expense.setStatus(status);
        return expenseRepository.save(expense);
    }

    /**
     * Get expense statistics
     */
    public Map<String, Object> getExpenseStatistics(Long userId, LocalDate startDate, LocalDate endDate) {
        BigDecimal totalSpending = getTotalSpending(userId, startDate, endDate);
        BigDecimal averageDaily = getAverageDailySpending(userId, startDate, endDate);
        Long totalExpenses = expenseRepository.countByUserIdAndDateBetween(userId, startDate, endDate);
        
        return Map.of(
            "totalSpending", totalSpending,
            "averageDailySpending", averageDaily,
            "totalExpenses", totalExpenses,
            "period", Map.of("startDate", startDate, "endDate", endDate)
        );
    }
} 