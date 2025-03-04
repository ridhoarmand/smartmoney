import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../firebase_options.dart';

class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();

  factory RemoteConfigService() {
    return _instance;
  }

  RemoteConfigService._internal();

  // Use nullable instead of late
  FirebaseRemoteConfig? _remoteConfig;
  String? _googleSignInClientId;

  Future<void> initialize() async {
    // Initialize Firebase first
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize remote config
    _remoteConfig = FirebaseRemoteConfig.instance;

    try {
      // Set default values if needed
      await _remoteConfig?.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ));

      // Fetch and activate
      await _remoteConfig?.fetchAndActivate();

      // Get the client ID
      _googleSignInClientId =
          _remoteConfig?.getString('google_signin_client_id');

      // Store in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('googleSignInClientId', _googleSignInClientId ?? '');

      if (kDebugMode) {
        print(
            'Remote config initialized with client ID: $_googleSignInClientId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching remote config: $e');
      }
    }
  }

  Future<String?> getGoogleSignInClientId() async {
    // Try to get from memory first
    if (_googleSignInClientId != null) {
      return _googleSignInClientId;
    }

    // Fall back to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('googleSignInClientId');
  }
}
