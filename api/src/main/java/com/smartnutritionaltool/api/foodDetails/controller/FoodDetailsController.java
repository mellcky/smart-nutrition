package com.smartnutritionaltool.api.foodDetails.controller;

import com.smartnutritionaltool.api.foodDetails.entity.FoodItem;
import com.smartnutritionaltool.api.foodDetails.service.FoodDetailsServiceImpl;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping(path = "/api/v1/smart-nutritional-tool/food-details")
@RequiredArgsConstructor
public class FoodDetailsController {

    private final FoodDetailsServiceImpl foodDetailsService;

    @GetMapping("/{food-name}")
    public ResponseEntity<List<FoodItem>> getFoodDetails(@PathVariable("food-name") String foodName) {
        if (foodName == null) {
            throw new IllegalArgumentException("foodDetails cannot be null");
        }

        final List<FoodItem> foodItem = foodDetailsService.getFoodDetailsByFoodName(foodName);
        if (foodItem == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(foodItem);
    }

    @GetMapping("/single/{food-name}")
    public ResponseEntity<FoodItem> getFoodDetail(@PathVariable("food-name") String foodName) {
        if (foodName == null) {
            throw new IllegalArgumentException("foodDetails cannot be null");
        }

        final FoodItem foodItem = foodDetailsService.getFoodDetailByFoodName(foodName);
        if (foodItem == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(foodItem);
    }
}
