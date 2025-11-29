import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../../../services/connectivity_service.dart';
import '../../../services/local_storage_service.dart';
import '../../../services/storage_service.dart';
import 'dart:convert';

enum UploadStatus {
  pending,
  uploading,
  completed,
  failed,
  offline,
}

class ImageUploadItem {
  final String id;
  final String localPath;
  final String? remotePath;
  final UploadStatus status;
  final double? latitude;
  final double? longitude;
  final DateTime capturedAt;
  final String? errorMessage;
  final double uploadProgress;

  ImageUploadItem({
    required this.id,
    required this.localPath,
    this.remotePath,
    required this.status,
    this.latitude,
    this.longitude,
    required this.capturedAt,
    this.errorMessage,
    this.uploadProgress = 0.0,
  });

  ImageUploadItem copyWith({
    String? remotePath,
    UploadStatus? status,
    String? errorMessage,
    double? uploadProgress,
  }) {
    return ImageUploadItem(
      id: id,
      localPath: localPath,
      remotePath: remotePath ?? this.remotePath,
      status: status ?? this.status,
      latitude: latitude,
      longitude: longitude,
      capturedAt: capturedAt,
      errorMessage: errorMessage ?? this.errorMessage,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'localPath': localPath,
      'remotePath': remotePath,
      'status': status.toString(),
      'latitude': latitude,
      'longitude': longitude,
      'capturedAt': capturedAt.toIso8601String(),
      'errorMessage': errorMessage,
      'uploadProgress': uploadProgress,
    };
  }

  factory ImageUploadItem.fromJson(Map<String, dynamic> json) {
    return ImageUploadItem(
      id: json['id'],
      localPath: json['localPath'],
      remotePath: json['remotePath'],
      status: UploadStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => UploadStatus.pending,
      ),
      latitude: json['latitude'],
      longitude: json['longitude'],
      capturedAt: DateTime.parse(json['capturedAt']),
      errorMessage: json['errorMessage'],
      uploadProgress: json['uploadProgress'] ?? 0.0,
    );
  }
}

class EnhancedBatchUploadScreen extends StatefulWidget {
  const EnhancedBatchUploadScreen({super.key});

  @override
  State<EnhancedBatchUploadScreen> createState() => _EnhancedBatchUploadScreenState();
}

class _EnhancedBatchUploadScreenState extends State<EnhancedBatchUploadScreen> {
  final ImagePicker _picker = ImagePicker();
  final LocalStorageService _localStorage = LocalStorageService();
  final StorageService _storageService = StorageService();
  List<ImageUploadItem> _uploadQueue = [];
  bool _isUploading = false;
  bool _isLoadingFromStorage = true;

  @override
  void initState() {
    super.initState();
    _loadSavedQueue();
    _setupConnectivityListener();
  }

  Future<void> _loadSavedQueue() async {
    try {
      final savedData = await _localStorage.getData('upload_queue');
      if (savedData != null && savedData is String) {
        final List<dynamic> jsonList = json.decode(savedData);
        setState(() {
          _uploadQueue = jsonList.map((json) => ImageUploadItem.fromJson(json)).toList();
          _isLoadingFromStorage = false;
        });
      } else {
        setState(() {
          _isLoadingFromStorage = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingFromStorage = false;
      });
    }
  }

  Future<void> _saveQueue() async {
    try {
      final jsonList = _uploadQueue.map((item) => item.toJson()).toList();
      await _localStorage.saveData('upload_queue', json.encode(jsonList));
    } catch (e) {
      debugPrint('Error saving queue: $e');
    }
  }

  void _setupConnectivityListener() {
    // Listen for connectivity changes
    final connectivityService = Provider.of<ConnectivityService>(context, listen: false);
    connectivityService.addListener(() {
      if (connectivityService.isOnline && !_isUploading) {
        _retryFailedUploads();
      }
    });
  }

  Future<void> _retryFailedUploads() async {
    final pendingItems = _uploadQueue.where(
      (item) => item.status == UploadStatus.pending || 
                item.status == UploadStatus.failed ||
                item.status == UploadStatus.offline
    ).toList();

    if (pendingItems.isNotEmpty) {
      await _uploadPendingImages();
    }
  }

  Future<Position?> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      debugPrint('Location error: $e');
      return null;
    }
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      
      if (images.isEmpty) return;

      final position = await _getCurrentLocation();
      final connectivityService = Provider.of<ConnectivityService>(context, listen: false);

      setState(() {
        for (var image in images) {
          final item = ImageUploadItem(
            id: DateTime.now().millisecondsSinceEpoch.toString() + images.indexOf(image).toString(),
            localPath: image.path,
            status: connectivityService.isOnline ? UploadStatus.pending : UploadStatus.offline,
            latitude: position?.latitude,
            longitude: position?.longitude,
            capturedAt: DateTime.now(),
          );
          _uploadQueue.add(item);
        }
      });

      await _saveQueue();

