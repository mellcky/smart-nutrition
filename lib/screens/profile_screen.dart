import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/userprofile_provider.dart';
import 'package:diet_app/utils/calorie_calculator.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Returns the appropriate avatar icon based on gender
  IconData _getAvatarIcon(String? gender) {
    if (gender == null) return Icons.person;

    switch (gender.toLowerCase()) {
      case 'male':
        return Icons.man;
      case 'female':
        return Icons.woman;
      default:
        return Icons.person;
    }
  }

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

    // Calculate BMI if height and weight are available
    String bmiText = 'Not available';
    String bmiCategory = '';
    Color bmiColor = Colors.grey;

    if (profile?.height != null && profile?.weight != null && 
        profile!.height! > 0 && profile.weight! > 0) {
      final bmi = profile.weight! / ((profile.height! / 100) * (profile.height! / 100));
      bmiText = bmi.toStringAsFixed(1);

      if (bmi < 18.5) {
        bmiCategory = 'Underweight';
        bmiColor = Colors.blue;
      } else if (bmi < 25) {
        bmiCategory = 'Healthy';
        bmiColor = Colors.green;
      } else if (bmi < 30) {
        bmiCategory = 'Overweight';
        bmiColor = Colors.orange;
      } else {
        bmiCategory = 'Obese';
        bmiColor = Colors.red;
      }
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with profile header
          SliverAppBar(
            expandedHeight: 200.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey.shade200,
                        child: Icon(
                          _getAvatarIcon(profile?.gender),
                          size: 40,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        (profile != null && profile.name?.isNotEmpty == true)
                            ? profile.name!
                            : 'No Name',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.calculate),
                onPressed: () {
                  userProfileProvider.updateCalorieGoal();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Calorie goal updated!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                tooltip: 'Calculate Calorie Goal',
              ),
            ],
          ),

          // Profile content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Health metrics card
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade200, width: 1),
                    ),
                    elevation: 0,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Row(
                              children: [
                                Icon(Icons.health_and_safety, color: Colors.grey.shade600, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Health Metrics',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Health metrics grid
                          Row(
                            children: [
                              // BMI
                              Expanded(
                                child: _buildMetricItem(
                                  'BMI',
                                  bmiText,
                                  bmiCategory,
                                  Colors.grey.shade700,
                                ),
                              ),

                              // Calories
                              Expanded(
                                child: _buildMetricItem(
                                  'Daily Calories',
                                  profile?.totalCaloriesGoal != null
                                      ? '${profile!.totalCaloriesGoal!.round()}'
                                      : 'N/A',
                                  'Goal',
                                  Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Personal info card
                  _buildSectionCard(
                    'Personal Information',
                    Icons.person_outline,
                    [
                      _buildProfileItem(
                        context,
                        'Name',
                        profile?.name,
                        Icons.badge_outlined,
                        () {
                          _editField(context, 'Name', profile?.name, (val) {
                            userProfileProvider.updateName(val);
                            userProfileProvider.saveUserProfile();
                          });
                        },
                      ),
                      _buildProfileItem(
                        context,
                        'Gender',
                        profile?.gender,
                        Icons.wc,
                        () {
                          _showSelectionDialog(
                            context,
                            'Select Gender',
                            ['Male', 'Female', 'Other'],
                            profile?.gender,
                            (val) {
                              userProfileProvider.updateGender(val);
                              userProfileProvider.saveUserProfile();
                            },
                          );
                        },
                      ),
                      _buildProfileItem(
                        context,
                        'Age',
                        profile?.age?.toString(),
                        Icons.cake_outlined,
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
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Body measurements card
                  _buildSectionCard(
                    'Body Measurements',
                    Icons.straighten,
                    [
                      _buildProfileItem(
                        context,
                        'Height (cm)',
                        profile?.height?.toString(),
                        Icons.height,
                        () {
                          _editField(context, 'Height (cm)', profile?.height?.toString(), (val) {
                            final height = double.tryParse(val);
                            if (height != null) {
                              userProfileProvider.updateHeight(height);
                              userProfileProvider.saveUserProfile();
                            }
                          });
                        },
                      ),
                      _buildProfileItem(
                        context,
                        'Weight (kg)',
                        profile?.weight?.toString(),
                        Icons.monitor_weight_outlined,
                        () {
                          _editField(context, 'Weight (kg)', profile?.weight?.toString(), (val) {
                            final weight = double.tryParse(val);
                            if (weight != null) {
                              userProfileProvider.updateWeight(weight);
                              userProfileProvider.saveUserProfile();
                            }
                          });
                        },
                      ),
                      _buildProfileItem(
                        context,
                        'Activity Level',
                        profile?.activityLevel,
                        Icons.directions_run,
                        () {
                          _showSelectionDialog(
                            context,
                            'Select Activity Level',
                            ['sedentary', 'light', 'moderate', 'active', 'very active'],
                            profile?.activityLevel,
                            (val) {
                              userProfileProvider.updateActivityLevel(val);
                              userProfileProvider.saveUserProfile();
                            },
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Health conditions card
                  _buildSectionCard(
                    'Health & Diet',
                    Icons.favorite_border,
                    [
                      _buildProfileItem(
                        context,
                        'Health Conditions',
                        (profile?.healthConditions?.isNotEmpty ?? false)
                            ? profile!.healthConditions?.join(', ')
                            : 'None',
                        Icons.medical_services_outlined,
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
                      _buildProfileItem(
                        context,
                        'Dietary Restrictions',
                        (profile?.dietaryRestrictions?.isNotEmpty ?? false)
                            ? profile!.dietaryRestrictions?.join(', ')
                            : 'None',
                        Icons.no_food_outlined,
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
                      _buildProfileItem(
                        context,
                        'Dietary Goals',
                        (profile?.dietaryGoals?.isNotEmpty ?? false)
                            ? profile!.dietaryGoals?.join(', ')
                            : 'None',
                        Icons.flag_outlined,
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

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build a metric item for the health metrics card
  Widget _buildMetricItem(String label, String value, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  // Build a section card with a title, icon, and list of items
  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  Icon(icon, color: Colors.grey.shade600, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }

  // Build a profile item with an icon
  Widget _buildProfileItem(
    BuildContext context,
    String label,
    String? value,
    IconData icon,
    VoidCallback onEdit,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
          child: Row(
            children: [
              Icon(
                icon,
                color: Colors.grey.shade500,
                size: 18,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      value ?? 'Not set',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade800,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  // Show a selection dialog for choosing from a list of options
  void _showSelectionDialog(
    BuildContext context,
    String title,
    List<String> options,
    String? currentValue,
    Function(String) onSelect,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade800,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((option) {
              final isSelected = option.toLowerCase() == currentValue?.toLowerCase();
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.grey.shade100 : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected ? Colors.grey.shade300 : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: ListTile(
                  dense: true,
                  title: Text(
                    option,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade800,
                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected ? Icon(Icons.check, color: Colors.grey.shade600, size: 18) : null,
                  onTap: () {
                    onSelect(option);
                    Navigator.pop(context);
                  },
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade700,
            ),
            child: const Text('Cancel'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _editField(
    BuildContext context,
    String label,
    String? initialValue,
    Function(String) onSave,
  ) {
    final controller = TextEditingController(text: initialValue ?? '');

    // Determine the appropriate icon based on the field
    IconData fieldIcon = Icons.edit;
    if (label == 'Age') {
      fieldIcon = Icons.cake_outlined;
    } else if (label.contains('Height')) {
      fieldIcon = Icons.height;
    } else if (label.contains('Weight')) {
      fieldIcon = Icons.monitor_weight_outlined;
    } else if (label == 'Name') {
      fieldIcon = Icons.badge_outlined;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Edit $label',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade800,
          ),
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: Colors.grey.shade600),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade500, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            prefixIcon: Icon(fieldIcon, color: Colors.grey.shade600, size: 20),
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
          keyboardType: (label == 'Age' ||
                  label.contains('Height') ||
                  label.contains('Weight'))
              ? TextInputType.number
              : TextInputType.text,
          autofocus: true,
          textInputAction: TextInputAction.done,
          style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              onSave(value.trim());
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade700,
            ),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                onSave(controller.text.trim());
                Navigator.pop(context);
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade800,
              backgroundColor: Colors.grey.shade200,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('Save'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
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
      builder: (_) => AlertDialog(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade800,
          ),
        ),
        content: StatefulBuilder(
          builder: (context, setState) => SizedBox(
            width: double.maxFinite,
            height: MediaQuery.of(context).size.height * 0.4,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Selected: ${selectedValues.length}/${allOptions.length}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                      if (selectedValues.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              selectedValues.clear();
                            });
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey.shade700,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Clear All', style: TextStyle(fontSize: 13)),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: allOptions.length,
                    itemBuilder: (context, index) {
                      final option = allOptions[index];
                      final isSelected = selectedValues.contains(option);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.grey.shade100 : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isSelected ? Colors.grey.shade300 : Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: CheckboxListTile(
                          value: isSelected,
                          title: Text(
                            option,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade800,
                              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                            ),
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: Colors.grey.shade500,
                          checkColor: Colors.white,
                          onChanged: (checked) {
                            setState(() {
                              if (checked == true) {
                                selectedValues.add(option);
                              } else {
                                selectedValues.remove(option);
                              }
                            });
                          },
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade700,
            ),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, selectedValues),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade800,
              backgroundColor: Colors.grey.shade200,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('Save'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      ),
    );
  }
}
