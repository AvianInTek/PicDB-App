

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:picdb/widgets/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';
import '../services/api_service.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/check_connection.dart';
import '../widgets/upload/UploadPopup.dart';


// upload.dart
class UploadImage extends StatefulWidget {
  const UploadImage({super.key});

  @override
  _UploadImageState createState() => _UploadImageState();
}

class _UploadImageState extends State<UploadImage> with SingleTickerProviderStateMixin {
  late AnimationController loadingController;
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  List<dynamic> _results = [];
  bool lock = false;
  late SharedPreferences prefs;
  late List<dynamic> images;

  void initImages() async {
    var temp = prefs.getStringList("images") ?? [];
    images = temp.map((image) => jsonDecode(image)).toList();
    if (images.isEmpty) {
      await prefs.setStringList("images", []);
    }
  }

  void initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  void selectImage(result) {
    showDialog(
      context: context,
      builder: (context) => UploadPopup(
        imageUrl: result['link'],
        imageName: result['title'],
        viewUrl: result['view'],
      ),
    );
  }

  String getFileSizeString({required int bytes, int decimals = 2}) {
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (bytes == 0) ? 0 : (log(bytes) / log(1024)).floor();
    var size = bytes / pow(1024, i);
    return '${size.toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  Future<void> _selectImage() async {
    setState(() {
      lock = true;
    });
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      loadingController.forward();

      // Upload the image
      try {
        if (_imageFile!.lengthSync() > 65 * 1024 * 1024) {
          toaster(
            context,
            message: "File size exceeds 65MB!",
            type: ToastificationType.error,
            iconPath: 'assets/icons/error.svg',
            backgroundColor: Colors.red.shade700,
          );
          setState(() {
            lock = false;
          });
          return;
        }
        var result = await APIService().uploadFile(_imageFile!.path);

        if (result['success'] == true) {
          setState(() {
            _results.add(result);
            lock = false;
          });

          images.add(jsonEncode({
            "link": result['link'].toString(),
            "title": result['title'].toString(),
            "view": result['view'].toString(),
            "size": getFileSizeString(bytes: _imageFile!.lengthSync()).toString()
          }));
          await prefs.setStringList("images", images.map((image) => image.toString()).toList());

          toaster(
            context,
            message: "Upload was successful!",
            type: ToastificationType.success,
            iconPath: 'assets/icons/success.svg'
          );
        } else {
          toaster(
            context,
            message: result['message'],
            type: ToastificationType.error,
            iconPath: 'assets/icons/error.svg',
            backgroundColor: Colors.red.shade700, // Optional custom background
          );
        }
      } catch (e) {
        toaster(
          context,
          message: 'An error occured!',
          type: ToastificationType.error,
          iconPath: 'assets/icons/error.svg',
          backgroundColor: Colors.red.shade700, // Optional custom background
        );
      } finally {
        loadingController.reset();
      }
    }
  }

  @override
  void initState() {
    loadingController = AnimationController( vsync: this, duration: const Duration(seconds: 10))..addListener(() {
      setState(() {});
    });
    initPrefs();
    Future.delayed(const Duration(seconds: 2), () {
      initImages();
    });
    super.initState();
  }

  @override
  void dispose() {
    loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConnectivityWidget(
      child: Scaffold(
        bottomNavigationBar: const BottomNavBar(selectedIndex: 0),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              _imageFile == null || _results.isEmpty ?
              Column(
                children: [
                  const SizedBox(height: 40),
                  Lottie.asset(
                    './assets/lottie/upload.json',
                    width: 250,
                    fit: BoxFit.fill,
                  ),
                ],
              ): const SizedBox(height: 100),
              const SizedBox(height: 50),
              Text(
                'Upload your file',
                style: TextStyle(
                  fontSize: 25,
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'File should be jpg, png',
                style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: lock == false ? _selectImage: null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40.0,
                    vertical: 20.0,
                  ),
                  child: DottedBorder(
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(10),
                    dashPattern: const [10, 4],
                    strokeCap: StrokeCap.round,
                    color: Colors.blue.shade400,
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50.withOpacity(.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Lottie.asset(
                            './assets/lottie/drop_box.json',
                            width: 150,
                            fit: BoxFit.fill,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Select your file',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              _imageFile != null && lock == true
                  ? Container(
                padding: const EdgeInsets.all(40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected File',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade200,
                            offset: const Offset(0, 1),
                            blurRadius: 3,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _imageFile!,
                              width: 70,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _imageFile!.path.split('/').last,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '${(_imageFile!.lengthSync() / 1024).ceil()} KB',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Container(
                                  height: 8,
                                  clipBehavior: Clip.hardEdge,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.blue.shade50,
                                  ),
                                  child: LinearProgressIndicator(
                                    value: loadingController.value,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                      ),
                    ),
                    // const SizedBox(height: 20),
                  ],
                ),
              )
                  : Container(),
              _results.isNotEmpty ? Container(
                padding: const EdgeInsets.all(40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _results.map((result) {
                    return GestureDetector(
                      onTap: () => selectImage(result),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade200,
                              offset: const Offset(0, 1),
                              blurRadius: 3,
                              spreadRadius: 2,
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                result['link'],
                                width: 70,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    result['title'],
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    '${(result['size'] / 1024).ceil()} KB',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              )
                  : Container(),
              // const SizedBox(height: 150),
            ],
          ),
        ),
      ),
    );
  }
}