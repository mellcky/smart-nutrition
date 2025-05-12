package com.smartnutritionaltool.api.foodDetails.repository;

import com.smartnutritionaltool.api.foodDetails.entity.FoodItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface FoodItemRepository extends JpaRepository<FoodItem, Long> {

    FoodItem findByVitaminsIgnoreCase(String vitamins);
    List<FoodItem> findAllByVitaminsIgnoreCase(String vitamins);

}
