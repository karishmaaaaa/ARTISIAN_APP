import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../core/constants/app_constants.dart';
import '../core/errors/failures.dart';
import '../core/errors/result.dart';
import '../core/utils/helpers.dart';

/// Service for handling image operations.
/// 
/// Provides image picking, compression, and upload functionality
/// to Firebase Storage with proper error handling.
class ImageService {
  final FirebaseStorage _storage;
  final ImagePicker _picker;
  
  ImageService({
    FirebaseStorage? storage,
    ImagePicker? picker,
  })  : _storage = storage ?? FirebaseStorage.instance,
        _picker = picker ?? ImagePicker();
  
  /// Pick an image from gallery
  Future<Result<File>> pickImageFromGallery() async {
    try {
      final XFile? xFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: AppConstants.maxImageWidth.toDouble(),
        maxHeight: AppConstants.maxImageHeight.toDouble(),
        imageQuality: AppConstants.imageQuality,
      );
      
      if (xFile == null) {
        return Result.failure(
          const AppFailure(message: 'No image selected'),
        );
      }
      
      final file = File(xFile.path);
      
      // Check file size
      final fileSizeInBytes = await file.length();
      final fileSizeInMB = fileSizeInBytes / (1024 * 1024);
      
      if (fileSizeInMB > AppConstants.maxFileSizeMB) {
        return Result.failure(
          AppFailure(
            message: 'Image size must be less than ${AppConstants.maxFileSizeMB}MB',
          ),
        );
      }
      
      return Result.success(file);
    } catch (e) {
      return Result.failure(UnexpectedFailure.fromException(e));
    }
  }
  
  /// Pick an image from camera
  Future<Result<File>> pickImageFromCamera() async {
    try {
      final XFile? xFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: AppConstants.maxImageWidth.toDouble(),
        maxHeight: AppConstants.maxImageHeight.toDouble(),
        imageQuality: AppConstants.imageQuality,
      );
      
      if (xFile == null) {
        return Result.failure(
          const AppFailure(message: 'No image captured'),
        );
      }
      
      return Result.success(File(xFile.path));
    } catch (e) {
      return Result.failure(UnexpectedFailure.fromException(e));
    }
  }
  
  /// Pick multiple images from gallery
  Future<Result<List<File>>> pickMultipleImages({
    int maxImages = AppConstants.maxProductImages,
  }) async {
    try {
      final List<XFile> xFiles = await _picker.pickMultiImage(
        maxWidth: AppConstants.maxImageWidth.toDouble(),
        maxHeight: AppConstants.maxImageHeight.toDouble(),
        imageQuality: AppConstants.imageQuality,
      );
      
      if (xFiles.isEmpty) {
        return Result.failure(
          const AppFailure(message: 'No images selected'),
        );
      }
      
      if (xFiles.length > maxImages) {
        return Result.failure(
          AppFailure(message: 'Maximum $maxImages images allowed'),
        );
      }
      
      final files = xFiles.map((xFile) => File(xFile.path)).toList();
      
      // Check total size
      int totalSize = 0;
      for (final file in files) {
        totalSize += await file.length();
      }
      final totalSizeMB = totalSize / (1024 * 1024);
      
      if (totalSizeMB > AppConstants.maxFileSizeMB * maxImages) {
        return Result.failure(
          const AppFailure(message: 'Total image size is too large'),
        );
      }
      
      return Result.success(files);
    } catch (e) {
      return Result.failure(UnexpectedFailure.fromException(e));
    }
  }
  
  /// Upload image to Firebase Storage
  Future<Result<String>> uploadImage({
    required File file,
    required String path,
    required String filename,
    Function(double)? onProgress,
  }) async {
    try {
      // Compress image before upload
      final compressedFile = await Helpers.compressImage(file);
      final uploadFile = compressedFile ?? file;
      
      final ref = _storage.ref().child(path).child(filename);
      final uploadTask = ref.putFile(uploadFile);
      
      // Monitor upload progress
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((taskSnapshot) {
          final progress = taskSnapshot.bytesTransferred / taskSnapshot.totalBytes;
          onProgress(progress);
        });
      }
      
      await uploadTask;
      final downloadUrl = await ref.getDownloadURL();
      
      return Result.success(downloadUrl);
    } on FirebaseException catch (e) {
      return Result.failure(StorageFailure.fromFirebaseStorage(e));
    } catch (e) {
      return Result.failure(UnexpectedFailure.fromException(e));
    }
  }
  
  /// Delete image from Firebase Storage
  Future<Result<void>> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      return Result.success(null);
    } on FirebaseException catch (e) {
      return Result.failure(StorageFailure.fromFirebaseStorage(e));
    } catch (e) {
      return Result.failure(UnexpectedFailure.fromException(e));
    }
  }
  
  /// Upload multiple images
  Future<Result<List<String>>> uploadMultipleImages({
    required List<File> files,
    required String path,
    Function(int, double)? onProgress,
  }) async {
    final urls = <String>[];
    
    for (int i = 0; i < files.length; i++) {
      final file = files[i];
      final filename = Helpers.generateUniqueFilename('image_$i.jpg');
      
      final result = await uploadImage(
        file: file,
        path: path,
        filename: filename,
        onProgress: onProgress != null 
            ? (progress) => onProgress(i, progress)
            : null,
      );
      
      if (result.isFailure) {
        // Clean up already uploaded images
        for (final url in urls) {
          await deleteImage(url);
        }
        return Result.failure(result.failure!);
      }
      
      urls.add(result.value!);
    }
    
    return Result.success(urls);
  }
  
  /// Show image source selection dialog options
  static const List<String> imageSourceOptions = ['Camera', 'Gallery'];
}
