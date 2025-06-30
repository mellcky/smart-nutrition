import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_profile.dart';
import '/models/food_item.dart';
import '/models/water_log.dart';

class UserDatabaseHelper {
  static final UserDatabaseHelper _instance = UserDatabaseHelper._internal();
  factory UserDatabaseHelper() => _instance;
  UserDatabaseHelper._internal();

  static Database? _database;

  // Table name
  final String tableUser = 'user_profile';
  final String tableFoodItems = 'food_items';
  final String tableWaterLogs = 'water_logs';

  // Initialize the database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  // Create database path and table
  Future<Database> _initDb() async {
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'user_profile.db');

    return await openDatabase(
      path, 
      version: 2, 
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Handle database upgrades
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Create water_logs table if upgrading from version 1
      await db.execute('''
        CREATE TABLE $tableWaterLogs (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          amount REAL,
          timestamp INTEGER
        )
      ''');
      print('Created water_logs table during upgrade from version $oldVersion to $newVersion');
    }
  }

  // SQL to create the user_profile table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableUser (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        gender TEXT,
        age INTEGER,
        height REAL,
        weight REAL,
        healthConditions TEXT,
        dietaryRestrictions TEXT,
        activityLevel TEXT,
        dietaryGoals TEXT,
        name TEXT,
        totalCaloriesGoal REAL,
        timestamp INTEGER DEFAULT (strftime('%s', 'now'))
        )
    ''');

    await db.execute('''
      CREATE TABLE $tableFoodItems (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        foodItem TEXT,
        calories REAL,
        protein REAL,
        fats REAL,
        carbs REAL,
        chorestrol REAL,     
        sugar REAL,
        vitaminA REAL,
        vitaminD REAL,
        vitaminC REAL,
        vitaminE REAL,
        vitaminB6 REAL,      
        vitaminB12 REAL,
        ca REAL,
        mg REAL,
        k REAL,
        fe REAL,
        zn REAL,
        saturatedFat REAL,  
        fiber REAL,
        sodium REAL,
        mealType TEXT,      
        timestamp INTEGER,
        imagePath TEXT 
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableWaterLogs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL,
        timestamp INTEGER
      )
    ''');
  }

  // Insert a user profile
  Future<int> insertUser(UserProfile profile) async {
    final db = await database;
    return await db.insert(tableUser, profile.toMap());
  }

  // Get all user profiles
  Future<List<UserProfile>> getUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableUser);
    return maps.map((map) => UserProfile.fromMap(map)).toList();
  }

  // Update a user profile
  Future<int> updateUser(UserProfile profile) async {
    final db = await database;
    return await db.update(
      tableUser,
      profile.toMap(),
      where: 'id = ?',
      whereArgs: [profile.id],
    );
  }

  // Delete a user profile
  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete(tableUser, where: 'id = ?', whereArgs: [id]);
  }

  // Clear all users
  Future<void> clearUsers() async {
    final db = await database;
    await db.delete(tableUser);
  }

  Future<int> insertFoodItem(FoodItem foodItem) async {
    final db = await database;
    return await db.insert(tableFoodItems, foodItem.toMap());
  }

  Future<List<FoodItem>> getFoodItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableFoodItems);
    return List.generate(maps.length, (i) => FoodItem.fromMap(maps[i]));
  }

  Future<List<FoodItem>> getFoodItemsByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(Duration(days: 1));

    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableFoodItems,
      where: 'timestamp >= ? AND timestamp < ?',
      whereArgs: [
        startOfDay.millisecondsSinceEpoch,
        endOfDay.millisecondsSinceEpoch,
      ],
    );
    return List.generate(maps.length, (i) => FoodItem.fromMap(maps[i]));
  }

  Future<List<FoodItem>> getFoodItemsByMealTypeAndDate(
    String mealType,
    DateTime date,
  ) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(Duration(days: 1));

    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableFoodItems,
      where: 'mealType = ? AND timestamp >= ? AND timestamp < ?',
      whereArgs: [
        mealType,
        startOfDay.millisecondsSinceEpoch,
        endOfDay.millisecondsSinceEpoch,
      ],
    );
    return List.generate(maps.length, (i) => FoodItem.fromMap(maps[i]));
  }

  // Water logging methods
  Future<int> insertWaterLog(WaterLog waterLog) async {
    try {
      final db = await database;

      // Use a transaction to ensure database operations are atomic
      return await db.transaction((txn) async {
        return await txn.insert(tableWaterLogs, waterLog.toMap());
      });
    } catch (e) {
      print('Error inserting water log: $e');
      return -1;
    }
  }

  Future<List<WaterLog>> getWaterLogs() async {
    try {
      final db = await database;

      // Use a transaction to ensure database operations are atomic
      return await db.transaction((txn) async {
        final List<Map<String, dynamic>> maps = await txn.query(tableWaterLogs);
        return List.generate(maps.length, (i) => WaterLog.fromMap(maps[i]));
      });
    } catch (e) {
      print('Error getting water logs: $e');
      return [];
    }
  }

  Future<List<WaterLog>> getWaterLogsByDate(DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(Duration(days: 1));

      final db = await database;

      // Use a transaction to ensure database operations are atomic
      return await db.transaction((txn) async {
        final List<Map<String, dynamic>> maps = await txn.query(
          tableWaterLogs,
          where: 'timestamp >= ? AND timestamp < ?',
          whereArgs: [
            startOfDay.millisecondsSinceEpoch,
            endOfDay.millisecondsSinceEpoch,
          ],
        );
        return List.generate(maps.length, (i) => WaterLog.fromMap(maps[i]));
      });
    } catch (e) {
      print('Error getting water logs by date: $e');
      return [];
    }
  }

  Future<double> getTotalWaterForDate(DateTime date) async {
    try {
      final waterLogs = await getWaterLogsByDate(date);
      return waterLogs.fold<double>(0.0, (sum, log) => sum + log.amount);
    } catch (e) {
      print('Error getting total water for date: $e');
      return 0.0;
    }
  }

  Future<List<WaterLog>> getWaterLogsByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final start = DateTime(startDate.year, startDate.month, startDate.day);
      final end = DateTime(endDate.year, endDate.month, endDate.day).add(Duration(days: 1));

      final db = await database;

      // Use a transaction to ensure database operations are atomic
      return await db.transaction((txn) async {
        final List<Map<String, dynamic>> maps = await txn.query(
          tableWaterLogs,
          where: 'timestamp >= ? AND timestamp < ?',
          whereArgs: [
            start.millisecondsSinceEpoch,
            end.millisecondsSinceEpoch,
          ],
        );
        return List.generate(maps.length, (i) => WaterLog.fromMap(maps[i]));
      });
    } catch (e) {
      print('Error getting water logs by date range: $e');
      return [];
    }
  }
}
