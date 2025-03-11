import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/bottom_nav.dart';
import '../widgets/check_connection.dart';
import '../widgets/upload/UploadPopup.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardState();
}

class _DashboardState extends State<DashboardScreen> {
  late SharedPreferences prefs;
  List<dynamic> images = [];
  bool loadedImage = false;

  @override
  void initState() {
    initPrefs();
    Future.delayed(const Duration(seconds: 2), () {
      initImages();
    });
    super.initState();
  }

  void initImages() async {
    var temp = prefs.getStringList("images") ?? [];
    images = temp.map((image) => jsonDecode(image)).toList();
    if (images.isEmpty) {
      await prefs.setStringList("images", []);
    }
    setState(() {
      loadedImage = true;
    });
  }

  void initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  void selectImage(title, link, view) {
    showDialog(
      context: context,
      builder: (context) => UploadPopup(
        imageUrl: link,
        imageName: title,
        viewUrl: view,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return ConnectivityWidget(
      child: Scaffold(
        backgroundColor: const Color(0xFFFCF9F5),
        bottomNavigationBar: const BottomNavBar(selectedIndex: 1),
        body: SingleChildScrollView(
          child: Container(
            // color: const Color(0xFFFCF9F5), // Background color
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 40,),
                images.isEmpty ?
                Center(
                  heightFactor: 2,
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      Lottie.asset(
                        './assets/lottie/search.json',
                        width: 250,
                        fit: BoxFit.fill,
                      ),
                    ],
                  ),
                ) : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    final image = images[index];
                    return Column(
                      children: [
                        _buildStorageCard(
                          title: image['title'],
                          size: image['size'],
                          view: image['view'],
                          link: image['link'],
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStorageCard({
    required String title,
    required String size,
    required String view,
    required String link
  }) {
    return GestureDetector(
      onTap: () {
        selectImage(title, link, view);
      },
      //   child: Container(
      //     padding: const EdgeInsets.all(30),
      //     decoration: BoxDecoration(
      //       color: color,
      //       borderRadius: BorderRadius.circular(12),
      //       boxShadow: [
      //         BoxShadow(
      //           color: Colors.grey.withOpacity(0.2),
      //           spreadRadius: 1,
      //           blurRadius: 5,
      //           offset: const Offset(0, 2),
      //         ),
      //       ],
      //     ),
      //     child: Column(
      //       crossAxisAlignment: CrossAxisAlignment.start,
      //       children: [
      //         Row(
      //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //           crossAxisAlignment: CrossAxisAlignment.start,
      //           children: [
      //             Expanded(
      //               child: Column(
      //                 crossAxisAlignment: CrossAxisAlignment.start,
      //                 children: [
      //                   const SizedBox(height: 10),
      //                   Text(
      //                     title,
      //                     style: TextStyle(
      //                       fontWeight: FontWeight.bold,
      //                       fontSize: 24,
      //                       color: textColor,
      //                     ),
      //                   ),
      //                   const SizedBox(height: 12),
      //                   RichText(
      //                       text: TextSpan(
      //                           style: TextStyle(
      //                             fontSize: 16,
      //                             color: textColor,
      //                           ),
      //                           children: <TextSpan>[
      //                             TextSpan(
      //                               text: size,
      //                             ),
      //                           ]
      //                       )
      //                   ),
      //                 ],
      //               ),
      //             ),
      //             const SizedBox(width: 20),
      //             Image.network(
      //               link,
      //               height: 100,
      //               width: 100,
      //             ),
      //           ],
      //         ),
      //       ],
      //     ),
      //   ),
      // );

      child: Container(
        width: 300, // Adjust width as needed
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFF0D1F2D), // Dark background color from the image
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Stack( // ADD STACK WIDGET
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ClipRRect(
                  //   borderRadius: BorderRadius.circular(20),
                  //   child: Image.network(
                  //     // Replace with your actual image URL
                  //     link,
                  //     height: 200,
                  //     width: double.infinity,
                  //     fit: BoxFit.cover,
                  //   ),
                  // ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2D1A9), // Pale orange from the image
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            title.split('.')[title.split('.').length-1].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8,),
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Size: $size',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Positioned(
              //   top: 10,
              //   left: 10,
              //   child: Container(
              //     padding:
              //     const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              //     decoration: BoxDecoration(
              //       color: const Color(0xFFF2D1A9), // Pale orange from the image
              //       borderRadius: BorderRadius.circular(10),
              //     ),
              //     child: Text(
              //       title.split('.')[title.split('.').length-1].toUpperCase(),
              //       style: const TextStyle(
              //         color: Colors.black87,
              //         fontWeight: FontWeight.bold,
              //       ),
              //     ),
              //   ),
              // ),
              Positioned(
                bottom: 10,
                right: 10,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDFF2B8), // Pale green from the image
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_outward_rounded,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}