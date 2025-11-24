import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/image_upload_service.dart';

class MultiImageCaptureScreen extends StatefulWidget {
  final String? reportId;
  final String? userId;
  final int maxImages;
  final VoidCallback? onComplete;

  const MultiImageCaptureScreen({
    super.key,
    this.reportId,
    this.userId,
    this.maxImages = 10,
    this.onComplete,
  });

  @override
  State<MultiImageCaptureScreen> createState() => _MultiImageCaptureScreenState();
}

class _MultiImageCaptureScreenState extends State<MultiImageCaptureScreen> {
  final List<File> _capturedImages = [];
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Capture Farm Images (${_capturedImages.length}/${widget.maxImages})',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [
          if (_capturedImages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _confirmImages,
              tooltip: 'Done',
            ),
        ],
      ),
      body: Column(
        children: [
          // Instructions Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              border: Border(
                bottom: BorderSide(color: Colors.blue.shade200),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Capture Multiple Angles',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '• Take 4-5 clear photos from different angles\n'
                  '• Include field boundaries and damage areas\n'
                  '• Photos will be compressed automatically\n'
                  '• Maximum ${widget.maxImages} images allowed',
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          // Image Grid
          Expanded(
            child: _capturedImages.isEmpty
                ? _buildEmptyState()
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1,
                    ),
                    itemCount: _capturedImages.length,
                    itemBuilder: (context, index) {
                      return _buildImageCard(_capturedImages[index], index);
                    },
                  ),
          ),

          // Action Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                children: [
                  if (_capturedImages.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildActionButton(
                              'Clear All',
                              Icons.delete_outline,
                              Colors.red.shade700,
                              _clearAll,
                              outlined: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildActionButton(
                              'Done (${_capturedImages.length})',
                              Icons.check_circle,
                              Colors.green.shade700,
                              _confirmImages,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          'Take Photo',
                          Icons.camera_alt,
                          Colors.blue.shade700,
                          _capturedImages.length < widget.maxImages
                              ? () => _captureImage()
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          'From Gallery',
                          Icons.photo_library,
                          Colors.purple.shade700,
                          _capturedImages.length < widget.maxImages
                              ? () => _pickFromGallery()
                              : null,
                          outlined: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Processing Overlay
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          'Compressing images...',
                          style: GoogleFonts.roboto(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_camera,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No Images Captured Yet',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap "Take Photo" to start',
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard(File image, int index) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(
            image,
            fit: BoxFit.cover,
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.visibility, color: Colors.white, size: 20),
                    onPressed: () => _previewImage(image),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.white, size: 20),
                    onPressed: () => _removeImage(index),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback? onPressed, {
    bool outlined = false,
  }) {
    return outlined
        ? OutlinedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 20),
            label: Text(label),
            style: OutlinedButton.styleFrom(
              foregroundColor: color,
              side: BorderSide(color: color),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          )
        : ElevatedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 20),
            label: Text(label),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              disabledBackgroundColor: Colors.grey.shade300,
            ),
          );
  }

  Future<void> _captureImage() async {
    if (_capturedImages.length >= widget.maxImages) {
      _showMaxImagesDialog();
      return;
    }

    final result = await context.push('/camera');
    
    if (result != null && result is String) {
      setState(() {
        _capturedImages.add(File(result));
      });
    }
  }

  Future<void> _pickFromGallery() async {
    if (_capturedImages.length >= widget.maxImages) {
      _showMaxImagesDialog();
      return;
    }

    // TODO: Implement gallery picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gallery picker coming soon')),
    );
  }

  void _removeImage(int index) {
    setState(() {
      _capturedImages.removeAt(index);
    });
  }

  void _clearAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Images?'),
        content: const Text('This will remove all captured images. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _capturedImages.clear();
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _previewImage(File image) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          body: Center(
            child: InteractiveViewer(
              child: Image.file(image),
            ),
          ),
          backgroundColor: Colors.black,
        ),
      ),
    );
  }

  void _showMaxImagesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Maximum Images Reached'),
        content: Text('You can only add up to ${widget.maxImages} images per report.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmImages() async {
    if (_capturedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please capture at least one image')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Images'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You have captured ${_capturedImages.length} image(s).'),
            const SizedBox(height: 12),
            Text(
              'Images will be compressed automatically to reduce upload time and server load.',
              style: GoogleFonts.roboto(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Recommended: 4-5 images from different angles',
                      style: GoogleFonts.roboto(
                        fontSize: 11,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Add More'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _processAndUploadImages();
    }
  }

  Future<void> _processAndUploadImages() async {
    setState(() => _isProcessing = true);

    try {
      final uploadService = context.read<ImageUploadService>();
      
      // Add images to upload queue (will compress automatically)
      final compressedPaths = await uploadService.addImagesToQueue(
        images: _capturedImages,
        reportId: widget.reportId ?? 'unknown',
        userId: widget.userId ?? 'unknown',
      );

      if (mounted) {
        setState(() => _isProcessing = false);
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${compressedPaths.length} images ready for upload'),
            backgroundColor: Colors.green.shade700,
          ),
        );

        // Call onComplete callback or pop
        if (widget.onComplete != null) {
          widget.onComplete!();
        } else {
          context.pop(compressedPaths);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing images: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }
}
