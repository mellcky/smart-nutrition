// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';

// class MedicalRecordsScreen extends StatelessWidget {
//   const MedicalRecordsScreen({super.key});

//   // Future<void> _pickFile(BuildContext context) async {
//   //   try {
//   //     FilePickerResult? result = await FilePicker.platform.pickFiles(
//   //       allowMultiple: false,
//   //       type: FileType.any,
//   //     );

//   //     if (result != null && result.files.isNotEmpty) {
//   //       String fileName = result.files.first.name;
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         SnackBar(
//   //           content: Text("File uploaded: $fileName"),
//   //           duration: const Duration(seconds: 2),
//   //         ),
//   //       );
//   //     } else {
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         const SnackBar(
//   //           content: Text("No file selected"),
//   //           duration: Duration(seconds: 2),
//   //         ),
//   //       );
//   //     }
//   //   } catch (e) {
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(
//   //         content: Text("Error uploading file: $e"),
//   //         duration: const Duration(seconds: 2),
//   //       ),
//   //     );
//   //   }
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Medical Records"),
//         centerTitle: true,
//         backgroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               "Step 7/7",
//               style: TextStyle(color: Colors.grey, fontSize: 14),
//             ),
//             const SizedBox(height: 16),
//             const Text(
//               "Connect Your medical records here for better recommendations",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               '"This is optional but helps us provide more personalized nutrition plans"',
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey,
//                 fontStyle: FontStyle.italic,
//               ),
//             ),
//             const SizedBox(height: 24),
//             GestureDetector(
//               onTap: () => _pickFile(context),
//               child: Container(
//                 padding: const EdgeInsets.all(16),
//                 margin: const EdgeInsets.only(bottom: 16),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Row(
//                   children: [
//                     const Icon(Icons.upload_file, color: Colors.grey),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: const [
//                           Text(
//                             "Upload Medical Documents 📎",
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           SizedBox(height: 4),
//                           Text(
//                             "Upload PDF's or images of your records",
//                             style: TextStyle(fontSize: 14, color: Colors.grey),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             GestureDetector(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => const ManualEntryScreen(),
//                   ),
//                 );
//               },
//               child: Container(
//                 padding: const EdgeInsets.all(16),
//                 margin: const EdgeInsets.only(bottom: 16),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Row(
//                   children: [
//                     const Icon(Icons.edit, color: Colors.grey),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: const [
//                           Text(
//                             "Enter details manually ✍️",
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           SizedBox(height: 4),
//                           Text(
//                             "Add your medical information yourself",
//                             style: TextStyle(fontSize: 14, color: Colors.grey),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const RecommendationScreen(),
//                     ),
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.green,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                 ),
//                 child: const Text(
//                   "CREATE RECOMMENDATION",
//                   style: TextStyle(fontSize: 16, color: Colors.white),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class ManualEntryScreen extends StatelessWidget {
//   const ManualEntryScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Enter Medical Details"),
//         centerTitle: true,
//         backgroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               "Enter your medical information",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               maxLines: 5,
//               decoration: InputDecoration(
//                 hintText: "Type your medical details here...",
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.green,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                 ),
//                 child: const Text(
//                   "SUBMIT",
//                   style: TextStyle(fontSize: 16, color: Colors.white),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class RecommendationScreen extends StatelessWidget {
//   const RecommendationScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Recommendation"),
//         centerTitle: true,
//         backgroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: const Center(
//         child: Text(
//           "Your personalized recommendations are ready!",
//           style: TextStyle(fontSize: 18),
//           textAlign: TextAlign.center,
//         ),
//       ),
//     );
//   }
// }
