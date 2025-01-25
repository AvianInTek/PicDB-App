
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart';

class UploadPopup extends StatefulWidget {
  final String imageUrl;
  final String imageName;
  final String viewUrl;

  const UploadPopup({
    Key? key,
    required this.imageUrl,
    required this.imageName,
    required this.viewUrl,
  }) : super(key: key);

  @override
  _UploadPopupState createState() => _UploadPopupState();
}

class _UploadPopupState extends State<UploadPopup> {
  // By default, show the download content
  bool _showDownloadContent = true;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title and Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Title (Image Name and Type)
                Row(
                  children: [
                    Text(
                      widget.imageName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade400,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        "PNG",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                // Close Button
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Buttons (Download and View)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showDownloadContent = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text("Download"),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showDownloadContent = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade200,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text("View"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Conditional Content (Download or View)
            _showDownloadContent
                ? _buildDownloadContent(context)
                : _buildViewContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Image Download:",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text("This provides you a link to download the image."),
        const SizedBox(height: 16),
        const Text("Download link"),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.imageUrl,
                  style: TextStyle(color: Colors.blue.shade800),
                  overflow: TextOverflow.ellipsis, // Hide overflow with ellipsis
                  maxLines: 1, // Allow only one line
                ),
              ),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: widget.imageUrl));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Link copied to clipboard')),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Icon(Icons.copy, size: 20),
                ),
              ),
              const SizedBox(width: 5),
              GestureDetector(
                onTap: () async {
                  if (!await launchUrl(Uri.parse(widget.imageUrl))) {
                    throw 'Could not launch ${widget.imageUrl}';
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Icon(Icons.open_in_new, size: 20),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: QrImageView(
            data: widget.imageUrl,
            version: QrVersions.auto,
            size: 200.0,
          ),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text("Scan this code to download the image."),
        ),
      ],
    );
  }

  Widget _buildViewContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Image View:",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text("This provides you a link to view the image."),
        const SizedBox(height: 20),
        Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
            height: MediaQuery.of(context).size.width * 0.6,
            child: Image.network(
              widget.viewUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Text("Image failed to load"),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text("View link"),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.viewUrl,
                  style: TextStyle(color: Colors.blue.shade800),
                  overflow: TextOverflow.ellipsis, // Hide the overflow
                  maxLines: 1, // Only allow one line
                ),
              ),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: widget.viewUrl));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Link copied to clipboard')),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Icon(Icons.copy, size: 20),
                ),
              ),
              const SizedBox(width: 5),
              GestureDetector(
                onTap: () async {
                  if (!await launchUrl(Uri.parse(widget.viewUrl))) {
                    throw 'Could not launch ${widget.viewUrl}';
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Icon(Icons.open_in_new, size: 20),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}