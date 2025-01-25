import 'package:flutter/material.dart';

import '../widgets/bottom_nav.dart';
import '../widgets/check_connection.dart';
import '../widgets/upload/UploadPopup.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardState();
}

class _DashboardState extends State<DashboardScreen> {

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
          bottomNavigationBar: const BottomNavBar(selectedIndex: 1),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFCF9F5), // Background color
          elevation: 0, // Remove shadow
          title: const Padding(
            padding: EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dashboard',
                  style: TextStyle(
                    color: Color(0xFF333333), // Text color
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            color: const Color(0xFFFCF9F5), // Background color
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildStorageCard(
                  title: 'Kids toys',
                  size: 'Size: 2.5 GB',
                  view: 'https://picdb.avianintek.workers.dev/2',
                  link: 'https://picdb.avianintek.workers.dev/2',
                ),
                const SizedBox(height: 16),
                _buildStorageCard(
                  title: 'Kids toys',
                  size: 'Size: 2.5 GB',
                  view: 'https://picdb.avianintek.workers.dev/2',
                  link: 'https://picdb.avianintek.workers.dev/2',
                ),
                const SizedBox(height: 16),
                _buildStorageCard(
                  title: 'Kids toys',
                  size: 'Size: 2.5 GB',
                  view: 'https://picdb.avianintek.workers.dev/2',
                  link: 'https://picdb.avianintek.workers.dev/2',
                ),
                const SizedBox(height: 16),
                _buildStorageCard(
                  title: 'Kids toys',
                  size: 'Size: 2.5 GB',
                  view: 'https://picdb.avianintek.workers.dev/2',
                  link: 'https://picdb.avianintek.workers.dev/2',
                ),
                const SizedBox(height: 16),
                _buildStorageCard(
                  title: 'Kids toys',
                  size: 'Size: 2.5 GB',
                  view: 'https://picdb.avianintek.workers.dev/2',
                  link: 'https://picdb.avianintek.workers.dev/2',
                ),
                const SizedBox(height: 16),
                _buildStorageCard(
                  title: 'Kids toys',
                  size: 'Size: 2.5 GB',
                  view: 'https://picdb.avianintek.workers.dev/2',
                  link: 'https://picdb.avianintek.workers.dev/2',
                ),
                const SizedBox(height: 16),
                _buildStorageCard(
                  title: 'Kids toys',
                  size: 'Size: 2.5 GB',
                  view: 'https://picdb.avianintek.workers.dev/2',
                  link: 'https://picdb.avianintek.workers.dev/2',
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
    required String link,
    Color color = Colors.white, // Default card color
    Color textColor = const Color(0xFF333333)
  }) {
    return GestureDetector(
      onTap: () {
        selectImage(title, link, view);
      },
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      RichText(
                          text: TextSpan(
                              style: TextStyle(
                                fontSize: 16,
                                color: textColor,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: size,
                                ),
                              ]
                          )
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Image.network(
                  link,
                  height: 100,
                  width: 100,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}