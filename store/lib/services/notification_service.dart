import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../core/errors/failures.dart';
import '../core/errors/result.dart';

/// Service for handling push notifications.
/// 
/// Manages Firebase Cloud Messaging for order updates,
/// new orders, and other real-time notifications.
class NotificationService {
  final FirebaseMessaging _messaging;
  
  NotificationService({
    FirebaseMessaging? messaging,
  }) : _messaging = messaging ?? FirebaseMessaging.instance;
  
  /// Initialize notification service and request permissions
  Future<Result<void>> initialize() async {
    try {
      // Request notification permissions (iOS)
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('[v0] Notification permissions granted');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        debugPrint('[v0] Provisional notification permissions granted');
      } else {
        debugPrint('[v0] Notification permissions denied');
      }
      
      // Get FCM token
      final token = await getToken();
      if (token.isSuccess) {
        debugPrint('[v0] FCM Token: ${token.value}');
      }
      
      // Set up foreground message handler
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      
      // Set up background message handler
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
      
      // Check for any initial message (app opened from terminated state)
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleBackgroundMessage(initialMessage);
      }
      
      return Result.success(null);
    } catch (e) {
      return Result.failure(UnexpectedFailure.fromException(e));
    }
  }
  
  /// Get FCM token for this device
  Future<Result<String>> getToken() async {
    try {
      final token = await _messaging.getToken();
      
      if (token == null) {
        return Result.failure(
          const AppFailure(message: 'Failed to get FCM token'),
        );
      }
      
      return Result.success(token);
    } catch (e) {
      return Result.failure(UnexpectedFailure.fromException(e));
    }
  }
  
  /// Subscribe to a topic
  Future<Result<void>> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      debugPrint('[v0] Subscribed to topic: $topic');
      return Result.success(null);
    } catch (e) {
      return Result.failure(UnexpectedFailure.fromException(e));
    }
  }
  
  /// Unsubscribe from a topic
  Future<Result<void>> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      debugPrint('[v0] Unsubscribed from topic: $topic');
      return Result.success(null);
    } catch (e) {
      return Result.failure(UnexpectedFailure.fromException(e));
    }
  }
  
  /// Delete FCM token
  Future<Result<void>> deleteToken() async {
    try {
      await _messaging.deleteToken();
      return Result.success(null);
    } catch (e) {
      return Result.failure(UnexpectedFailure.fromException(e));
    }
  }
  
  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('[v0] Foreground message received');
    debugPrint('[v0] Title: ${message.notification?.title}');
    debugPrint('[v0] Body: ${message.notification?.body}');
    debugPrint('[v0] Data: ${message.data}');
    
    // TODO: Show local notification or update UI
    // You can add flutter_local_notifications package for local notifications
  }
  
  /// Handle background/terminated app messages
  void _handleBackgroundMessage(RemoteMessage message) {
    debugPrint('[v0] Background message received');
    debugPrint('[v0] Title: ${message.notification?.title}');
    debugPrint('[v0] Body: ${message.notification?.body}');
    debugPrint('[v0] Data: ${message.data}');
    
    // TODO: Navigate to appropriate screen based on message data
    final String? type = message.data['type'];
    final String? id = message.data['id'];
    
    if (type == 'order' && id != null) {
      // Navigate to order detail screen
      debugPrint('[v0] Navigate to order: $id');
    } else if (type == 'product' && id != null) {
      // Navigate to product detail screen
      debugPrint('[v0] Navigate to product: $id');
    }
  }
  
  /// Topic names for subscriptions
  static const String allUsersTopicName = 'all_users';
  static const String artisansTopicName = 'artisans';
  static const String customersTopicName = 'customers';
  
  /// Create artisan-specific topic name
  static String artisanOrdersTopic(String artisanId) => 'artisan_$artisanId';
  
  /// Create customer-specific topic name
  static String customerOrdersTopic(String customerId) => 'customer_$customerId';
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[v0] Background message handler');
  debugPrint('[v0] Title: ${message.notification?.title}');
  debugPrint('[v0] Body: ${message.notification?.body}');
  debugPrint('[v0] Data: ${message.data}');
}
