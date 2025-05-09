package com.smartnutritionaltool.api.foodDetails.repository;

import com.smartnutritionaltool.api.foodDetails.entity.FoodItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface FoodItemRepository extends JpaRepository<FoodItem, Long> {

}
