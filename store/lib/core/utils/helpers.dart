import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_constants.dart';

/// Helper utilities for common operations
class Helpers {
  Helpers._();
  
  /// Picks an image from the specified source
  static Future<File?> pickImage({
    required ImageSource source,
    int maxWidth = AppConstants.maxImageWidth,
    int maxHeight = AppConstants.maxImageHeight,
    int quality = AppConstants.imageQuality,
  }) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: quality,
      );
      
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }
  
  /// Picks multiple images from gallery
  static Future<List<File>> pickMultipleImages({
    int maxWidth = AppConstants.maxImageWidth,
    int maxHeight = AppConstants.maxImageHeight,
    int quality = AppConstants.imageQuality,
    int? limit,
  }) async {
    try {
      final picker = ImagePicker();
      final pickedFiles = await picker.pickMultiImage(
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: quality,
        limit: limit,
      );
      
      return pickedFiles.map((xFile) => File(xFile.path)).toList();
    } catch (e) {
      debugPrint('Error picking images: $e');
      return [];
    }
  }
  
  /// Compresses an image file
  static Future<File?> compressImage(
    File file, {
    int quality = AppConstants.imageQuality,
    int minWidth = 800,
    int minHeight = 800,
  }) async {
    try {
      final filePath = file.absolute.path;
      final lastIndex = filePath.lastIndexOf('.');
      final targetPath = '${filePath.substring(0, lastIndex)}_compressed.jpg';
      
      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        minWidth: minWidth,
        minHeight: minHeight,
      );
      
      if (result != null) {
        return File(result.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error compressing image: $e');
      return file; // Return original if compression fails
    }
  }
  
  /// Launches a URL in the browser
  static Future<bool> launchURL(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (e) {
      debugPrint('Error launching URL: $e');
      return false;
    }
  }
  
  /// Launches email app with pre-filled data
  static Future<bool> launchEmail({
    required String email,
    String? subject,
    String? body,
  }) async {
    try {
      final uri = Uri(
        scheme: 'mailto',
        path: email,
        queryParameters: {
          if (subject != null) 'subject': subject,
          if (body != null) 'body': body,
        },
      );
      return await launchUrl(uri);
    } catch (e) {
      debugPrint('Error launching email: $e');
      return false;
    }
  }
  
  /// Launches phone dialer
  static Future<bool> launchPhone(String phoneNumber) async {
    try {
      final uri = Uri(scheme: 'tel', path: phoneNumber);
      return await launchUrl(uri);
    } catch (e) {
      debugPrint('Error launching phone: $e');
      return false;
    }
  }
  
  /// Shares content using the system share sheet
  static Future<void> shareContent({
    required String text,
    String? subject,
  }) async {
    try {
      await Share.share(text, subject: subject);
    } catch (e) {
      debugPrint('Error sharing content: $e');
    }
  }
  
  /// Shares a storefront link
  static Future<void> shareStorefrontLink({
    required String artisanId,
    required String artisanName,
  }) async {
    final link = 'https://artisan.marketplace/store/$artisanId';
    await shareContent(
      text: 'Check out $artisanName\'s handmade products on Artisan Marketplace!\n\n$link',
      subject: '$artisanName\'s Storefront',
    );
  }
  
  /// Shows an image source selection dialog
  static Future<ImageSource?> showImageSourceDialog(BuildContext context) async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Shows a confirmation dialog
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: isDestructive
                ? ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  )
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }
  
  /// Formats file size for display
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1048576).toStringAsFixed(1)} MB';
  }
  
  /// Generates a unique filename with timestamp
  static String generateUniqueFilename(String originalName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = originalName.split('.').last;
    return '${timestamp}_${originalName.hashCode}.$extension';
  }
}
