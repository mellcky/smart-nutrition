package com.smartnutritionaltool.api.foodDetails.controller;

import com.smartnutritionaltool.api.foodDetails.service.FoodDetailsServiceImpl;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping(path = "/api/v1/smart-nutritional-tool/food-details")
@RequiredArgsConstructor
public class FoodDetailsController {

    private final FoodDetailsServiceImpl foodDetailsService;
}
