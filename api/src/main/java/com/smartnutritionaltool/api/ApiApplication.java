package com.smartnutritionaltool.api;

import com.smartnutritionaltool.api.foodDetails.entity.FoodItem;
import com.smartnutritionaltool.api.foodDetails.repository.FoodItemRepository;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;


import java.io.InputStream;

@SpringBootApplication
public class ApiApplication {

	public static void main(String[] args) {
		SpringApplication.run(ApiApplication.class, args);
	}

	@Bean
	CommandLineRunner loadData(FoodItemRepository repository) {
		return args -> {
			try (InputStream fis = getClass().getClassLoader().getResourceAsStream("static/food-data.xlsx")) {
                assert fis != null;
                try (Workbook workbook = new XSSFWorkbook(fis)) {

                    Sheet sheet = workbook.getSheetAt(0);

                    for (int i = 1; i <= sheet.getLastRowNum(); i++) {
                        Row row = sheet.getRow(i);
                        FoodItem item = new FoodItem();

                        item.setFoodItem(getString(row, 0));
                        item.setFoodType(getString(row, 1));
                        item.setCalories(getDouble(row, 2));
                        item.setProtein(getDouble(row, 3));
                        item.setFats(getDouble(row, 4));
                        item.setCarbs(getDouble(row, 5));
                        item.setChorestrol(getDouble(row, 6));
                        item.setSugar(getDouble(row, 7));
                        item.setVitaminA(getDouble(row, 8));
                        item.setVitaminD(getDouble(row, 9));
                        item.setVitaminC(getDouble(row, 10));
                        item.setVitaminE(getDouble(row, 11));
                        item.setVitaminB6(getDouble(row, 12));
                        item.setVitaminB12(getDouble(row, 13));
                        item.setCa(getDouble(row, 14));
                        item.setMg(getDouble(row, 15));
                        item.setK(getDouble(row, 16));
                        item.setFe(getDouble(row, 17));
                        item.setZn(getDouble(row, 18));
                        item.setSaturatedFat(getDouble(row, 19));
                        item.setFiber(getDouble(row, 20));
                        item.setSodium(getDouble(row, 21));

                        repository.save(item);
                    }
                }
            }
		};
	}


	private Double getDouble(Row row, int colIndex) {
		Cell cell = row.getCell(colIndex);
		return (cell != null && cell.getCellType() == CellType.NUMERIC) ? cell.getNumericCellValue() : 0.0;
	}

	private String getString(Row row, int colIndex) {
		Cell cell = row.getCell(colIndex);
		if (cell == null) {
			return "";
		}
		switch (cell.getCellType()) {
			case NUMERIC:
				return String.valueOf(cell.getNumericCellValue());
			case STRING:
				return cell.getStringCellValue();
			case BOOLEAN:
				return String.valueOf(cell.getBooleanCellValue());
			case FORMULA:
				return cell.getCellFormula();
			default:
				return "";
		}
	}

}
