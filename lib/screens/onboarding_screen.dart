// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../onboardingprovider/onboardingclass.dart';
// import '/screens/welcome_screen.dart';
// import '/screens/gender_screen.dart';

// class OnboardingScreen extends StatefulWidget {
//   @override
//   _OnboardingScreenState createState() => _OnboardingScreenState();
// }

// class _OnboardingScreenState extends State<OnboardingScreen> {
//   late PageController _pageController;

//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController();
//     // Add listener to sync PageView with OnboardingState
//     final onboardingState = Provider.of<OnboardingState>(
//       context,
//       listen: false,
//     );
//     onboardingState.addListener(() {
//       _pageController.animateToPage(
//         onboardingState.currentStep,
//         duration: Duration(milliseconds: 300),
//         curve: Curves.ease,
//       );
//     });
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: PageView(
//         controller: _pageController,
//         onPageChanged: (index) {
//           // Update state when user swipes
//           Provider.of<OnboardingState>(
//             context,
//             listen: false,
//           ).setCurrentStep(index);
//         },
//         children: [
//           WelcomePage(
//             onContinue: () {
//               _pageController.nextPage(
//                 duration: Duration(milliseconds: 300),
//                 curve: Curves.easeInOut,
//               );
//             },
//           ),
//           GenderSelectionPage(),
//           // Add more pages here as needed
//         ],
//       ),
//     );
//   }
// }