      if (connectivityService.isOnline) {
        _uploadPendingImages();
      } else {
        _showSnackBar('📥 ${images.length} फोटो ऑफलाइन सहेजी गई। ऑनलाइन होने पर अपलोड होगी।', Colors.orange);
      }
    } catch (e) {
      _showSnackBar('फोटो चुनने में त्रुटि: $e', Colors.red);
    }
  }

  Future<void> _captureImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      
      if (image == null) return;

      final position = await _getCurrentLocation();
      final connectivityService = Provider.of<ConnectivityService>(context, listen: false);

      setState(() {
        final item = ImageUploadItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          localPath: image.path,
          status: connectivityService.isOnline ? UploadStatus.pending : UploadStatus.offline,
          latitude: position?.latitude,
          longitude: position?.longitude,
          capturedAt: DateTime.now(),
        );
        _uploadQueue.add(item);
      });

      await _saveQueue();

      if (connectivityService.isOnline) {
        _uploadPendingImages();
      } else {
        _showSnackBar('📷 फोटो ऑफलाइन सहेजी गई। GPS: ${position != null ? "✓" : "✗"}', Colors.orange);
      }
    } catch (e) {
      _showSnackBar('कैमरा एरर: $e', Colors.red);
    }
  }

  Future<void> _uploadPendingImages() async {
    if (_isUploading) return;

    setState(() {
      _isUploading = true;
    });

    final pendingItems = _uploadQueue.where(
      (item) => item.status == UploadStatus.pending || 
                item.status == UploadStatus.failed ||
                item.status == UploadStatus.offline
    ).toList();

    for (var item in pendingItems) {
      await _uploadSingleImage(item);
    }

    setState(() {
      _isUploading = false;
    });

    await _saveQueue();
  }

  Future<void> _uploadSingleImage(ImageUploadItem item) async {
    try {
      final connectivityService = Provider.of<ConnectivityService>(context, listen: false);
      
      if (!connectivityService.isOnline) {
        setState(() {
          final index = _uploadQueue.indexOf(item);
          _uploadQueue[index] = item.copyWith(status: UploadStatus.offline);
        });
        return;
      }

      setState(() {
        final index = _uploadQueue.indexOf(item);
        _uploadQueue[index] = item.copyWith(
          status: UploadStatus.uploading,
          uploadProgress: 0.0,
        );
      });

      // Simulate upload with progress
      for (int i = 0; i <= 100; i += 20) {
        await Future.delayed(const Duration(milliseconds: 200));
        setState(() {
          final index = _uploadQueue.indexOf(item);
          if (index != -1) {
            _uploadQueue[index] = _uploadQueue[index].copyWith(
              uploadProgress: i / 100,
            );
          }
        });
      }

      // Upload to Firebase Storage
      final file = File(item.localPath);
      final fileName = path.basename(item.localPath);
      final remotePath = 'crop_images/${DateTime.now().millisecondsSinceEpoch}_$fileName';

      await _storageService.uploadFile(file, remotePath);

      setState(() {
        final index = _uploadQueue.indexOf(item);
        _uploadQueue[index] = item.copyWith(
          status: UploadStatus.completed,
          remotePath: remotePath,
          uploadProgress: 1.0,
        );
      });

      _showSnackBar('✓ फोटो अपलोड हो गई', Colors.green);
    } catch (e) {
      setState(() {
        final index = _uploadQueue.indexOf(item);
        _uploadQueue[index] = item.copyWith(
          status: UploadStatus.failed,
          errorMessage: e.toString(),
        );
      });
      _showSnackBar('❌ अपलोड विफल: ${e.toString()}', Colors.red);
    }
  }

  Future<void> _retryUpload(ImageUploadItem item) async {
    setState(() {
      final index = _uploadQueue.indexOf(item);
      _uploadQueue[index] = item.copyWith(status: UploadStatus.pending);
    });
    await _uploadSingleImage(item);
    await _saveQueue();
  }

  Future<void> _removeItem(ImageUploadItem item) async {
    setState(() {
      _uploadQueue.remove(item);
    });
    await _saveQueue();
    
    // Delete local file
    try {
      final file = File(item.localPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error deleting file: $e');
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.notoSansDevanagari()),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Color _getStatusColor(UploadStatus status) {
    switch (status) {
      case UploadStatus.completed:
        return const Color(0xFF2E7D32);
      case UploadStatus.uploading:
        return const Color(0xFF0277BD);
      case UploadStatus.pending:
        return const Color(0xFFF57C00);
      case UploadStatus.offline:
        return const Color(0xFF616161);
      case UploadStatus.failed:
        return const Color(0xFFC62828);
    }
  }

  String _getStatusText(UploadStatus status) {
    switch (status) {
      case UploadStatus.completed:
        return 'अपलोड हो गई ✓';
      case UploadStatus.uploading:
        return 'अपलोड हो रही है...';
      case UploadStatus.pending:
        return 'लंबित';
      case UploadStatus.offline:
        return 'ऑफलाइन सहेजी';
      case UploadStatus.failed:
        return 'विफल ❌';
    }
  }

  IconData _getStatusIcon(UploadStatus status) {
    switch (status) {
      case UploadStatus.completed:
        return Icons.check_circle;
      case UploadStatus.uploading:
        return Icons.cloud_upload;
      case UploadStatus.pending:
        return Icons.hourglass_empty;
      case UploadStatus.offline:
        return Icons.cloud_off;
      case UploadStatus.failed:
        return Icons.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectivityService = Provider.of<ConnectivityService>(context);
    
    final completedCount = _uploadQueue.where((i) => i.status == UploadStatus.completed).length;
    final pendingCount = _uploadQueue.where((i) => 
      i.status == UploadStatus.pending || i.status == UploadStatus.offline
    ).length;
    final failedCount = _uploadQueue.where((i) => i.status == UploadStatus.failed).length;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Text(
          'बैच फोटो अपलोड',
          style: GoogleFonts.notoSansDevanagari(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1B5E20),
        elevation: 2,
        actions: [
          if (!connectivityService.isOnline)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.cloud_off, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'ऑफलाइन',
                        style: GoogleFonts.notoSansDevanagari(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _isLoadingFromStorage
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Stats Cards
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'कुल',
                          _uploadQueue.length.toString(),
                          Icons.photo_library,
                          const Color(0xFF1565C0),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'पूर्ण',
                          completedCount.toString(),
                          Icons.check_circle,
                          const Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'लंबित',
                          pendingCount.toString(),
                          Icons.pending,
                          const Color(0xFFF57C00),
                        ),
                      ),
                      if (failedCount > 0) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'विफल',
                            failedCount.toString(),
                            Icons.error,
                            const Color(0xFFC62828),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Upload List
                Expanded(
                  child: _uploadQueue.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.photo_library_outlined,
                                size: 80,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'कोई फोटो नहीं',
                                style: GoogleFonts.notoSansDevanagari(
                                  fontSize: 18,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'फोटो जोड़ने के लिए नीचे बटन दबाएं',
                                style: GoogleFonts.notoSansDevanagari(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _uploadQueue.length,
                          itemBuilder: (context, index) {
                            final item = _uploadQueue[index];
                            return _buildUploadCard(item);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (pendingCount > 0 && connectivityService.isOnline)
            FloatingActionButton.extended(
              heroTag: 'upload_all',
              onPressed: _isUploading ? null : _uploadPendingImages,
              backgroundColor: const Color(0xFF0277BD),
              icon: _isUploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.cloud_upload),
              label: Text(
                'सभी अपलोड करें ($pendingCount)',
                style: GoogleFonts.notoSansDevanagari(),
              ),
            ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'camera',
            onPressed: _captureImage,
            backgroundColor: const Color(0xFF2E7D32),
            child: const Icon(Icons.camera_alt),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'gallery',
            onPressed: _pickImages,
            backgroundColor: const Color(0xFF1B5E20),
            child: const Icon(Icons.photo_library),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.notoSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 11,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadCard(ImageUploadItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(item.localPath),
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.broken_image),
                ),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    path.basename(item.localPath),
                    style: GoogleFonts.notoSans(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(item.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStatusIcon(item.status),
                        size: 14,
                        color: _getStatusColor(item.status),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getStatusText(item.status),
                        style: GoogleFonts.notoSansDevanagari(
                          fontSize: 11,
                          color: _getStatusColor(item.status),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 12, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      '${item.capturedAt.day}/${item.capturedAt.month} ${item.capturedAt.hour}:${item.capturedAt.minute.toString().padLeft(2, '0')}',
                      style: GoogleFonts.notoSans(fontSize: 11, color: Colors.grey.shade600),
                    ),
                    if (item.latitude != null && item.longitude != null) ...[
                      const SizedBox(width: 12),
                      Icon(Icons.location_on, size: 12, color: Colors.green.shade700),
                      const SizedBox(width: 2),
                      Text(
                        'GPS ✓',
                        style: GoogleFonts.notoSans(fontSize: 11, color: Colors.green.shade700),
                      ),
                    ],
                  ],
                ),
                if (item.status == UploadStatus.uploading && item.uploadProgress > 0) ...[
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: item.uploadProgress,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor(item.status)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(item.uploadProgress * 100).toInt()}% पूर्ण',
                    style: GoogleFonts.notoSansDevanagari(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
                if (item.errorMessage != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'त्रुटि: ${item.errorMessage}',
                    style: GoogleFonts.notoSansDevanagari(
                      fontSize: 11,
                      color: const Color(0xFFC62828),
                    ),
                  ),
                ],
              ],
            ),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'retry') {
                  _retryUpload(item);
                } else if (value == 'delete') {
                  _removeItem(item);
                }
              },
              itemBuilder: (context) => [
                if (item.status == UploadStatus.failed || item.status == UploadStatus.offline)
                  PopupMenuItem(
                    value: 'retry',
                    child: Row(
                      children: [
                        const Icon(Icons.refresh, size: 20),
                        const SizedBox(width: 8),
                        Text('पुनः प्रयास', style: GoogleFonts.notoSansDevanagari()),
                      ],
                    ),
                  ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete, size: 20, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(
                        'हटाएं',
                        style: GoogleFonts.notoSansDevanagari(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
