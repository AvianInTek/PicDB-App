import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:async';  // Add missing import for Completer
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:picdb/widgets/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';
import '../services/api_service.dart';
import 'package:flutter/material.dart'; // Add missing Flutter import
import 'package:permission_handler/permission_handler.dart'; // Add missing permission handler import
import 'package:flutter_animate/flutter_animate.dart'; // Add missing animate import

// Import widgets
import '../widgets/bottom_nav.dart';
import '../widgets/check_connection.dart';
import '../widgets/common/dialog_theme.dart';
import '../widgets/upload/UploadPopup.dart';
import '../widgets/common/dialog_widgets.dart'; // Import dialog widgets

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
  List<dynamic> images = [];
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String _currentFileName = '';
  List<XFile> _pendingUploads = [];
  bool _isCancelled = false;

  Future<bool> _requestPermissions(ImageSource source) async {
    if (Platform.isAndroid) {
      PermissionStatus status;

      if (source == ImageSource.camera) {
        status = await Permission.camera.status;
        if (status.isDenied || status.isPermanentlyDenied) {
          final result = await Permission.camera.request();
          if (!result.isGranted) {
            if (!mounted) return false;
            toaster(
              context,
              message: 'Camera permission is required. Please enable it in Settings.',
              type: ToastificationType.error,
              iconPath: 'assets/icons/error.svg',
              backgroundColor: Colors.red.shade700,
            );
            await openAppSettings();
            return false;
          }
        }
      }

      // Check for photos permission (Android 13+)
      status = await Permission.photos.status;
      if (status.isDenied || status.isPermanentlyDenied) {
        final result = await Permission.photos.request();
        if (!result.isGranted) {
          // Try storage permission for Android 12 and below
          status = await Permission.storage.status;
          if (status.isDenied || status.isPermanentlyDenied) {
            final storageResult = await Permission.storage.request();
            if (!storageResult.isGranted) {
              if (!mounted) return false;
              toaster(
                context,
                message: 'Storage permission is required. Please enable it in Settings.',
                type: ToastificationType.error,
                iconPath: 'assets/icons/error.svg',
                backgroundColor: Colors.red.shade700,
              );
              await openAppSettings();
              return false;
            }
          }
        }
      }
      return true;
    }
    return true;
  }

  void _showPermissionDeniedDialog() {
    AppDialogs.showPermissionDeniedDialog(
      context: context,
      content: 'This app needs access to your storage and camera to function properly.',
      onOpenSettings: () async {
        await openAppSettings();
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    if (!mounted) return;

    try {
      // First request permissions
      if (!await _requestPermissions(source)) {
        return;
      }

      // Set loading state
      setState(() {
        lock = true;
      });

      // Pick image
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      // Handle no image selected
      if (pickedFile == null) {
        if (mounted) {
          setState(() {
            lock = false;
          });
        }
        return;
      }

      if (!mounted) return;

      // Update state with selected image
      setState(() {
        _imageFile = File(pickedFile.path);
        _currentFileName = pickedFile.name;
      });

      // Process upload
      await _processUpload();
    } catch (e) {
      print('Image picking error: $e');
      if (!mounted) return;

      setState(() {
        lock = false;
      });

      // Show specific error message
      String errorMessage = 'Could not select image. Please try again.';
      if (e.toString().contains('permission')) {
        errorMessage = 'Permission denied. Please grant access in Settings.';
      }

      toaster(
        context,
        message: errorMessage,
        type: ToastificationType.error,
        iconPath: 'assets/icons/error.svg',
        backgroundColor: Colors.red.shade700,
      );
    }
  }

  Future<void> _pickMultipleImages() async {
    if (!mounted) return;

    try {
      if (!await _requestPermissions(ImageSource.gallery)) {
        return;
      }

      final List<XFile> selectedImages = await _picker.pickMultiImage();

      if (selectedImages.isEmpty) return;

      setState(() {
        _pendingUploads = selectedImages;
        lock = true;
      });

      _processNextUpload();
    } catch (e) {
      print('Image picking error: $e');
      if (!mounted) return;

      setState(() {
        lock = false;
      });

      String errorMessage = 'Could not select images. Please try again.';
      if (e.toString().contains('permission')) {
        errorMessage = 'Permission denied. Please grant access in Settings.';
      }

      toaster(
        context,
        message: errorMessage,
        type: ToastificationType.error,
        iconPath: 'assets/icons/error.svg',
        backgroundColor: Colors.red.shade700,
      );
    }
  }

  Future<void> _processNextUpload() async {
    if (_pendingUploads.isEmpty || _isCancelled) {
      setState(() {
        lock = false;
        _isCancelled = false;
      });
      return;
    }

    final currentFile = _pendingUploads.first;
    setState(() {
      _currentFileName = currentFile.name;
      _imageFile = File(currentFile.path);
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    await _processUpload();

    if (!_isCancelled) {
      setState(() {
        _pendingUploads.removeAt(0);
      });
      _processNextUpload();
    }
  }

  void _cancelUpload() {
    setState(() {
      _isCancelled = true;
      if (_pendingUploads.isNotEmpty) {
        // Remove only the current upload
        _pendingUploads.removeAt(0);
      }
      _isUploading = false;
      _uploadProgress = 0.0;
    });
    loadingController.reset();

    toaster(
      context,
      message: "Upload cancelled",
      type: ToastificationType.warning,
      iconPath: 'assets/icons/error.svg',
      backgroundColor: Colors.orange.shade700,
    );

    // Allow a brief moment for the current upload to finish cancellation
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isCancelled = false;
          // Only release the lock if there are no more pending uploads
          if (_pendingUploads.isEmpty) {
            lock = false;
          } else {
            // Process the next upload
            _processNextUpload();
          }
        });
      }
    });
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Select Images',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSourceOption(
                      icon: Icons.photo_library,
                      label: 'Gallery',
                      onTap: () {
                        Navigator.pop(context);
                        _pickMultipleImages();
                      },
                    ),
                    _buildSourceOption(
                      icon: Icons.camera_alt,
                      label: 'Camera',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: Colors.blue.shade700),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void selectImage(result) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDialogTheme.borderRadius)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        child: AppDialogTheme.animatedDialogBuilder(
          context,
          UploadPopup(
            imageUrl: result['link'],
            imageName: result['title'],
            viewUrl: result['view'],
          ),
        ),
      ),
    );
  }

  String getFileSizeString({required int bytes, int decimals = 2}) {
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (bytes == 0) ? 0 : (log(bytes) / log(1024)).floor();
    var size = bytes / pow(1024, i);
    return '${size.toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  Future<void> _processUpload() async {
    if (_imageFile == null) {
      setState(() {
        lock = false;
      });
      return;
    }

    try {
      setState(() {
        _isUploading = true;
        _uploadProgress = 0.0;
      });

      // Check for cancellation at the beginning
      if (_isCancelled) return;

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
          _isUploading = false;
        });
        return;
      }

      // Simulate upload progress
      loadingController.forward();
      loadingController.addListener(() {
        if (mounted && !_isCancelled) {
          setState(() {
            _uploadProgress = loadingController.value;
          });
        }
      });

      // Check for cancellation before starting network request
      if (_isCancelled) {
        loadingController.reset();
        return;
      }

      // Wrap the API call with a check that allows cancellation during the upload
      final uploadCompleter = Completer<Map<String, dynamic>>();

      // Start upload in a separate isolate/thread
      Future<Map<String, dynamic>> uploadFuture = APIService().uploadFile(_imageFile!.path);
      // Listen for cancellation while upload is in progress
      bool wasCancelled = false;
      final cancelCheckTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (_isCancelled) {
          wasCancelled = true;
          timer.cancel();
          if (!uploadCompleter.isCompleted) {
            uploadCompleter.complete({'success': false, 'cancelled': true});
          }
        }
      });
      // Set up the actual upload
      uploadFuture.then((result) {
        if (!uploadCompleter.isCompleted) {
          uploadCompleter.complete(result);
        }
        cancelCheckTimer.cancel();
      }).catchError((error) {
        if (!uploadCompleter.isCompleted) {
          uploadCompleter.completeError(error);
        }
        cancelCheckTimer.cancel();
      });
      // Wait for either completion or cancellation
      final result = await uploadCompleter.future;
      // Check if upload was cancelled or component is no longer mounted
      if (!mounted || _isCancelled || wasCancelled || result['cancelled'] == true) {
        return;
      }
      if (result['success'] == true) {
        setState(() {
          _results.add(result);
          images.add(jsonEncode({
            "link": result['link'].toString(),
            "title": result['title'].toString(),
            "view": result['view'].toString(),
            "size": getFileSizeString(bytes: _imageFile!.lengthSync()).toString()
          }));
        });
        await prefs.setStringList("images", images.map((image) => image.toString()).toList());
        if (_pendingUploads.length > 1) {
          toaster(
            context,
            message: "Image uploaded successfully! ${_pendingUploads.length - 1} remaining...",
            type: ToastificationType.success,
            iconPath: 'assets/icons/success.svg'
          );
        } else {
          toaster(
            context,
            message: "Upload successful!",
            type: ToastificationType.success,
            iconPath: 'assets/icons/success.svg'
          );
        }
      } else {
        if (!_isCancelled && result['cancelled'] != true) {
          toaster(
            context,
            message: result['message'] ?? 'Upload failed',
            type: ToastificationType.error,
            iconPath: 'assets/icons/error.svg',
            backgroundColor: Colors.red.shade700,
          );
        }
      }
    } catch (e) {
      print('Upload error: $e');
      if (!mounted || _isCancelled) return;
      toaster(
        context,
        message: 'Upload failed. Please try again.',
        type: ToastificationType.error,
        iconPath: 'assets/icons/error.svg',
        backgroundColor: Colors.red.shade700,
      );
    } finally {
      if (mounted && !_isCancelled) {
        setState(() {
          _isUploading = false;
          _uploadProgress = 0.0;
        });
      }
      loadingController.reset();
    }
  }

  Widget _buildAnimatedContainer(Widget child, {int delay = 0}) {
    return Container(
      child: child,
    ).animate()
      .fadeIn(
        duration: const Duration(milliseconds: 600),
        delay: Duration(milliseconds: delay),
      )
      .slideY(begin: 0.2);
  }

  Widget _buildUploadProgress() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            offset: const Offset(0, 2),
            blurRadius: 6,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.cloud_upload,
                  color: Colors.blue.shade700,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Uploading',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        if (_pendingUploads.length > 1)
                          Expanded(
                            child: Text(
                              ' (${_pendingUploads.length} remaining)',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currentFileName,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.cancel, color: Colors.red, size: 22),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: _cancelUpload,
                tooltip: 'Cancel Upload',
              ),
              const SizedBox(width: 4),
              SizedBox(
                width: 45,
                child: Text(
                  '${(_uploadProgress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade700,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: _uploadProgress,
              backgroundColor: Colors.blue.shade50,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.blue.shade400,
              ),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConnectivityWidget(
      child: Scaffold(
        bottomNavigationBar: const BottomNavBar(selectedIndex: 0),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade50, Colors.white],
            ),
          ),
          child: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAnimatedContainer(
                          Text(
                            'Upload Image',
                            style: TextStyle(
                              fontSize: 32,
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildAnimatedContainer(
                          Text(
                            'Share your moments with the world',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          delay: 200,
                        ),
                      ],
                    ),
                  ),
                ),
                if (!_isUploading && _results.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: GestureDetector(
                        onTap: _showImageSourceDialog,
                        child: DottedBorder(
                          borderType: BorderType.RRect,
                          radius: const Radius.circular(20),
                          dashPattern: const [10, 4],
                          strokeCap: StrokeCap.round,
                          color: Colors.blue.shade400,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                Lottie.asset(
                                  './assets/lottie/upload.json',
                                  width: 150,
                                  height: 150,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Tap to upload images',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Select multiple images • Max: 65MB each',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ).animate()
                        .fadeIn(delay: 400.ms, duration: 600.ms)
                        .slideY(begin: 0.2),
                    ),
                  ),

                if (_isUploading)
                  SliverToBoxAdapter(
                    child: _buildUploadProgress().animate()
                      .fadeIn(duration: 300.ms)
                      .slideY(begin: 0.2),
                  ),

                if (_results.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Uploads',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _showImageSourceDialog,
                            icon: Icon(Icons.add, color: Colors.blue.shade700),
                            label: Text(
                              'Upload More',
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (_results.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final result = _results[index];
                          return GestureDetector(
                            onTap: () => selectImage(result),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade200,
                                    offset: const Offset(0, 4),
                                    blurRadius: 8,
                                  )
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                    child: AspectRatio(
                                      aspectRatio: 16 / 9,
                                      child: Hero(
                                        tag: 'image_${result['link']}',
                                        child: Image.network(
                                          result['link'],
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return Container(
                                              color: Colors.grey.shade100,
                                              child: Center(
                                                child: CircularProgressIndicator(
                                                  value: loadingProgress.expectedTotalBytes != null
                                                      ? loadingProgress.cumulativeBytesLoaded /
                                                          loadingProgress.expectedTotalBytes!
                                                      : null,
                                                  valueColor: AlwaysStoppedAnimation<Color>(
                                                    Colors.blue.shade200,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                result['title'],
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.link,
                                                    size: 14,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      result['view'],
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey.shade600,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.share),
                                          onPressed: () {
                                            // Implement share functionality
                                          },
                                          tooltip: 'Share Image',
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ).animate()
                            .fadeIn(delay: (100 * index).ms, duration: 400.ms)
                            .slideX(begin: 0.2);
                        },
                        childCount: _results.length,
                      ),
                    ),
                  ),
              ].animate(interval: const Duration(milliseconds: 50)),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    loadingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addListener(() {
        setState(() {});
      });
    initPrefs();
    Future.delayed(const Duration(seconds: 2), initImages);
  }

  @override
  void dispose() {
    loadingController.dispose();
    super.dispose();
  }

  Future<void> initImages() async {
    var temp = prefs.getStringList("images") ?? [];
    List<dynamic> validImages = [];

    for (String imageString in temp) {
      try {
        // Try to parse as JSON first
        var decodedImage = jsonDecode(imageString);
        // Add timestamp if it doesn't exist (for sorting)
        if (decodedImage['timestamp'] == null) {
          decodedImage['timestamp'] = DateTime.now().millisecondsSinceEpoch;
        }
        validImages.add(decodedImage);
      } catch (e) {
        // Skip malformed JSON entries and clean them up
        print('Error decoding image data: $e');
        print('Malformed data: $imageString');

        // Try to extract data from malformed string if it follows a pattern
        try {
          if (imageString.contains('link:') && imageString.contains('title:')) {
            // Parse malformed data that looks like: {link: url, title: name, ...}
            final linkMatch = RegExp(r'link:\s*([^,}]+)').firstMatch(imageString);
            final titleMatch = RegExp(r'title:\s*([^,}]+)').firstMatch(imageString);
            final viewMatch = RegExp(r'view:\s*([^,}]+)').firstMatch(imageString);
            final sizeMatch = RegExp(r'size:\s*([^,}]+)').firstMatch(imageString);

            if (linkMatch != null && titleMatch != null) {
              final recoveredImage = {
                'link': linkMatch.group(1)?.trim() ?? '',
                'title': titleMatch.group(1)?.trim() ?? '',
                'view': viewMatch?.group(1)?.trim() ?? '',
                'size': sizeMatch?.group(1)?.trim() ?? '0 KB',
                'timestamp': DateTime.now().millisecondsSinceEpoch,
              };
              validImages.add(recoveredImage);
            }
          }
        } catch (parseError) {
          print('Could not recover malformed data: $parseError');
        }
      }
    }

    // Sort images by timestamp (oldest first)
    validImages.sort((a, b) {
      final aTime = a['timestamp'] ?? 0;
      final bTime = b['timestamp'] ?? 0;
      return aTime.compareTo(bTime);
    });

    setState(() {
      images = validImages;
    });

    // Clean up SharedPreferences by saving only valid data
    List<String> validEncodedImages = images.map((image) => jsonEncode(image)).toList();
    await prefs.setStringList("images", validEncodedImages);

    if (images.isEmpty) {
      await prefs.setStringList("images", []);
    }
  }

  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }
}
