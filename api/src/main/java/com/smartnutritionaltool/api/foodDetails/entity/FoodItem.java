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
    private String foodCode;
    private String foodGroup;
    private Integer number;
    private String vitamins; //food name
    private Double vita;
    private Double aVita;
    private Double vitd;
    private Double vite;
    private Double vitc;
    private Double thia;
    private Double ribf;
    private Double nia;
    private Double vitB6;
    private Double fol;
    private Double vitB12;
    private Double pant;
}
