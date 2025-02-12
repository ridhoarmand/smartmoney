import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();

  factory RemoteConfigService() {
    return _instance;
  }

  RemoteConfigService._internal();

  late final FirebaseRemoteConfig _remoteConfig;
  String? _googleSignInClientId;

  Future<void> initialize() async {
    await Firebase.initializeApp();
    _remoteConfig = FirebaseRemoteConfig.instance;

    try {
      await _remoteConfig.fetchAndActivate();
      // Ambil nilai 'google_signin_client_id' dari Remote Config
      _googleSignInClientId =
          _remoteConfig.getString('google_signin_client_id');

      // Menyimpan nilai Google Sign-In Client ID ke SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('googleSignInClientId', _googleSignInClientId ?? '');
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching remote config: $e');
      }
    }
  }

  Future<String?> getGoogleSignInClientId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('googleSignInClientId');
  }
}
