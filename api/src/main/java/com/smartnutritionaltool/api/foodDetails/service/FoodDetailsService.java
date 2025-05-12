package com.smartnutritionaltool.api.foodDetails.service;

import com.smartnutritionaltool.api.foodDetails.entity.FoodItem;

import java.util.List;

public interface FoodDetailsService {
    List<FoodItem> getFoodDetailsByFoodName(String foodName);
}
