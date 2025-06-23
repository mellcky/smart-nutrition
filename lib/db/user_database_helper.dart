import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_profile.dart';
import '/models/food_item.dart';

class UserDatabaseHelper {
  static final UserDatabaseHelper _instance = UserDatabaseHelper._internal();
  factory UserDatabaseHelper() => _instance;
  UserDatabaseHelper._internal();

  static Database? _database;

  // Table name
  final String tableUser = 'user_profile';
  final String tableFoodItems = 'food_items';

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

    return await openDatabase(path, version: 1, onCreate: _onCreate);
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
        timestamp INTEGER 
      )
    ''');
  }

  // Insert a user profile
  Future<int> insertUser(UserProfile profile) async {
    final db = await database;
    return await db.insert(tableUser, profile.toMap());
  }

  // Get all user profiles (you'll usually only have one)
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

  // Optional: Clear all users (e.g., for testing or logout)
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

  // user_database_helper.dart
  Future<List<FoodItem>> getFoodItemsByMealType(String mealType) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableFoodItems,
      where: 'mealType = ?',
      whereArgs: [mealType],
    );
    return List.generate(maps.length, (i) => FoodItem.fromMap(maps[i]));
  }
}
