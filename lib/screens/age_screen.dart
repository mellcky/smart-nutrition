// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '/providers/on_boarding_provider.dart';
// import '/providers/userprofile_provider.dart';
// import '/widgets/progress_bar.dart';
// import '/widgets/back_button_wrapper.dart';
// import '/screens/bodymeasurement_screen.dart';

// class AgeInputPage extends StatefulWidget {
//   const AgeInputPage({super.key});

//   @override
//   State<AgeInputPage> createState() => _AgeInputPageState();
// }

// class _AgeInputPageState extends State<AgeInputPage> {
//   final TextEditingController _ageController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     // Pre-fill if needed in future
//   }

//   @override
//   Widget build(BuildContext context) {
//     final onboardingProvider = Provider.of<OnboardingProvider>(context);
//     onboardingProvider.setProgress(0.3);

//     return Scaffold(
//       appBar: AppBar(toolbarHeight: 0, automaticallyImplyLeading: false),
//       // backgroundColor: Colors.white,
//       body: Column(
//         children: [
//           TopProgressBar(),
//           BackIconWrapper(),
//           SizedBox(
//             width: double.infinity,
//             height: 130,
//             child: Stack(
//               clipBehavior: Clip.none,
//               alignment: Alignment.center,
//               children: [
//                 Positioned(
//                   top: -50,
//                   child: CircleAvatar(
//                     radius: 50,
//                     backgroundImage: AssetImage('assets/images/app_logo.jpg'),
//                     backgroundColor: Colors.transparent,
//                   ),
//                 ),
//                 Positioned(
//                   top: 60,
//                   child: const Text(
//                     "Basic Information",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 40),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: const [
//               Icon(Icons.cake, color: Color.fromARGB(255, 18, 18, 18)),
//               SizedBox(width: 8),
//               Text(
//                 "What’s your age?",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
//               ),
//             ],
//           ),
//           const SizedBox(height: 32),
//           Center(
//             child: SizedBox(
//               width: 150,
//               child: TextField(
//                 controller: _ageController,
//                 textAlign: TextAlign.center,
//                 keyboardType: TextInputType.number,
//                 decoration: InputDecoration(
//                   hintText: "Enter your age",
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           Spacer(),
//           Padding(
//             padding: const EdgeInsets.only(bottom: 50),
//             child: ElevatedButton(
//               onPressed: () {
//                 final ageText = _ageController.text.trim();
//                 final age = int.tryParse(ageText);

//                 if (age != null && age > 0) {
//                   final profileProvider = Provider.of<UserProfileProvider>(
//                     context,
//                     listen: false,
//                   );
//                   profileProvider.updateAge(age);

//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => BodyMeasurementScreen(),
//                     ),
//                   );
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text("Please enter a valid age")),
//                   );
//                 }
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green,
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 40,
//                   vertical: 12,
//                 ),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               child: const Text(
//                 "Continue",
//                 style: TextStyle(fontSize: 16, color: Colors.white),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/progress_provider.dart';
import '/providers/userprofile_provider.dart';
import '/widgets/progress_bar.dart';
import '/screens/bodymeasurement_screen.dart';

class AgeInputPage extends StatefulWidget {
  const AgeInputPage({super.key});

  @override
  State<AgeInputPage> createState() => _AgeInputPageState();
}

class _AgeInputPageState extends State<AgeInputPage> {
  int _selectedAge = 25;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar at the very top
            TopProgressBar(),

            // Header with back button and centered logo
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Centered logo
                  const CircleAvatar(
                    radius: 70,
                    backgroundImage: AssetImage('assets/images/app_logo.jpg'),
                    backgroundColor: Colors.transparent,
                  ),
                ],
              ),
            ),

            const Text(
              "Basic Information",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cake),
                SizedBox(width: 8),
                Text(
                  "What's your age?",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Center(
              child: Container(
                width: 150, // Reduced width
                height: 250,
                decoration: BoxDecoration(
                  // Cyan background with slight transparency
                  borderRadius: BorderRadius.circular(
                    12,
                  ), // Optional: rounded corners
                ),
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: _selectedAge - 1,
                  ),
                  itemExtent: 40,
                  onSelectedItemChanged: (index) {
                    setState(() {
                      _selectedAge = index + 1;
                    });
                  },
                  children: List.generate(
                    100,
                    (index) => Center(
                      child: Text(
                        "${index + 1}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: ElevatedButton(
                onPressed: () {
                  Provider.of<UserProfileProvider>(
                    context,
                    listen: false,
                  ).updateAge(_selectedAge);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BodyMeasurementScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Continue",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
