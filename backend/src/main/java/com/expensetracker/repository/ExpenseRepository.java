package com.expensetracker.repository;

import com.expensetracker.model.Expense;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Repository
public interface ExpenseRepository extends JpaRepository<Expense, Long> {

    /**
     * Find expenses by user with pagination
     */
    Page<Expense> findByUserId(Long userId, Pageable pageable);

    /**
     * Find expenses by user and date range
     */
    @Query("SELECT e FROM Expense e WHERE e.user.id = :userId AND e.date BETWEEN :startDate AND :endDate")
    List<Expense> findByUserIdAndDateBetween(@Param("userId") Long userId, 
                                           @Param("startDate") LocalDate startDate, 
                                           @Param("endDate") LocalDate endDate);

    /**
     * Find expenses by user and category
     */
    List<Expense> findByUserIdAndCategoryId(Long userId, Long categoryId);

    /**
     * Find expenses by user and currency
     */
    List<Expense> findByUserIdAndCurrencyCode(Long userId, String currencyCode);

    /**
     * Find expenses by user and amount range
     */
    @Query("SELECT e FROM Expense e WHERE e.user.id = :userId AND e.amount BETWEEN :minAmount AND :maxAmount")
    List<Expense> findByUserIdAndAmountBetween(@Param("userId") Long userId,
                                             @Param("minAmount") BigDecimal minAmount,
                                             @Param("maxAmount") BigDecimal maxAmount);

    /**
     * Find expenses by user and tags (contains)
     */
    @Query("SELECT e FROM Expense e WHERE e.user.id = :userId AND e.tags LIKE %:tag%")
    List<Expense> findByUserIdAndTagsContaining(@Param("userId") Long userId, @Param("tag") String tag);

    /**
     * Find reimbursable expenses by user
     */
    List<Expense> findByUserIdAndIsReimbursableTrue(Long userId);

    /**
     * Find expenses by user and status
     */
    List<Expense> findByUserIdAndStatus(Long userId, Expense.ExpenseStatus status);

    /**
     * Get total amount by user and date range
     */
    @Query("SELECT SUM(e.amount) FROM Expense e WHERE e.user.id = :userId AND e.date BETWEEN :startDate AND :endDate")
    BigDecimal getTotalAmountByUserIdAndDateBetween(@Param("userId") Long userId,
                                                  @Param("startDate") LocalDate startDate,
                                                  @Param("endDate") LocalDate endDate);

    /**
     * Get total amount by user, category and date range
     */
    @Query("SELECT SUM(e.amount) FROM Expense e WHERE e.user.id = :userId AND e.category.id = :categoryId AND e.date BETWEEN :startDate AND :endDate")
    BigDecimal getTotalAmountByUserIdAndCategoryIdAndDateBetween(@Param("userId") Long userId,
                                                               @Param("categoryId") Long categoryId,
                                                               @Param("startDate") LocalDate startDate,
                                                               @Param("endDate") LocalDate endDate);

    /**
     * Get spending by category for user
     */
    @Query("SELECT e.category.id, e.category.name, SUM(e.amount), COUNT(e) " +
           "FROM Expense e WHERE e.user.id = :userId AND e.date BETWEEN :startDate AND :endDate " +
           "GROUP BY e.category.id, e.category.name")
    List<Object[]> getSpendingByCategory(@Param("userId") Long userId,
                                       @Param("startDate") LocalDate startDate,
                                       @Param("endDate") LocalDate endDate);

    /**
     * Get spending trend by period
     */
    @Query("SELECT DATE(e.date), SUM(e.amount), COUNT(e) " +
           "FROM Expense e WHERE e.user.id = :userId AND e.date BETWEEN :startDate AND :endDate " +
           "GROUP BY DATE(e.date) ORDER BY DATE(e.date)")
    List<Object[]> getSpendingTrend(@Param("userId") Long userId,
                                   @Param("startDate") LocalDate startDate,
                                   @Param("endDate") LocalDate endDate);

    /**
     * Get monthly spending for user
     */
    @Query("SELECT YEAR(e.date), MONTH(e.date), SUM(e.amount) " +
           "FROM Expense e WHERE e.user.id = :userId AND e.date BETWEEN :startDate AND :endDate " +
           "GROUP BY YEAR(e.date), MONTH(e.date) ORDER BY YEAR(e.date), MONTH(e.date)")
    List<Object[]> getMonthlySpending(@Param("userId") Long userId,
                                     @Param("startDate") LocalDate startDate,
                                     @Param("endDate") LocalDate endDate);

    /**
     * Find expenses with receipt images
     */
    @Query("SELECT e FROM Expense e WHERE e.user.id = :userId AND e.receiptImageUrl IS NOT NULL")
    List<Expense> findExpensesWithReceipts(@Param("userId") Long userId);

    /**
     * Count expenses by user and date range
     */
    @Query("SELECT COUNT(e) FROM Expense e WHERE e.user.id = :userId AND e.date BETWEEN :startDate AND :endDate")
    Long countByUserIdAndDateBetween(@Param("userId") Long userId,
                                    @Param("startDate") LocalDate startDate,
                                    @Param("endDate") LocalDate endDate);

    /**
     * Get average daily spending for user
     */
    @Query("SELECT AVG(daily.total) FROM (" +
           "SELECT DATE(e.date) as date, SUM(e.amount) as total " +
           "FROM Expense e WHERE e.user.id = :userId AND e.date BETWEEN :startDate AND :endDate " +
           "GROUP BY DATE(e.date)) as daily")
    BigDecimal getAverageDailySpending(@Param("userId") Long userId,
                                     @Param("startDate") LocalDate startDate,
                                     @Param("endDate") LocalDate endDate);
} 