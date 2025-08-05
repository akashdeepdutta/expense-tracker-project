package com.expensetracker.repository;

import com.expensetracker.model.Category;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CategoryRepository extends JpaRepository<Category, Long> {

    /**
     * Find categories by user
     */
    List<Category> findByUserId(Long userId);

    /**
     * Find default categories
     */
    List<Category> findByIsDefaultTrue();

    /**
     * Find categories by user including defaults
     */
    @Query("SELECT c FROM Category c WHERE c.user.id = :userId OR c.isDefault = true")
    List<Category> findByUserIdIncludingDefaults(@Param("userId") Long userId);

    /**
     * Find category by name and user
     */
    Category findByNameAndUserId(String name, Long userId);

    /**
     * Check if category exists by name and user
     */
    boolean existsByNameAndUserId(String name, Long userId);

    /**
     * Find categories by user with usage count
     */
    @Query("SELECT c, COUNT(e) FROM Category c LEFT JOIN c.expenses e WHERE c.user.id = :userId GROUP BY c")
    List<Object[]> findCategoriesWithUsageCount(@Param("userId") Long userId);
} 