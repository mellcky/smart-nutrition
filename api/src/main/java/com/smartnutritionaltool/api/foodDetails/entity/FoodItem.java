package com.smartnutritionaltool.api.foodDetails.entity;


import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@NoArgsConstructor
@AllArgsConstructor
@Setter
@Getter
@Entity
@Table(name = "food_items")
public class FoodItem {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long foodItemId;

    @Column(name = "food_name")
    private String foodItem;

    private String foodType;

    @Column(name = "calories")
    private Double calories;
    private Double protein;//grams
    private Double fats;//Gg
    private Double carbs;//grams
    private Double chorestrol;//mg
    private Double sugar;
    private Double vitaminA;
    private Double vitaminD;
    private Double vitaminC;
    private Double vitaminE;
    private Double vitaminB6;
    private Double vitaminB12;
    private Double ca;
    private Double mg;
    private Double k;
    private Double fe;
    private Double zn;
    private Double saturatedFat;
    private Double fiber;
    private Double sodium;
}
