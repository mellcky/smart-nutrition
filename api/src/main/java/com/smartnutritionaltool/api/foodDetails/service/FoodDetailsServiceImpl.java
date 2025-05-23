package com.smartnutritionaltool.api.foodDetails.service;

import com.smartnutritionaltool.api.foodDetails.entity.FoodItem;
import com.smartnutritionaltool.api.foodDetails.repository.FoodItemRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class FoodDetailsServiceImpl implements FoodDetailsService{

    private final FoodItemRepository foodItemRepository;

    @Override
    public List<FoodItem> getFoodDetailsByFoodName(String foodName) {
        return foodItemRepository.findAllByFoodTypeIgnoreCase(foodName);
    }

    @Override
    public FoodItem getFoodDetailByFoodName(String foodName) {
        return foodItemRepository.findByFoodTypeIgnoreCase(foodName);
    }

}
