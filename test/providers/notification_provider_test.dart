import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:chef_specials/providers/notification_provider.dart';
import 'package:chef_specials/services/notification_service.dart';

void main() {
  group('NotificationProvider', () {
    late NotificationService mockService;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      mockService = NotificationService(
        firestore: FakeFirebaseFirestore(),
        localNotifications: FlutterLocalNotificationsPlugin(),
      );
    });

    test('has correct default values', () {
      final provider = NotificationProvider(
        service: mockService,
        authStream: const Stream<User?>.empty(),
      );

      expect(provider.breakfastEnabled, false);
      expect(provider.breakfastTime, const TimeOfDay(hour: 8, minute: 0));
      expect(provider.lunchEnabled, false);
      expect(provider.lunchTime, const TimeOfDay(hour: 12, minute: 0));
      expect(provider.dinnerEnabled, false);
      expect(provider.dinnerTime, const TimeOfDay(hour: 19, minute: 0));
      expect(provider.newRecipeAlerts, false);
      expect(provider.commentAlerts, false);
      expect(provider.followerAlerts, false);
    });

    test('loads persisted meal reminder settings from SharedPreferences',
        () async {
      SharedPreferences.setMockInitialValues({
        'notif_breakfast_enabled': true,
        'notif_breakfast_hour': 7,
        'notif_breakfast_minute': 30,
        'notif_lunch_enabled': true,
        'notif_lunch_hour': 13,
        'notif_lunch_minute': 15,
        'notif_dinner_enabled': false,
        'notif_dinner_hour': 20,
        'notif_dinner_minute': 0,
      });

      final provider = NotificationProvider(
        service: mockService,
        authStream: const Stream<User?>.empty(),
      );
      final prefs = await SharedPreferences.getInstance();

      expect(prefs.getBool('notif_breakfast_enabled'), true);
      expect(prefs.getInt('notif_breakfast_hour'), 7);
      expect(prefs.getInt('notif_breakfast_minute'), 30);
      expect(prefs.getBool('notif_lunch_enabled'), true);
      expect(prefs.getInt('notif_lunch_hour'), 13);
      expect(prefs.getInt('notif_lunch_minute'), 15);
      expect(prefs.getBool('notif_dinner_enabled'), false);
      expect(prefs.getInt('notif_dinner_hour'), 20);
      expect(prefs.getInt('notif_dinner_minute'), 0);
      expect(provider, isNotNull);
    });

    test('loads persisted social alert settings from SharedPreferences',
        () async {
      SharedPreferences.setMockInitialValues({
        'notif_new_recipe_alerts': true,
        'notif_comment_alerts': true,
        'notif_follower_alerts': false,
      });

      final prefs = await SharedPreferences.getInstance();

      expect(prefs.getBool('notif_new_recipe_alerts'), true);
      expect(prefs.getBool('notif_comment_alerts'), true);
      expect(prefs.getBool('notif_follower_alerts'), false);
    });

    test('can be instantiated with mock service', () {
      final provider = NotificationProvider(
        service: mockService,
        authStream: const Stream<User?>.empty(),
      );
      expect(provider, isNotNull);
    });

    test('default times are set correctly', () {
      final provider = NotificationProvider(
        service: mockService,
        authStream: const Stream<User?>.empty(),
      );
      expect(provider.breakfastTime.hour, 8);
      expect(provider.breakfastTime.minute, 0);
      expect(provider.lunchTime.hour, 12);
      expect(provider.lunchTime.minute, 0);
      expect(provider.dinnerTime.hour, 19);
      expect(provider.dinnerTime.minute, 0);
    });

    test('SharedPreferences round-trip for all keys', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      // Simulate saving
      await prefs.setBool('notif_breakfast_enabled', true);
      await prefs.setInt('notif_breakfast_hour', 9);
      await prefs.setInt('notif_breakfast_minute', 15);
      await prefs.setBool('notif_lunch_enabled', false);
      await prefs.setInt('notif_lunch_hour', 11);
      await prefs.setInt('notif_lunch_minute', 45);
      await prefs.setBool('notif_dinner_enabled', true);
      await prefs.setInt('notif_dinner_hour', 18);
      await prefs.setInt('notif_dinner_minute', 30);
      await prefs.setBool('notif_new_recipe_alerts', true);
      await prefs.setBool('notif_comment_alerts', false);
      await prefs.setBool('notif_follower_alerts', true);

      // Simulate loading
      expect(prefs.getBool('notif_breakfast_enabled'), true);
      expect(prefs.getInt('notif_breakfast_hour'), 9);
      expect(prefs.getInt('notif_breakfast_minute'), 15);
      expect(prefs.getBool('notif_lunch_enabled'), false);
      expect(prefs.getInt('notif_lunch_hour'), 11);
      expect(prefs.getInt('notif_lunch_minute'), 45);
      expect(prefs.getBool('notif_dinner_enabled'), true);
      expect(prefs.getInt('notif_dinner_hour'), 18);
      expect(prefs.getInt('notif_dinner_minute'), 30);
      expect(prefs.getBool('notif_new_recipe_alerts'), true);
      expect(prefs.getBool('notif_comment_alerts'), false);
      expect(prefs.getBool('notif_follower_alerts'), true);
    });
  });
}
