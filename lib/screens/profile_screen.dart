import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/userprofile_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const List<String> allHealthConditions = [
    'Diabetes',
    'Hypertension',
    'Cardiovascular Disease',
    'Asthma',
    'Allergies',
    'Kidney Disease',
    'Anemia',
  ];

  static const List<String> allDietaryRestrictions = [
    'Gluten-Free',
    'Lactose-Free',
    'Vegan',
    'Vegetarian',
    'Nut-Free',
    'Halal',
    'Kosher',
    'Pescatarian',
  ];

  static const List<String> allDietaryGoals = [
    'Weight Loss',
    'Muscle Gain',
    'Maintenance',
    'Improve Energy',
    'Better Sleep',
    'Manage Diabetes',
    'Lower Cholesterol',
    'Heart Health',
  ];

  @override
  Widget build(BuildContext context) {
    final userProfileProvider = Provider.of<UserProfileProvider>(context);
    final profile = userProfileProvider.profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.calculate),
            onPressed: () {
              userProfileProvider.updateCalorieGoal();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Calorie goal updated!')),
              );
            },
            tooltip: 'Calculate Calorie Goal',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey.shade300,
            child: Icon(Icons.person, size: 50, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              (profile != null && profile.name?.isNotEmpty == true)
                  ? profile.name!
                  : 'No Name',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          if (profile?.totalCaloriesGoal != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Center(
                child: Text(
                  'Daily Calories: ${profile!.totalCaloriesGoal!.round()} kcal',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.green[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 24),

          // Now with dividers after each item
          _buildProfileItemWithDivider(context, 'Name', profile?.name, () {
            _editField(context, 'Name', profile?.name, (val) {
              userProfileProvider.updateName(val);
              userProfileProvider.saveUserProfile();
            });
          }),
          _buildProfileItemWithDivider(context, 'Gender', profile?.gender, () {
            _editField(context, 'Gender', profile?.gender, (val) {
              userProfileProvider.updateGender(val);
              userProfileProvider.saveUserProfile();
            });
          }),
          _buildProfileItemWithDivider(
            context,
            'Age',
            profile?.age?.toString(),
            () {
              _editField(context, 'Age', profile?.age?.toString(), (val) {
                final age = int.tryParse(val);
                if (age != null) {
                  userProfileProvider.updateAge(age);
                  userProfileProvider.saveUserProfile();
                }
              });
            },
          ),
          _buildProfileItemWithDivider(
            context,
            'Height (cm)',
            profile?.height?.toString(),
            () {
              _editField(context, 'Height (cm)', profile?.height?.toString(), (
                val,
              ) {
                final height = double.tryParse(val);
                if (height != null) {
                  userProfileProvider.updateHeight(height);
                  userProfileProvider.saveUserProfile();
                }
              });
            },
          ),
          _buildProfileItemWithDivider(
            context,
            'Weight (kg)',
            profile?.weight?.toString(),
            () {
              _editField(context, 'Weight (kg)', profile?.weight?.toString(), (
                val,
              ) {
                final weight = double.tryParse(val);
                if (weight != null) {
                  userProfileProvider.updateWeight(weight);
                  userProfileProvider.saveUserProfile();
                }
              });
            },
          ),
          _buildProfileItemWithDivider(
            context,
            'Activity Level',
            profile?.activityLevel,
            () {
              _editField(context, 'Activity Level', profile?.activityLevel, (
                val,
              ) {
                userProfileProvider.updateActivityLevel(val);
                userProfileProvider.saveUserProfile();
              });
            },
          ),

          _buildProfileItemWithDivider(
            context,
            'Health Conditions',
            (profile?.healthConditions?.isNotEmpty ?? false)
                ? profile!.healthConditions?.join(', ')
                : 'None',
            () async {
              final selected = await _showMultiSelectDialog(
                context,
                'Select Health Conditions',
                allHealthConditions,
                profile?.healthConditions ?? [],
              );
              if (selected != null) {
                userProfileProvider.updateHealthConditions(selected);
                userProfileProvider.saveUserProfile();
              }
            },
          ),
          _buildProfileItemWithDivider(
            context,
            'Dietary Restrictions',
            (profile?.dietaryRestrictions?.isNotEmpty ?? false)
                ? profile!.dietaryRestrictions?.join(', ')
                : 'None',
            () async {
              final selected = await _showMultiSelectDialog(
                context,
                'Select Dietary Restrictions',
                allDietaryRestrictions,
                profile?.dietaryRestrictions ?? [],
              );
              if (selected != null) {
                userProfileProvider.updateDietRestrictions(selected);
                userProfileProvider.saveUserProfile();
              }
            },
          ),
          _buildProfileItemWithDivider(
            context,
            'Dietary Goals',
            (profile?.dietaryGoals?.isNotEmpty ?? false)
                ? profile!.dietaryGoals?.join(', ')
                : 'None',
            () async {
              final selected = await _showMultiSelectDialog(
                context,
                'Select Dietary Goals',
                allDietaryGoals,
                profile?.dietaryGoals ?? [],
              );
              if (selected != null) {
                userProfileProvider.setDietaryGoals(selected);
                userProfileProvider.saveUserProfile();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItemWithDivider(
    BuildContext context,
    String label,
    String? value,
    VoidCallback onEdit,
  ) {
    return Column(
      children: [
        ListTile(
          title: Text(label),
          subtitle: Text(value ?? 'Not set'),
          trailing: const Icon(Icons.edit),
          onTap: onEdit,
        ),
        const Divider(height: 1),
      ],
    );
  }

  void _editField(
    BuildContext context,
    String label,
    String? initialValue,
    Function(String) onSave,
  ) {
    final controller = TextEditingController(text: initialValue ?? '');
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Edit $label'),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(labelText: label),
              keyboardType:
                  (label == 'Age' ||
                          label.contains('Height') ||
                          label.contains('Weight'))
                      ? TextInputType.number
                      : TextInputType.text,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  onSave(controller.text.trim());
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  Future<List<String>?> _showMultiSelectDialog(
    BuildContext context,
    String title,
    List<String> allOptions,
    List<String> initiallySelected,
  ) {
    final selectedValues = List<String>.from(initiallySelected);

    return showDialog<List<String>>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(title),
            content: StatefulBuilder(
              builder:
                  (context, setState) => SingleChildScrollView(
                    child: ListBody(
                      children:
                          allOptions.map((option) {
                            final isSelected = selectedValues.contains(option);
                            return CheckboxListTile(
                              value: isSelected,
                              title: Text(option),
                              controlAffinity: ListTileControlAffinity.leading,
                              onChanged: (checked) {
                                setState(() {
                                  if (checked == true) {
                                    selectedValues.add(option);
                                  } else {
                                    selectedValues.remove(option);
                                  }
                                });
                              },
                            );
                          }).toList(),
                    ),
                  ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, selectedValues),
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }
}
