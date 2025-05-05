package com.smartnutritionaltool.api;

import com.smartnutritionaltool.api.foodDetails.entity.FoodItem;
import com.smartnutritionaltool.api.foodDetails.repository.FoodItemRepository;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

import java.io.FileInputStream;

@SpringBootApplication
public class ApiApplication {

	public static void main(String[] args) {
		SpringApplication.run(ApiApplication.class, args);
	}

	@Bean
	CommandLineRunner loadData(FoodItemRepository repository) {
		return args -> {
			FileInputStream fis = new FileInputStream("src/main/resources/static/food-data.xlsx");
			Workbook workbook = new XSSFWorkbook(fis);
			Sheet sheet = workbook.getSheetAt(0);

			for (int i = 1; i <= sheet.getLastRowNum(); i++) {
				Row row = sheet.getRow(i);
				FoodItem item = new FoodItem();

				item.setFoodCode(row.getCell(0).getStringCellValue());
				item.setFoodGroup(row.getCell(1).getStringCellValue());
				item.setNumber((int) row.getCell(2).getNumericCellValue());
				item.setVitamins(row.getCell(3).getStringCellValue());

				item.setVita(getDouble(row, 4));
				item.setAVita(getDouble(row, 5));
				item.setVitd(getDouble(row, 6));
				item.setVite(getDouble(row, 7));
				item.setVitc(getDouble(row, 8));
				item.setThia(getDouble(row, 9));
				item.setRibf(getDouble(row, 10));
				item.setNia(getDouble(row, 11));
				item.setVitB6(getDouble(row, 12));
				item.setFol(getDouble(row, 13));
				item.setVitB12(getDouble(row, 14));
				item.setPant(getDouble(row, 15));

				repository.save(item);
			}

			workbook.close();
		};
	}

	private Double getDouble(Row row, int colIndex) {
		Cell cell = row.getCell(colIndex);
		return (cell != null && cell.getCellType() == CellType.NUMERIC) ? cell.getNumericCellValue() : 0.0;
	}

}
