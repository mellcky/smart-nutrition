import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Settings'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Account Settings Section
          const Text(
            'Account Settings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Name'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('Cressy', style: TextStyle(color: Colors.grey)),
                Icon(Icons.chevron_right),
              ],
            ),
            onTap: () {
              // Navigate to edit name screen (placeholder)
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Age'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('23', style: TextStyle(color: Colors.grey)),
                Icon(Icons.chevron_right),
              ],
            ),
            onTap: () {
              // Navigate to edit age screen (placeholder)
            },
          ),
          ListTile(
            leading: const Icon(Icons.wc),
            title: const Text('Gender'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('Female', style: TextStyle(color: Colors.grey)),
                Icon(Icons.chevron_right),
              ],
            ),
            onTap: () {
              // Navigate to edit gender screen (placeholder)
            },
          ),
          ListTile(
            leading: const Icon(Icons.height),
            title: const Text('Height'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('131 cm', style: TextStyle(color: Colors.grey)),
                Icon(Icons.chevron_right),
              ],
            ),
            onTap: () {
              // Navigate to edit height screen (placeholder)
            },
          ),
          ListTile(
            leading: const Icon(Icons.fitness_center),
            title: const Text('Weight'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('63.7', style: TextStyle(color: Colors.grey)),
                Icon(Icons.chevron_right),
              ],
            ),
            onTap: () {
              // Navigate to edit weight screen (placeholder)
            },
          ),
          const SizedBox(height: 16),
          // Diet Information Section
          const Text(
            'Diet Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.directions_run),
            title: const Text('Activity Level'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('Moderate Active', style: TextStyle(color: Colors.grey)),
                Icon(Icons.chevron_right),
              ],
            ),
            onTap: () {
              // Navigate to edit activity level screen (placeholder)
            },
          ),
          ListTile(
            leading: const Icon(Icons.warning),
            title: const Text('Restrictions'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('None', style: TextStyle(color: Colors.grey)),
                Icon(Icons.chevron_right),
              ],
            ),
            onTap: () {
              // Navigate to edit restrictions screen (placeholder)
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Health Conditions'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('None', style: TextStyle(color: Colors.grey)),
                Icon(Icons.chevron_right),
              ],
            ),
            onTap: () {
              // Navigate to edit health conditions screen (placeholder)
            },
          ),
          ListTile(
            leading: const Icon(Icons.medical_services),
            title: const Text('Medical History (optional)'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('None', style: TextStyle(color: Colors.grey)),
                Icon(Icons.chevron_right),
              ],
            ),
            onTap: () {
              // Navigate to edit medical history screen (placeholder)
            },
          ),
          ListTile(
            leading: const Icon(Icons.alarm),
            title: const Text('Reminders'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('None', style: TextStyle(color: Colors.grey)),
                Icon(Icons.chevron_right),
              ],
            ),
            onTap: () {
              // Navigate to edit reminders screen (placeholder)
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Handle update action (placeholder)
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Update'),
          ),
          const SizedBox(height: 16),
          // Application Section
          const Text(
            'Application',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.contact_support),
            title: const Text('Contact Us'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to contact us screen (placeholder)
            },
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              // Handle log out action (placeholder)
            },
            child: const Text('Log out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
